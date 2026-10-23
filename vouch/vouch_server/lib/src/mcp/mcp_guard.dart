import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';

import '../approval/approval_endpoint.dart';
import '../attestation/attestation_service.dart';
import '../attestation/transcript_matcher.dart';
import '../audit/audit_service.dart';
import '../generated/protocol.dart';
import '../policy/policy_engine.dart';
import 'request_state.dart';
import 'tools.dart';

/// The "who spoke" decision trace for a single `tools/call`, surfaced to
/// clients as `structuredContent.vouch` on every result shape (success,
/// tool error, and input_required — see mcp_route.dart D3c). This is the
/// pitch's core artifact: it never carries voice/biometric data, only the
/// resolved identity + policy outcome.
///
/// [decision] is one of: "allow", "stepUp", "deny" (fresh-call outcomes),
/// or "pending", "approved", "denied", "expired" (MRTR/legacy retry
/// outcomes). [presentTier] on a retry leg reflects the tier presented at
/// the *original* fresh call that opened the step-up (no new attestation is
/// presented on a retry itself). [ruleSource] is the `sourceText` of the
/// [PolicyRule] that matched, if any rule matched and it was entered as
/// plain language.
class VouchTrace {
  const VouchTrace({
    required this.speaker,
    required this.confidence,
    required this.attestationMatched,
    required this.matchedTranscript,
    required this.requiredTier,
    required this.presentTier,
    required this.decision,
    required this.reason,
    required this.ruleSource,
  });

  final Map<String, dynamic>? speaker;
  final double? confidence;
  final bool attestationMatched;
  final String? matchedTranscript;
  final String requiredTier;
  final String presentTier;
  final String decision;
  final String reason;
  final String? ruleSource;

  Map<String, dynamic> toJson() => {
    'speaker': speaker,
    'confidence': confidence,
    'attestationMatched': attestationMatched,
    'matchedTranscript': matchedTranscript,
    'requiredTier': requiredTier,
    'presentTier': presentTier,
    'decision': decision,
    'reason': reason,
    'ruleSource': ruleSource,
  };
}

/// Outcome of running a `tools/call` through the guard. Mirrors the MRTR
/// result shapes the route needs to emit (see mcp_route.dart).
sealed class McpGuardOutcome {
  McpGuardOutcome(this.trace);
  final VouchTrace trace;
}

class McpGuardSuccess extends McpGuardOutcome {
  McpGuardSuccess(this.text, VouchTrace trace) : super(trace);
  final String text;
}

class McpGuardToolError extends McpGuardOutcome {
  McpGuardToolError(this.reason, VouchTrace trace) : super(trace);
  final String reason;
}

class McpGuardInputRequired extends McpGuardOutcome {
  McpGuardInputRequired(this.requestState, this.message, VouchTrace trace)
    : super(trace);
  final String requestState;
  final String message;
}

/// A protocol-level error (bad requestState, etc) — the caller must surface
/// this as a JSON-RPC error, not a tool result.
class McpGuardProtocolError implements Exception {
  McpGuardProtocolError(this.code, this.message);
  final int code;
  final String message;
}

/// The step-up approval window. Matches the Approval.expiresAt spread used
/// when creating a pending row.
const Duration approvalWindow = Duration(seconds: 60);

/// Runs a `tools/call` (name, args, householdId, and optionally an MRTR
/// retry's requestState + inputResponses) through the full attestation +
/// policy + (if needed) step-up-approval guard.
class McpGuard {
  const McpGuard._();

  static Future<McpGuardOutcome> handleToolCall(
    Session session, {
    required int householdId,
    required String toolName,
    required Map<String, dynamic> args,
    String? requestState,
    Map<String, dynamic>? inputResponses,
  }) async {
    final tool = findMcpTool(toolName);
    if (tool == null) {
      throw McpGuardProtocolError(-32602, 'unknown tool "$toolName"');
    }

    final utterance = args['utterance'];
    if (utterance is! String || utterance.isEmpty) {
      throw McpGuardProtocolError(
        -32602,
        'missing required "utterance" argument',
      );
    }

    // Tool args excluding `utterance` itself — this is what policy rules
    // (e.g. maxAmount) and the requestState argsHash operate over.
    final toolArgs = Map<String, dynamic>.of(args)..remove('utterance');

    // --- MRTR retry path: a requestState was echoed back. -----------------
    if (requestState != null) {
      return _handleRetry(
        session,
        householdId: householdId,
        toolName: toolName,
        toolArgs: toolArgs,
        utterance: utterance,
        requestState: requestState,
      );
    }

    // --- Fresh call: attest, decide. --------------------------------------
    final attestation = await AttestationService.consumeMatching(
      session,
      householdId: householdId,
      alexaCommandText: utterance,
    );
    // Alexa+ is an LLM and may paraphrase. A near-miss names a plausible
    // speaker (so their rules, incl. denies, still apply) but does not bind
    // them to this command, so anything above T0 goes to the owner.
    final nearMiss = attestation == null
        ? await AttestationService.consumeNearMiss(
            session,
            householdId: householdId,
            alexaCommandText: utterance,
          )
        : null;
    final evidence = attestation ?? nearMiss;
    final speaker = evidence?.member;
    final attestedTier = evidence?.tier ?? TrustTier.t0;

    final household = await Household.db.findById(session, householdId);
    final rules = household == null
        ? <PolicyRule>[]
        : await PolicyRule.db.find(
            session,
            where: (t) =>
                t.householdId.equals(householdId) & t.enabled.equals(true),
          );

    // A tool with no built-in default tier may still have a cached risk
    // classification (see ToolClassification / RulesEndpoint.classifyTool).
    // PolicyEngine.decide only ever consults this when no PolicyRule
    // matches AND the action has no built-in default, so it is safe to
    // always look it up here — a rule or built-in default simply takes
    // priority over it inside decide().
    TrustTier? classifiedTier;
    if (!hasBuiltInDefaultTier(toolName)) {
      final classification = await ToolClassification.db.findFirstRow(
        session,
        where: (t) => t.toolName.equals(toolName),
      );
      classifiedTier = classification?.tier;
    }

    var decision = PolicyEngine.decide(
      rules: rules,
      speaker: speaker,
      speakerRole: speaker?.role,
      action: toolName,
      args: toolArgs,
      attestedTier: attestedTier,
      classifiedTier: classifiedTier,
    );
    if (nearMiss != null &&
        decision.effect == PolicyDecisionEffect.allow &&
        decision.requiredTier != TrustTier.t0) {
      decision = PolicyDecision(
        effect: PolicyDecisionEffect.stepUp,
        requiredTier: decision.requiredTier,
        matchedRuleId: decision.matchedRuleId,
        reason:
            'command paraphrased (hub heard "${nearMiss.transcriptNormalised}"); '
            'owner approval required',
      );
    }

    String? ruleSource;
    final matchedRuleId = decision.matchedRuleId;
    if (matchedRuleId != null) {
      final matchedRule = await PolicyRule.db.findById(session, matchedRuleId);
      ruleSource = matchedRule?.sourceText;
    }

    VouchTrace buildTrace(String decisionLabel) => VouchTrace(
      speaker: speaker == null
          ? null
          : {
              'memberId': speaker.id,
              'displayName': speaker.displayName,
              'role': speaker.role.name,
            },
      confidence: evidence?.confidence,
      attestationMatched: attestation != null,
      matchedTranscript: evidence?.transcriptNormalised,
      requiredTier: decision.requiredTier.name,
      presentTier: attestedTier.name,
      decision: decisionLabel,
      reason: decision.reason,
      ruleSource: ruleSource,
    );

    switch (decision.effect) {
      case PolicyDecisionEffect.allow:
        final text = runMockTool(toolName, toolArgs);
        await AuditService.append(
          session,
          householdId: householdId,
          memberId: speaker?.id,
          eventType: 'mcp.tool_call',
          action: toolName,
          decision: AuditDecision.permitted,
          tierRequired: decision.requiredTier,
          tierPresent: attestedTier,
          reason: decision.reason,
        );
        return McpGuardSuccess(text, buildTrace('allow'));

      case PolicyDecisionEffect.deny:
        await AuditService.append(
          session,
          householdId: householdId,
          memberId: speaker?.id,
          eventType: 'mcp.tool_call',
          action: toolName,
          decision: AuditDecision.denied,
          tierRequired: decision.requiredTier,
          tierPresent: attestedTier,
          reason: decision.reason,
        );
        return McpGuardToolError(decision.reason, buildTrace('deny'));

      case PolicyDecisionEffect.stepUp:
        final now = DateTime.now().toUtc();
        final approval = await Approval.db.insertRow(
          session,
          Approval(
            householdId: householdId,
            memberId: speaker?.id,
            action: toolName,
            argsJson: jsonEncode(toolArgs),
            utterance: utterance,
            speakerConfidence: evidence?.confidence,
            transcriptMatch: attestation != null
                ? 'matched'
                : (nearMiss != null ? 'near_miss' : 'none'),
            heardTranscript: evidence?.transcriptNormalised,
            transcriptSimilarity: evidence == null
                ? null
                : TranscriptMatcher.tokenSetSimilarity(
                    TranscriptMatcher.normalise(evidence.transcriptNormalised),
                    TranscriptMatcher.normalise(utterance),
                  ),
            requiredTier: decision.requiredTier,
            presentTier: attestedTier,
            policyReason: decision.reason,
            ruleSource: ruleSource,
            status: ApprovalStatus.pending,
            used: false,
            createdAt: now,
            expiresAt: now.add(approvalWindow),
          ),
        );

        final state = RequestStateCodec.encode(
          session,
          RequestStatePayload(
            approvalId: approval.id!,
            householdId: householdId,
            tool: toolName,
            argsHash: RequestStateCodec.hashArgs(toolArgs),
            exp: approval.expiresAt.millisecondsSinceEpoch ~/ 1000,
          ),
        );

        await AuditService.append(
          session,
          householdId: householdId,
          memberId: speaker?.id,
          eventType: 'mcp.tool_call',
          action: toolName,
          decision: AuditDecision.challenged,
          tierRequired: decision.requiredTier,
          tierPresent: attestedTier,
          reason: 'step-up requested (approval ${approval.id})',
        );

        // Push the new pending approval to any admin app subscribed to
        // ApprovalEndpoint.pendingApprovals for this household.
        await session.messages.postMessage(
          ApprovalEndpoint.channelFor(householdId),
          approval,
        );

        return McpGuardInputRequired(
          state,
          "Waiting for approval on the owner's phone — say or tap confirm "
          'when approved.',
          buildTrace('stepUp'),
        );
    }
  }

  /// Builds the trace for a retry leg (MRTR/legacy `approvalRef`
  /// resubmission). No fresh attestation is presented on a retry, so the
  /// evidence reported is the evidence recorded on the [Approval] when the
  /// original fresh call opened the step-up (speaker, confidence, whether
  /// the transcript matched, tiers, rule). Every leg of one request
  /// therefore reports the same evidence. Rows created before those fields
  /// existed fall back to conservative values (not matched, t0 presented).
  static Future<VouchTrace> _buildRetryTrace(
    Session session,
    Approval approval, {
    required String decisionLabel,
    required String reason,
  }) async {
    Member? member;
    final memberId = approval.memberId;
    if (memberId != null) {
      member = await Member.db.findById(session, memberId);
    }
    return VouchTrace(
      speaker: member == null
          ? null
          : {
              'memberId': member.id,
              'displayName': member.displayName,
              'role': member.role.name,
            },
      confidence: approval.speakerConfidence,
      attestationMatched: approval.transcriptMatch == 'matched',
      matchedTranscript: approval.heardTranscript,
      requiredTier: (approval.requiredTier ?? TrustTier.t2).name,
      presentTier: (approval.presentTier ?? TrustTier.t0).name,
      decision: decisionLabel,
      reason: reason,
      ruleSource: approval.ruleSource,
    );
  }

  static Future<McpGuardOutcome> _handleRetry(
    Session session, {
    required int householdId,
    required String toolName,
    required Map<String, dynamic> toolArgs,
    required String utterance,
    required String requestState,
  }) async {
    final payload = RequestStateCodec.decodeAndVerify(session, requestState);
    if (payload == null) {
      // Tampered/malformed requestState -> protocol-level error, per spec
      // (this is not a tool-level decision, it's an integrity failure).
      throw McpGuardProtocolError(-32602, 'invalid or tampered requestState');
    }

    if (payload.householdId != householdId || payload.tool != toolName) {
      throw McpGuardProtocolError(
        -32602,
        'requestState does not match this call (household/tool mismatch)',
      );
    }

    final currentArgsHash = RequestStateCodec.hashArgs(toolArgs);
    if (payload.argsHash != currentArgsHash) {
      throw McpGuardProtocolError(
        -32602,
        'requestState does not match this call (args mismatch)',
      );
    }

    final nowSeconds = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    if (nowSeconds > payload.exp) {
      await AuditService.append(
        session,
        householdId: householdId,
        eventType: 'mcp.tool_call',
        action: toolName,
        decision: AuditDecision.denied,
        reason: 'step-up requestState expired',
      );
      return McpGuardToolError(
        'The approval window has expired. Please try again.',
        VouchTrace(
          speaker: null,
          confidence: null,
          attestationMatched: false,
          matchedTranscript: utterance,
          requiredTier: TrustTier.t2.name,
          presentTier: TrustTier.t0.name,
          decision: 'expired',
          reason: 'step-up requestState expired',
          ruleSource: null,
        ),
      );
    }

    final approval = await Approval.db.findById(session, payload.approvalId);
    if (approval == null) {
      throw McpGuardProtocolError(
        -32602,
        'unknown approval referenced by requestState',
      );
    }

    switch (approval.status) {
      case ApprovalStatus.pending:
        // Still waiting on the owner. Same requestState is fine to hand
        // back — see class doc: we chose to re-issue the identical blob
        // rather than mint a new one, since nothing about the pending
        // request has changed and it simplifies client-side retry logic
        // (no new value to track).
        return McpGuardInputRequired(
          requestState,
          "Still waiting for approval on the owner's phone.",
          await _buildRetryTrace(
            session,
            approval,
            decisionLabel: 'pending',
            reason: "waiting for the owner's decision",
          ),
        );

      case ApprovalStatus.denied:
        await AuditService.append(
          session,
          householdId: householdId,
          memberId: approval.memberId,
          eventType: 'mcp.tool_call',
          action: toolName,
          decision: AuditDecision.denied,
          reason: 'step-up denied by owner (approval ${approval.id})',
        );
        return McpGuardToolError(
          'The owner denied this request.',
          await _buildRetryTrace(
            session,
            approval,
            decisionLabel: 'denied',
            reason: 'step-up denied by owner (approval ${approval.id})',
          ),
        );

      case ApprovalStatus.expired:
        await AuditService.append(
          session,
          householdId: householdId,
          memberId: approval.memberId,
          eventType: 'mcp.tool_call',
          action: toolName,
          decision: AuditDecision.denied,
          reason: 'step-up approval expired (approval ${approval.id})',
        );
        return McpGuardToolError(
          'The approval window has expired. Please try again.',
          await _buildRetryTrace(
            session,
            approval,
            decisionLabel: 'expired',
            reason: 'step-up approval expired (approval ${approval.id})',
          ),
        );

      case ApprovalStatus.approved:
        if (approval.used) {
          await AuditService.append(
            session,
            householdId: householdId,
            memberId: approval.memberId,
            eventType: 'mcp.tool_call',
            action: toolName,
            decision: AuditDecision.denied,
            reason:
                'replayed requestState for already-used approval ${approval.id}',
          );
          return McpGuardToolError(
            'This approval has already been used.',
            await _buildRetryTrace(
              session,
              approval,
              decisionLabel: 'denied',
              reason:
                  'replayed requestState for already-used approval ${approval.id}',
            ),
          );
        }

        // Atomically claim the approval so a concurrent replay can't also
        // execute the tool.
        final claimed = await session.db.transaction((tx) async {
          final fresh = await Approval.db.findById(
            session,
            approval.id!,
            transaction: tx,
          );
          if (fresh == null ||
              fresh.status != ApprovalStatus.approved ||
              fresh.used) {
            return null;
          }
          return Approval.db.updateRow(
            session,
            fresh.copyWith(used: true),
            transaction: tx,
          );
        });

        if (claimed == null) {
          return McpGuardToolError(
            'This approval has already been used.',
            await _buildRetryTrace(
              session,
              approval,
              decisionLabel: 'denied',
              reason: 'approval already claimed by a concurrent request',
            ),
          );
        }

        final text = runMockTool(toolName, toolArgs);
        await AuditService.append(
          session,
          householdId: householdId,
          memberId: claimed.memberId,
          eventType: 'mcp.tool_call',
          action: toolName,
          decision: AuditDecision.permitted,
          tierRequired: TrustTier.t2,
          reason: 'step-up approved and executed (approval ${claimed.id})',
        );
        return McpGuardSuccess(
          text,
          await _buildRetryTrace(
            session,
            claimed,
            decisionLabel: 'approved',
            reason: 'step-up approved and executed (approval ${claimed.id})',
          ),
        );
    }
  }
}

/// sha256 hex digest helper reused by callers that need to independently
/// hash a bearer token (kept here to avoid a second import of `crypto` at
/// call sites that already import this file). See mcp_route.dart.
String sha256Hex(String input) => sha256.convert(utf8.encode(input)).toString();

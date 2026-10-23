import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'package:vouch_server/src/attestation/attestation_service.dart';
import 'package:vouch_server/src/attestation/attestation_signature.dart';
import 'package:vouch_server/src/attestation/transcript_matcher.dart';
import 'package:vouch_server/src/generated/protocol.dart';
import 'package:vouch_server/src/mcp/mcp_guard.dart';
import 'package:vouch_server/src/mcp/request_state.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given a household with a hub, owner and child', (
    sessionBuilder,
    endpoints,
  ) {
    var session = sessionBuilder.build();

    late Household household;
    late Member owner;
    late Member child;
    late Hub hub;
    late String publicKeyBase64;
    late dynamic keyPairHandle;

    setUp(() async {
      household = await Household.db.insertRow(
        session,
        Household(name: 'Test Household', createdAt: DateTime.now().toUtc()),
      );
      owner = await Member.db.insertRow(
        session,
        Member(
          householdId: household.id!,
          displayName: 'Alice',
          role: MemberRole.owner,
          status: MemberStatus.active,
        ),
      );
      child = await Member.db.insertRow(
        session,
        Member(
          householdId: household.id!,
          displayName: 'Kiddo',
          role: MemberRole.child,
          status: MemberStatus.active,
        ),
      );

      final probe = await AttestationSignature.signForTest('probe');
      keyPairHandle = probe.keyPair;
      publicKeyBase64 = probe.publicKeyBase64;

      hub = await Hub.db.insertRow(
        session,
        Hub(
          householdId: household.id!,
          publicKey: publicKeyBase64,
          version: '0.0.1-test',
        ),
      );

      // Default household policy rules, plus a child-specific deny for
      // place_order.
      for (final rule in [
        ...const [
          'get_weather',
          'play_music',
        ].map(
          (a) => PolicyRule(
            householdId: household.id!,
            actionPattern: a,
            requiredTier: TrustTier.t0,
            effect: PolicyEffect.require,
            enabled: true,
          ),
        ),
        PolicyRule(
          householdId: household.id!,
          actionPattern: 'add_to_list',
          requiredTier: TrustTier.t1,
          effect: PolicyEffect.require,
          enabled: true,
        ),
        PolicyRule(
          householdId: household.id!,
          actionPattern: 'unlock_front_door',
          requiredTier: TrustTier.t2,
          effect: PolicyEffect.require,
          enabled: true,
        ),
        PolicyRule(
          householdId: household.id!,
          memberId: child.id!,
          actionPattern: 'place_order',
          requiredTier: TrustTier.t0,
          effect: PolicyEffect.deny,
          enabled: true,
        ),
      ]) {
        await PolicyRule.db.insertRow(session, rule);
      }
    });

    Future<void> issueAttestation({
      required int memberId,
      required TrustTier tier,
      required String transcript,
      DateTime? capturedAt,
    }) async {
      final now = (capturedAt ?? DateTime.now().toUtc());
      final transcriptHash = TranscriptMatcher.hash(transcript);
      final payload = AttestationSignature.canonicalPayload(
        hubId: hub.id!,
        memberId: memberId,
        tier: tier.name,
        confidence: 0.95,
        spoofRisk: SpoofRisk.low.name,
        transcriptHash: transcriptHash,
        capturedAt: now,
      );
      final signed = await AttestationSignature.signForTest(
        payload,
        keyPair: keyPairHandle,
      );
      await AttestationService.submit(
        session,
        hubId: hub.id!,
        memberId: memberId,
        tier: tier,
        confidence: 0.95,
        spoofRisk: SpoofRisk.low,
        transcriptNormalised: transcript,
        capturedAt: now,
        signatureBase64: signed.signatureBase64,
      );
    }

    test('T0 tool allowed with no attestation', () async {
      final outcome = await McpGuard.handleToolCall(
        session,
        householdId: household.id!,
        toolName: 'get_weather',
        args: const {'utterance': "what's the weather"},
      );
      expect(outcome, isA<McpGuardSuccess>());
    });

    test('T1 tool allowed only with a matching attestation', () async {
      await issueAttestation(
        memberId: owner.id!,
        tier: TrustTier.t1,
        transcript: 'add milk to the list',
      );
      final outcome = await McpGuard.handleToolCall(
        session,
        householdId: household.id!,
        toolName: 'add_to_list',
        args: const {'utterance': 'add milk to the list', 'item': 'milk'},
      );
      expect(outcome, isA<McpGuardSuccess>());
    });

    test('T1 with non-matching utterance is denied', () async {
      final outcome = await McpGuard.handleToolCall(
        session,
        householdId: household.id!,
        toolName: 'add_to_list',
        args: const {'utterance': 'add milk to the list', 'item': 'milk'},
      );
      expect(outcome, isA<McpGuardToolError>());
    });

    test('child role place_order denied via policy rule', () async {
      await issueAttestation(
        memberId: child.id!,
        tier: TrustTier.t2,
        transcript: 'order a book',
      );
      final outcome = await McpGuard.handleToolCall(
        session,
        householdId: household.id!,
        toolName: 'place_order',
        args: const {
          'utterance': 'order a book',
          'item': 'book',
          'amount': 5,
          'currency': 'EUR',
        },
      );
      expect(outcome, isA<McpGuardToolError>());
    });

    test('T2 unlock_front_door returns input_required', () async {
      await issueAttestation(
        memberId: owner.id!,
        tier: TrustTier.t1,
        transcript: 'unlock the front door',
      );
      final outcome = await McpGuard.handleToolCall(
        session,
        householdId: household.id!,
        toolName: 'unlock_front_door',
        args: const {'utterance': 'unlock the front door'},
      );
      expect(outcome, isA<McpGuardInputRequired>());
    });

    group('step-up retry flow', () {
      late String requestState;

      setUp(() async {
        await issueAttestation(
          memberId: owner.id!,
          tier: TrustTier.t1,
          transcript: 'unlock the front door',
        );
        final outcome = await McpGuard.handleToolCall(
          session,
          householdId: household.id!,
          toolName: 'unlock_front_door',
          args: const {'utterance': 'unlock the front door'},
        );
        requestState = (outcome as McpGuardInputRequired).requestState;
      });

      test(
        'retry before approval decided returns input_required again',
        () async {
          final outcome = await McpGuard.handleToolCall(
            session,
            householdId: household.id!,
            toolName: 'unlock_front_door',
            args: const {'utterance': 'unlock the front door'},
            requestState: requestState,
          );
          expect(outcome, isA<McpGuardInputRequired>());
        },
      );

      test('after approve, retry succeeds exactly once', () async {
        final payload = RequestStateCodec.decodeAndVerify(
          session,
          requestState,
        )!;
        final approval = (await Approval.db.findById(
          session,
          payload.approvalId,
        ))!;
        await Approval.db.updateRow(
          session,
          approval.copyWith(
            status: ApprovalStatus.approved,
            decidedAt: DateTime.now().toUtc(),
          ),
        );

        final first = await McpGuard.handleToolCall(
          session,
          householdId: household.id!,
          toolName: 'unlock_front_door',
          args: const {'utterance': 'unlock the front door'},
          requestState: requestState,
        );
        expect(first, isA<McpGuardSuccess>());

        final second = await McpGuard.handleToolCall(
          session,
          householdId: household.id!,
          toolName: 'unlock_front_door',
          args: const {'utterance': 'unlock the front door'},
          requestState: requestState,
        );
        expect(second, isA<McpGuardToolError>());
      });

      test('tampered requestState throws a protocol error', () async {
        final tampered = '${requestState}tampered';
        expect(
          () => McpGuard.handleToolCall(
            session,
            householdId: household.id!,
            toolName: 'unlock_front_door',
            args: const {'utterance': 'unlock the front door'},
            requestState: tampered,
          ),
          throwsA(isA<McpGuardProtocolError>()),
        );
      });

      test('expired approval is denied', () async {
        final payload = RequestStateCodec.decodeAndVerify(
          session,
          requestState,
        )!;
        final approval = (await Approval.db.findById(
          session,
          payload.approvalId,
        ))!;
        await Approval.db.updateRow(
          session,
          approval.copyWith(status: ApprovalStatus.expired),
        );

        final outcome = await McpGuard.handleToolCall(
          session,
          householdId: household.id!,
          toolName: 'unlock_front_door',
          args: const {'utterance': 'unlock the front door'},
          requestState: requestState,
        );
        expect(outcome, isA<McpGuardToolError>());
      });
    });

    test(
      'unclassified unknown tool (no rule, no built-in default) steps up',
      () async {
        await issueAttestation(
          memberId: owner.id!,
          tier: TrustTier.t1,
          transcript: 'check the traffic',
        );
        final outcome = await McpGuard.handleToolCall(
          session,
          householdId: household.id!,
          toolName: 'check_traffic',
          args: const {'utterance': 'check the traffic'},
        );
        expect(outcome, isA<McpGuardInputRequired>());
        expect(outcome.trace.requiredTier, TrustTier.t2.name);
      },
    );

    test(
      'unknown tool with cached t0 classification is allowed without '
      'attestation',
      () async {
        await ToolClassification.db.insertRow(
          session,
          ToolClassification(
            toolName: 'check_traffic',
            tier: TrustTier.t0,
            reason: 'read-only informational query, no side effects',
            model: 'test-model',
            createdAt: DateTime.now().toUtc(),
          ),
        );

        final outcome = await McpGuard.handleToolCall(
          session,
          householdId: household.id!,
          toolName: 'check_traffic',
          args: const {'utterance': 'check the traffic'},
        );
        expect(outcome, isA<McpGuardSuccess>());
        expect(outcome.trace.requiredTier, TrustTier.t0.name);
      },
    );

    group('approval records the transcript evidence', () {
      Future<Approval> latestApproval(String action) async =>
          (await Approval.db.find(
            session,
            where: (t) =>
                t.householdId.equals(household.id!) & t.action.equals(action),
            orderBy: (t) => t.createdAt.desc(),
            limit: 1,
          )).single;

      test('exact match stores transcriptMatch=matched', () async {
        await issueAttestation(
          memberId: owner.id!,
          tier: TrustTier.t1,
          transcript: 'unlock the front door',
        );
        await McpGuard.handleToolCall(
          session,
          householdId: household.id!,
          toolName: 'unlock_front_door',
          args: const {'utterance': 'unlock the front door'},
        );
        final a = await latestApproval('unlock_front_door');
        expect(a.transcriptMatch, 'matched');
        expect(a.heardTranscript, 'unlock the front door');
        expect(a.transcriptSimilarity, closeTo(1.0, 1e-9));
        expect(a.presentTier, TrustTier.t1);
        expect(a.requiredTier, TrustTier.t2);
      });

      test(
        'near miss stores transcriptMatch=near_miss and heard text',
        () async {
          await issueAttestation(
            memberId: owner.id!,
            tier: TrustTier.t1,
            transcript: 'add milk to the shopping list',
          );
          await McpGuard.handleToolCall(
            session,
            householdId: household.id!,
            toolName: 'add_to_list',
            args: const {
              'utterance': 'add milk to my shopping list',
              'item': 'milk',
            },
          );
          final a = await latestApproval('add_to_list');
          expect(a.transcriptMatch, 'near_miss');
          expect(a.heardTranscript, 'add milk to the shopping list');
          expect(a.utterance, 'add milk to my shopping list');
          expect(a.transcriptSimilarity, lessThan(0.90));
          expect(a.transcriptSimilarity, greaterThanOrEqualTo(0.70));
        },
      );

      test('retries report the same evidence as the first call', () async {
        await issueAttestation(
          memberId: owner.id!,
          tier: TrustTier.t1,
          transcript: 'add milk to the shopping list',
        );
        const args = {
          'utterance': 'add milk to my shopping list',
          'item': 'milk',
        };
        final first = await McpGuard.handleToolCall(
          session,
          householdId: household.id!,
          toolName: 'add_to_list',
          args: args,
        );
        final state = (first as McpGuardInputRequired).requestState;
        final pending = await McpGuard.handleToolCall(
          session,
          householdId: household.id!,
          toolName: 'add_to_list',
          args: args,
          requestState: state,
        );
        for (final t in [pending.trace]) {
          expect(t.attestationMatched, first.trace.attestationMatched);
          expect(t.attestationMatched, isFalse);
          expect(t.confidence, first.trace.confidence);
          expect(t.presentTier, first.trace.presentTier);
          expect(t.presentTier, TrustTier.t1.name);
          expect(t.requiredTier, first.trace.requiredTier);
          expect(t.matchedTranscript, first.trace.matchedTranscript);
          expect(t.speaker?['displayName'], 'Alice');
        }

        final a = await latestApproval('add_to_list');
        await Approval.db.updateRow(
          session,
          a.copyWith(
            status: ApprovalStatus.approved,
            decidedAt: DateTime.now().toUtc(),
          ),
        );
        final done = await McpGuard.handleToolCall(
          session,
          householdId: household.id!,
          toolName: 'add_to_list',
          args: args,
          requestState: state,
        );
        expect(done, isA<McpGuardSuccess>());
        expect(done.trace.decision, 'approved');
        expect(done.trace.attestationMatched, isFalse);
        expect(done.trace.presentTier, TrustTier.t1.name);
        expect(done.trace.confidence, first.trace.confidence);
      });

      test('exact-match retry reports attestationMatched=true', () async {
        await issueAttestation(
          memberId: owner.id!,
          tier: TrustTier.t1,
          transcript: 'unlock the front door',
        );
        const args = {'utterance': 'unlock the front door'};
        final first = await McpGuard.handleToolCall(
          session,
          householdId: household.id!,
          toolName: 'unlock_front_door',
          args: args,
        );
        final retry = await McpGuard.handleToolCall(
          session,
          householdId: household.id!,
          toolName: 'unlock_front_door',
          args: args,
          requestState: (first as McpGuardInputRequired).requestState,
        );
        expect(retry.trace.attestationMatched, isTrue);
        expect(retry.trace.presentTier, TrustTier.t1.name);
        expect(retry.trace.confidence, closeTo(0.95, 1e-9));
      });
    });

    group('paraphrased command (near-miss attestation)', () {
      test(
        'T1 tool with a paraphrased utterance steps up instead of allowing',
        () async {
          await issueAttestation(
            memberId: owner.id!,
            tier: TrustTier.t1,
            transcript: 'add milk to the shopping list',
          );

          final outcome = await McpGuard.handleToolCall(
            session,
            householdId: household.id!,
            toolName: 'add_to_list',
            args: const {
              'utterance': 'add milk to my shopping list',
              'item': 'milk',
            },
          );

          expect(outcome, isA<McpGuardInputRequired>());
          expect(outcome.trace.decision, 'stepUp');
          expect(outcome.trace.reason, contains('paraphrased'));
          expect(outcome.trace.attestationMatched, isFalse);
          expect(
            outcome.trace.matchedTranscript,
            'add milk to the shopping list',
          );

          final pendingRows = await Approval.db.find(
            session,
            where: (t) =>
                t.householdId.equals(household.id!) &
                t.action.equals('add_to_list'),
            orderBy: (t) => t.createdAt.desc(),
            limit: 1,
          );
          expect(pendingRows, isNotEmpty);
        },
      );

      test(
        'T0 tool with a paraphrased utterance is still allowed outright',
        () async {
          await issueAttestation(
            memberId: owner.id!,
            tier: TrustTier.t0,
            transcript: "what's the weather in Berlin",
          );

          final outcome = await McpGuard.handleToolCall(
            session,
            householdId: household.id!,
            toolName: 'get_weather',
            args: const {'utterance': 'tell me the weather in Berlin'},
          );

          expect(outcome, isA<McpGuardSuccess>());
          expect(outcome.trace.decision, 'allow');
        },
      );

      test(
        'paraphrase with a different amount is treated as unknown speaker '
        'and denied',
        () async {
          await issueAttestation(
            memberId: owner.id!,
            tier: TrustTier.t2,
            transcript: 'order the new playstation for 500 euros',
          );

          final outcome = await McpGuard.handleToolCall(
            session,
            householdId: household.id!,
            toolName: 'place_order',
            args: const {
              'utterance': 'buy the new playstation for 50 euros',
              'item': 'playstation',
              'amount': 50,
              'currency': 'EUR',
            },
          );

          expect(outcome, isA<McpGuardToolError>());
          expect(outcome.trace.speaker, isNull);
          expect(outcome.trace.attestationMatched, isFalse);
        },
      );

      test(
        'the near-miss attestation is consumed: a replay is denied',
        () async {
          await issueAttestation(
            memberId: owner.id!,
            tier: TrustTier.t1,
            transcript: 'add milk to the shopping list',
          );

          final first = await McpGuard.handleToolCall(
            session,
            householdId: household.id!,
            toolName: 'add_to_list',
            args: const {
              'utterance': 'add milk to my shopping list',
              'item': 'milk',
            },
          );
          expect(first, isA<McpGuardInputRequired>());

          final second = await McpGuard.handleToolCall(
            session,
            householdId: household.id!,
            toolName: 'add_to_list',
            args: const {
              'utterance': 'add milk to my shopping list',
              'item': 'milk',
            },
          );
          expect(second, isA<McpGuardToolError>());
          expect(second.trace.speaker, isNull);
        },
      );

      test(
        "a member deny rule still applies to a near-miss speaker (child's "
        'place_order deny)',
        () async {
          await issueAttestation(
            memberId: child.id!,
            tier: TrustTier.t2,
            transcript: 'order the new playstation for 500 euros',
          );

          final outcome = await McpGuard.handleToolCall(
            session,
            householdId: household.id!,
            toolName: 'place_order',
            args: const {
              'utterance': 'buy the new playstation for 500 euros',
              'item': 'playstation',
              'amount': 500,
              'currency': 'EUR',
            },
          );

          expect(outcome, isA<McpGuardToolError>());
          expect(outcome.trace.decision, 'deny');
          expect(outcome.trace.speaker?['memberId'], child.id);
        },
      );

      test(
        'strict (non-paraphrased) match still allows exactly as before',
        () async {
          await issueAttestation(
            memberId: owner.id!,
            tier: TrustTier.t1,
            transcript: 'add milk to the shopping list',
          );

          final outcome = await McpGuard.handleToolCall(
            session,
            householdId: household.id!,
            toolName: 'add_to_list',
            args: const {
              'utterance': 'add milk to the shopping list',
              'item': 'milk',
            },
          );

          expect(outcome, isA<McpGuardSuccess>());
          expect(outcome.trace.decision, 'allow');
          expect(outcome.trace.attestationMatched, isTrue);
        },
      );
    });

    test(
      'step-up approval records the consumed attestation confidence',
      () async {
        await issueAttestation(
          memberId: owner.id!,
          tier: TrustTier.t1,
          transcript: 'unlock the front door',
        );

        final outcome = await McpGuard.handleToolCall(
          session,
          householdId: household.id!,
          toolName: 'unlock_front_door',
          args: const {'utterance': 'unlock the front door'},
        );
        expect(outcome, isA<McpGuardInputRequired>());

        final pendingRows = await Approval.db.find(
          session,
          where: (t) =>
              t.householdId.equals(household.id!) &
              t.action.equals('unlock_front_door'),
          orderBy: (t) => t.createdAt.desc(),
          limit: 1,
        );
        expect(pendingRows, isNotEmpty);
        expect(pendingRows.first.speakerConfidence, closeTo(0.95, 0.0001));
      },
    );
  });

  withServerpod('Given a household with an McpClient token', (
    sessionBuilder,
    endpoints,
  ) {
    var session = sessionBuilder.build();

    test(
      'bad/missing bearer token does not resolve to any household',
      () async {
        final household = await Household.db.insertRow(
          session,
          Household(name: 'Bearer Test', createdAt: DateTime.now().toUtc()),
        );
        await McpClient.db.insertRow(
          session,
          McpClient(
            householdId: household.id!,
            tokenHash: sha256Hex('a-real-token'),
            label: 'test client',
            createdAt: DateTime.now().toUtc(),
            revoked: false,
          ),
        );

        // The exact 401 path lives in McpRoute.handleCall (needs a live
        // Relic Request to exercise end-to-end); this test covers the
        // lookup logic the route delegates to: a wrong or revoked token
        // hash must never resolve to a household.
        final wrongToken = await McpClient.db.findFirstRow(
          session,
          where: (t) =>
              t.tokenHash.equals(sha256Hex('wrong-token')) &
              t.revoked.equals(false),
        );
        expect(wrongToken, isNull);

        await McpClient.db.updateRow(
          session,
          (await McpClient.db.findFirstRow(
            session,
            where: (t) => t.tokenHash.equals(sha256Hex('a-real-token')),
          ))!.copyWith(revoked: true),
        );
        final revokedLookup = await McpClient.db.findFirstRow(
          session,
          where: (t) =>
              t.tokenHash.equals(sha256Hex('a-real-token')) &
              t.revoked.equals(false),
        );
        expect(revokedLookup, isNull);
      },
    );
  });
}

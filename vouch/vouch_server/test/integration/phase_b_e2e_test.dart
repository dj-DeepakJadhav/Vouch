import 'package:test/test.dart';
import 'package:vouch_server/src/approval/approval_endpoint.dart';
import 'package:vouch_server/src/dev/dev_endpoint.dart';
import 'package:vouch_server/src/generated/protocol.dart';
import 'package:vouch_server/src/mcp/mcp_guard.dart';
import 'package:vouch_server/src/mcp/request_state.dart';

import 'test_tools/serverpod_test_tools.dart';

/// Phase B "done-when" integration test: exercises the full attestation +
/// policy + step-up-approval guard end to end against a seeded demo
/// household (DevEndpoint.seedDemoHousehold), signing real attestations
/// with a real Ed25519 hub key (DevEndpoint.issueTestAttestation) — no
/// mocking of the crypto or policy layers.
void main() {
  withServerpod('Given a seeded demo household', (sessionBuilder, endpoints) {
    var session = sessionBuilder.build();
    final dev = DevEndpoint();

    late DemoSeed seed;

    setUp(() async {
      seed = await dev.seedDemoHousehold(
        session,
        'Phase B Owner',
        'Phase B Child',
        'cGxhY2Vob2xkZXIta2V5', // overwritten by issueTestAttestation
      );
    });

    Future<List<AuditEvent>> auditRowsFor(String action) async {
      final rows = await AuditEvent.db.find(
        session,
        where: (t) =>
            t.householdId.equals(seed.householdId) & t.action.equals(action),
      );
      // Sort ascending by id (insertion order) rather than createdAt, since
      // several rows in a single test can share the same millisecond.
      rows.sort((a, b) => a.id!.compareTo(b.id!));
      return rows;
    }

    test(
      '(a) child attestation + place_order via McpGuard is denied',
      () async {
        const utterance = 'order some candy';
        await dev.issueTestAttestation(
          session,
          seed.hubId,
          seed.childMemberId,
          't2',
          utterance,
        );

        final outcome = await McpGuard.handleToolCall(
          session,
          householdId: seed.householdId,
          toolName: 'place_order',
          args: const {
            'utterance': utterance,
            'item': 'candy',
            'amount': 3,
            'currency': 'USD',
          },
        );
        expect(outcome, isA<McpGuardToolError>());

        final rows = await auditRowsFor('place_order');
        expect(rows, hasLength(1));
        expect(rows.single.eventType, 'mcp.tool_call');
        expect(rows.single.decision, AuditDecision.denied);
        expect(rows.single.memberId, seed.childMemberId);
      },
    );

    test(
      '(b) owner attestation + unlock_front_door steps up, is approved, '
      'succeeds once, and a replay is denied',
      () async {
        const utterance = 'unlock the front door';
        await dev.issueTestAttestation(
          session,
          seed.hubId,
          seed.ownerMemberId,
          't1',
          utterance,
        );

        final stepUpOutcome = await McpGuard.handleToolCall(
          session,
          householdId: seed.householdId,
          toolName: 'unlock_front_door',
          args: const {'utterance': utterance},
        );
        expect(stepUpOutcome, isA<McpGuardInputRequired>());
        final requestState =
            (stepUpOutcome as McpGuardInputRequired).requestState;

        final payload = RequestStateCodec.decodeAndVerify(
          session,
          requestState,
        )!;
        final approved = await ApprovalEndpoint.decideInternal(
          session,
          approvalId: payload.approvalId,
          approve: true,
        );
        expect(approved!.status, ApprovalStatus.approved);

        final firstRetry = await McpGuard.handleToolCall(
          session,
          householdId: seed.householdId,
          toolName: 'unlock_front_door',
          args: const {'utterance': utterance},
          requestState: requestState,
        );
        expect(firstRetry, isA<McpGuardSuccess>());

        final replay = await McpGuard.handleToolCall(
          session,
          householdId: seed.householdId,
          toolName: 'unlock_front_door',
          args: const {'utterance': utterance},
          requestState: requestState,
        );
        expect(replay, isA<McpGuardToolError>());

        final rows = await auditRowsFor('unlock_front_door');
        expect(rows, hasLength(4));
        expect(rows[0].decision, AuditDecision.challenged);
        expect(rows[0].memberId, seed.ownerMemberId);
        expect(rows[1].eventType, 'approval.decide');
        expect(rows[1].decision, AuditDecision.permitted);
        expect(rows[2].decision, AuditDecision.permitted);
        expect(rows[2].memberId, seed.ownerMemberId);
        expect(rows[3].decision, AuditDecision.denied);
        expect(rows[3].memberId, seed.ownerMemberId);
      },
    );

    test('(c) no attestation + get_weather is allowed', () async {
      final outcome = await McpGuard.handleToolCall(
        session,
        householdId: seed.householdId,
        toolName: 'get_weather',
        args: const {'utterance': "what's the weather"},
      );
      expect(outcome, isA<McpGuardSuccess>());

      final rows = await auditRowsFor('get_weather');
      expect(rows, hasLength(1));
      expect(rows.single.decision, AuditDecision.permitted);
      expect(rows.single.memberId, isNull);
    });

    test('(d) no attestation + add_to_list is denied', () async {
      final outcome = await McpGuard.handleToolCall(
        session,
        householdId: seed.householdId,
        toolName: 'add_to_list',
        args: const {'utterance': 'add milk to the list', 'item': 'milk'},
      );
      expect(outcome, isA<McpGuardToolError>());

      final rows = await auditRowsFor('add_to_list');
      expect(rows, hasLength(1));
      expect(rows.single.decision, AuditDecision.denied);
      expect(rows.single.memberId, isNull);
    });
  });
}

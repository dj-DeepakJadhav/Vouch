import 'package:test/test.dart';
import 'package:vouch_server/src/approval/approval_endpoint.dart';
import 'package:vouch_server/src/dev/dev_endpoint.dart';
import 'package:vouch_server/src/generated/protocol.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given the DevEndpoint', (sessionBuilder, endpoints) {
    var session = sessionBuilder.build();

    test('demoAvailable is true in the test run mode', () async {
      expect(await DevEndpoint().demoAvailable(session), isTrue);
    });

    test(
      'seedDemoHousehold creates a fully-formed demo household',
      () async {
        final dev = DevEndpoint();
        final seed = await dev.seedDemoHousehold(
          session,
          'Dev Owner',
          'Dev Child',
          'dGVzdC1wdWJsaWMta2V5',
        );

        expect(seed.householdId, isPositive);
        expect(seed.hubId, isPositive);
        expect(seed.ownerMemberId, isPositive);
        expect(seed.childMemberId, isPositive);
        expect(seed.mcpToken, isNotEmpty);

        final owner = await Member.db.findById(session, seed.ownerMemberId);
        expect(owner, isNotNull);
        expect(owner!.role, MemberRole.owner);

        final child = await Member.db.findById(session, seed.childMemberId);
        expect(child, isNotNull);
        expect(child!.role, MemberRole.child);

        final rules = await PolicyRule.db.find(
          session,
          where: (t) => t.householdId.equals(seed.householdId),
        );
        expect(rules, isNotEmpty);
        final childDeny = rules.where(
          (r) =>
              r.role == MemberRole.child &&
              r.memberId == null &&
              r.actionPattern == 'place_*' &&
              r.effect == PolicyEffect.deny,
        );
        expect(childDeny, hasLength(1));

        final client = await McpClient.db.findFirstRow(
          session,
          where: (t) => t.householdId.equals(seed.householdId),
        );
        expect(client, isNotNull);
        expect(client!.tokenHash, isNot(equals(seed.mcpToken)));
      },
    );

    test(
      'approveAsOwner approves through the same code path as a real decide',
      () async {
        final dev = DevEndpoint();
        final seed = await dev.seedDemoHousehold(
          session,
          'Owner2',
          'Child2',
          'YW5vdGhlci1rZXk=',
        );

        final now = DateTime.now().toUtc();
        final approval = await Approval.db.insertRow(
          session,
          Approval(
            householdId: seed.householdId,
            memberId: seed.ownerMemberId,
            action: 'place_order',
            argsJson: '{}',
            utterance: 'order more paper towels',
            status: ApprovalStatus.pending,
            used: false,
            createdAt: now,
            expiresAt: now.add(const Duration(seconds: 60)),
          ),
        );

        final decided = await dev.approveAsOwner(session, approval.id!);
        expect(decided, isNotNull);
        expect(decided!.status, ApprovalStatus.approved);

        // Re-fetch to confirm persisted.
        final reloaded = await Approval.db.findById(session, approval.id!);
        expect(reloaded!.status, ApprovalStatus.approved);
      },
    );
  });

  withServerpod(
    'Given owner-only approval authorization (no login helpers wired here)',
    (sessionBuilder, endpoints) {
      var session = sessionBuilder.build();

      test(
        'ApprovalEndpoint.decideInternal is unauthenticated by design',
        () async {
          // decideInternal is the shared, unauthenticated code path used by
          // both the real (auth-checked) ApprovalEndpoint.decide and the
          // dev-only DevEndpoint.approveAsOwner. This test just documents
          // that it performs the state transition without checking who is
          // calling — the authorization boundary lives one layer up.
          final household = await Household.db.insertRow(
            session,
            Household(
              name: 'Auth Boundary Test',
              createdAt: DateTime.now().toUtc(),
            ),
          );
          final now = DateTime.now().toUtc();
          final approval = await Approval.db.insertRow(
            session,
            Approval(
              householdId: household.id!,
              action: 'send_message',
              argsJson: '{}',
              utterance: 'send a message',
              status: ApprovalStatus.pending,
              used: false,
              createdAt: now,
              expiresAt: now.add(const Duration(seconds: 60)),
            ),
          );

          final decided = await ApprovalEndpoint.decideInternal(
            session,
            approvalId: approval.id!,
            approve: false,
          );
          expect(decided!.status, ApprovalStatus.denied);
        },
      );
    },
  );
}

import 'package:test/test.dart';
import 'package:vouch_server/src/approval/approval_endpoint.dart';
import 'package:vouch_server/src/audit/audit_service.dart';
import 'package:vouch_server/src/generated/protocol.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  // A subscribed stream keeps the server-side session alive for the whole
  // test, so appending an audit event from a second, concurrent session
  // (to trigger the publish under test) needs real concurrent DB access —
  // not supported inside the default single rolled-back transaction. See
  // the serverpod-testing skill's "Rollback behavior" section.
  withServerpod(
    'Given a household with an owner and a child',
    (sessionBuilder, endpoints) {
      var session = sessionBuilder.build();

      late Household household;
      late Member owner;

      const ownerAuthUserId = '55555555-5555-5555-5555-555555555555';
      const childAuthUserId = '66666666-6666-6666-6666-666666666666';

      setUp(() async {
        household = await Household.db.insertRow(
          session,
          Household(
            name: 'Household Status Test',
            createdAt: DateTime.now().toUtc(),
          ),
        );
        owner = await Member.db.insertRow(
          session,
          Member(
            householdId: household.id!,
            displayName: 'Owner',
            role: MemberRole.owner,
            status: MemberStatus.active,
            authUserId: ownerAuthUserId,
          ),
        );
        await Member.db.insertRow(
          session,
          Member(
            householdId: household.id!,
            displayName: 'Child',
            role: MemberRole.child,
            status: MemberStatus.active,
            authUserId: childAuthUserId,
          ),
        );
      });

      test(
        'owner subscribed to householdStatus receives an event from AuditService.append',
        () async {
          final ownerSession = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              ownerAuthUserId,
              {},
            ),
          );

          final stream = endpoints.household.householdStatus(
            ownerSession,
            household.id!,
          );
          // `stream` is an async* generator: nothing runs until something
          // listens. Grab the `.first` future (which subscribes
          // immediately) before posting, so the message channel is
          // guaranteed to be listening before AuditService.append
          // publishes to it. Posting first and listening afterwards is a
          // race: under load the append can complete — and the message be
          // dropped — before createStream's subscription is attached,
          // which then hangs `stream.first` for the full 30s test timeout.
          final eventFuture = stream.first;
          await flushEventQueue(); // let the stream subscribe to the channel

          await AuditService.append(
            session,
            householdId: household.id!,
            memberId: owner.id,
            eventType: 'mcp.tool_call',
            action: 'get_weather',
            decision: AuditDecision.permitted,
            reason: 'test event',
          );

          final event = await eventFuture;
          expect(event.householdId, household.id);
          expect(event.kind, HouseholdEventKind.decision);
          expect(event.action, 'get_weather');
          expect(event.memberId, owner.id);
          expect(event.decision, AuditDecision.permitted);
        },
      );

      test(
        'a non-owner is rejected when subscribing to householdStatus',
        () async {
          final childSession = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              childAuthUserId,
              {},
            ),
          );

          await expectLater(
            endpoints.household
                .householdStatus(childSession, household.id!)
                .first,
            throwsA(isA<NotHouseholdOwnerException>()),
          );
        },
      );

      test(
        'an unauthenticated caller is rejected when subscribing to householdStatus',
        () async {
          await expectLater(
            endpoints.household
                .householdStatus(sessionBuilder, household.id!)
                .first,
            throwsA(anything),
          );
        },
      );
    },
    rollbackDatabase: RollbackDatabase.disabled,
  );
}

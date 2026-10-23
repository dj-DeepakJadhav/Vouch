import 'package:test/test.dart';
import 'package:vouch_server/src/approval/approval_endpoint.dart';
import 'package:vouch_server/src/audit/audit_service.dart';
import 'package:vouch_server/src/generated/protocol.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given a household with recorded audit events', (
    sessionBuilder,
    endpoints,
  ) {
    var session = sessionBuilder.build();
    late Household household;
    const ownerAuthUserId = '99999999-9999-9999-9999-999999999999';
    const otherAuthUserId = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';

    ownerSession() => sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        ownerAuthUserId,
        {},
      ),
    );
    otherSession() => sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        otherAuthUserId,
        {},
      ),
    );

    setUp(() async {
      household = await Household.db.insertRow(
        session,
        Household(name: 'Test Household', createdAt: DateTime.now().toUtc()),
      );
      await Member.db.insertRow(
        session,
        Member(
          householdId: household.id!,
          displayName: 'Owner',
          role: MemberRole.owner,
          status: MemberStatus.active,
          authUserId: ownerAuthUserId,
        ),
      );

      for (var i = 0; i < 3; i++) {
        await AuditService.append(
          session,
          householdId: household.id!,
          eventType: 'policy.check',
          action: 'get_weather',
          decision: AuditDecision.permitted,
          reason: 'default tier t0 applied',
          createdAt: DateTime.now().toUtc().add(Duration(seconds: i)),
        );
      }
    });

    test(
      'when listing recent events then they are returned newest first',
      () async {
        final events = await endpoints.audit.listRecent(
          sessionBuilder,
          household.id!,
          page: 0,
          pageSize: 25,
        );

        expect(events, hasLength(3));
        expect(
          events[0].createdAt.isAfter(events[1].createdAt) ||
              events[0].createdAt.isAtSameMomentAs(events[1].createdAt),
          isTrue,
        );
      },
    );

    test('when appending an event then it is persisted with an id', () async {
      final event = await AuditService.append(
        session,
        householdId: household.id!,
        eventType: 'policy.check',
        action: 'place_order',
        decision: AuditDecision.challenged,
        tierRequired: TrustTier.t2,
        tierPresent: TrustTier.t1,
        reason: 'step-up required',
      );

      expect(event.id, isNotNull);
    });

    test(
      'when the owner exports since an early cutoff then all seeded events '
      'are returned oldest first',
      () async {
        final events = await endpoints.audit.exportSince(
          ownerSession(),
          household.id!,
          DateTime.now().toUtc().subtract(const Duration(days: 1)),
        );

        expect(events, hasLength(3));
        expect(
          events[0].createdAt.isBefore(events[1].createdAt) ||
              events[0].createdAt.isAtSameMomentAs(events[1].createdAt),
          isTrue,
        );
      },
    );

    test(
      'when exporting since a cutoff after all events then none are returned',
      () async {
        final events = await endpoints.audit.exportSince(
          ownerSession(),
          household.id!,
          DateTime.now().toUtc().add(const Duration(days: 1)),
        );

        expect(events, isEmpty);
      },
    );

    test('when a non-owner calls exportSince then it is rejected', () async {
      await expectLater(
        endpoints.audit.exportSince(
          otherSession(),
          household.id!,
          DateTime.now().toUtc().subtract(const Duration(days: 1)),
        ),
        throwsA(isA<NotHouseholdOwnerException>()),
      );
    });
  });
}

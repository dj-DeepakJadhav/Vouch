import 'dart:io';

import 'package:test/test.dart';
import 'package:vouch_server/src/attestation/attestation_service.dart';
import 'package:vouch_server/src/demo/demo_endpoint.dart';
import 'package:vouch_server/src/generated/protocol.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given the DemoEndpoint', (sessionBuilder, endpoints) {
    TestSessionBuilder as(String user) => sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(user, {}),
    );
    final alice = as('demo-alice');
    final bob = as('demo-bob');
    final db = sessionBuilder.build();

    setUp(() {
      DemoMode.overrideForTesting = true;
      DemoMode.maxPerHour = 30;
      DemoMode.maxTotal = 2000;
    });
    tearDown(() => DemoMode.overrideForTesting = null);

    Matcher refused(String code) =>
        throwsA(isA<DemoRefused>().having((e) => e.code, 'code', code));

    test('available reflects the flag', () async {
      expect(await endpoints.demo.available(sessionBuilder), isTrue);
      DemoMode.overrideForTesting = false;
      expect(await endpoints.demo.available(sessionBuilder), isFalse);
    });

    test('flag off: start, attest and mintMcpToken all refuse', () async {
      final s = await endpoints.demo.start(alice);
      DemoMode.overrideForTesting = false;
      await expectLater(endpoints.demo.start(alice), refused('demo_off'));
      await expectLater(
        endpoints.demo.attest(alice, s.ownerMemberId, 'hello'),
        refused('demo_off'),
      );
      await expectLater(
        endpoints.demo.mintMcpToken(alice),
        refused('demo_off'),
      );
    });

    test('start requires sign-in', () async {
      await expectLater(
        endpoints.demo.start(
          sessionBuilder.copyWith(
            authentication: AuthenticationOverride.unauthenticated(),
          ),
        ),
        refused('not_signed_in'),
      );
    });

    test('start builds an isolated household and is idempotent', () async {
      final a1 = await endpoints.demo.start(alice);
      final a2 = await endpoints.demo.start(alice);
      final b = await endpoints.demo.start(bob);
      expect(a2.householdId, a1.householdId);
      expect(a2.hubId, a1.hubId);
      expect(b.householdId, isNot(a1.householdId));
      expect(
        await DemoHousehold.db.count(
          db,
          where: (t) => t.ownerAuthUserId.equals('demo-alice'),
        ),
        1,
      );

      final owner = await Member.db.findById(db, a1.ownerMemberId);
      expect(owner!.authUserId, 'demo-alice');
      expect(owner.role, MemberRole.owner);
      final child = await Member.db.findById(db, a1.childMemberId);
      expect(child!.role, MemberRole.child);
      final hub = await Hub.db.findById(db, a1.hubId);
      expect(hub!.version, DemoEndpoint.demoHubVersion);
      final rules = await PolicyRule.db.find(
        db,
        where: (t) => t.householdId.equals(a1.householdId),
      );
      expect(
        rules.where(
          (r) =>
              r.role == MemberRole.child &&
              r.actionPattern == 'place_*' &&
              r.effect == PolicyEffect.deny,
        ),
        hasLength(1),
      );
      // The owner's normal app path resolves to this household.
      expect(await endpoints.household.hasHousehold(alice), isTrue);
      final overview = await endpoints.household.myHousehold(alice);
      expect(overview.household.id, a1.householdId);
      // Audited like any other action.
      final audit = await AuditEvent.db.find(
        db,
        where: (t) =>
            t.householdId.equals(a1.householdId) &
            t.eventType.equals('demo.start'),
      );
      expect(audit, hasLength(1));
    });

    test('a caller already linked to a real household is refused', () async {
      final h = await Household.db.insertRow(
        db,
        Household(name: 'real', createdAt: DateTime.now().toUtc()),
      );
      await Member.db.insertRow(
        db,
        Member(
          householdId: h.id!,
          displayName: 'Real Owner',
          role: MemberRole.owner,
          status: MemberStatus.active,
          authUserId: 'real-owner',
        ),
      );
      await expectLater(
        endpoints.demo.start(as('real-owner')),
        refused('caller_already_linked'),
      );
    });

    test('hourly rate limit and total cap stop new households', () async {
      DemoMode.maxPerHour = 1;
      await endpoints.demo.start(alice);
      await expectLater(endpoints.demo.start(bob), refused('rate_limited'));
      // The existing caller is still served (idempotent, no new row).
      await endpoints.demo.start(alice);

      DemoMode.maxPerHour = 30;
      DemoMode.maxTotal = 1;
      await expectLater(
        endpoints.demo.start(bob),
        refused('demo_capacity_reached'),
      );
    });

    test('the hub private key never leaves the server', () async {
      final s = await endpoints.demo.start(alice);
      final json = s.toJson();
      expect(json.keys, isNot(contains('hubPrivateKeySeed')));
      final row = await DemoHousehold.db.findFirstRow(
        db,
        where: (t) => t.householdId.equals(s.householdId),
      );
      expect(json.values, isNot(contains(row!.hubPrivateKeySeed)));
      // DemoHousehold is serverOnly: absent from the generated client.
      final clientProtocol = File(
        '../vouch_client/lib/src/protocol/protocol.dart',
      ).readAsStringSync();
      expect(clientProtocol, isNot(contains('DemoHousehold')));
    });

    test(
      'attest verifies through AttestationService and keeps the hub key',
      () async {
        final s = await endpoints.demo.start(alice);
        final keyBefore = (await Hub.db.findById(db, s.hubId))!.publicKey;

        final att = await endpoints.demo.attest(
          alice,
          s.childMemberId,
          'turn on the lights',
        );
        expect(att.memberId, s.childMemberId);
        expect(att.tier, TrustTier.t1);
        expect(att.transcriptNormalised, 'turn on the lights');
        expect((await Hub.db.findById(db, s.hubId))!.publicKey, keyBefore);
        final accepted = await AuditEvent.db.find(
          db,
          where: (t) =>
              t.householdId.equals(s.householdId) &
              t.eventType.equals('attestation.submit') &
              t.decision.equals(AuditDecision.permitted),
        );
        expect(accepted, hasLength(1));

        // Proof the signature is really checked: if the stored public key is
        // not the demo key, the same call is rejected by the normal path.
        final other = await endpoints.demo.start(bob);
        final otherKey = (await Hub.db.findById(db, other.hubId))!.publicKey;
        final hub = (await Hub.db.findById(db, s.hubId))!;
        await Hub.db.updateRow(db, hub.copyWith(publicKey: 'x$otherKey'));
        await expectLater(
          endpoints.demo.attest(alice, s.ownerMemberId, 'hello'),
          throwsA(
            isA<AttestationRejected>().having(
              (e) => e.reason,
              'reason',
              'invalid_signature',
            ),
          ),
        );
      },
    );

    test('attest rejects a member of another household', () async {
      await endpoints.demo.start(alice);
      final b = await endpoints.demo.start(bob);
      await expectLater(
        endpoints.demo.attest(alice, b.childMemberId, 'hello'),
        refused('member_not_in_household'),
      );
      await expectLater(
        endpoints.demo.attest(alice, 999999999, 'hello'),
        refused('member_not_in_household'),
      );
    });

    test('attest and mint refuse a non-demo household owner', () async {
      final h = await Household.db.insertRow(
        db,
        Household(name: 'real', createdAt: DateTime.now().toUtc()),
      );
      final owner = await Member.db.insertRow(
        db,
        Member(
          householdId: h.id!,
          displayName: 'Real Owner',
          role: MemberRole.owner,
          status: MemberStatus.active,
          authUserId: 'real-owner-2',
        ),
      );
      final real = as('real-owner-2');
      await expectLater(
        endpoints.demo.attest(real, owner.id!, 'hello'),
        refused('not_a_demo_household'),
      );
      await expectLater(
        endpoints.demo.mintMcpToken(real),
        refused('not_a_demo_household'),
      );
    });

    test(
      'a signed-in caller with no household cannot attest or mint',
      () async {
        final nobody = as('demo-nobody');
        await expectLater(
          endpoints.demo.attest(nobody, 1, 'hello'),
          throwsA(anything),
        );
        await expectLater(
          endpoints.demo.mintMcpToken(nobody),
          throwsA(anything),
        );
        expect(await endpoints.household.hasHousehold(nobody), isFalse);
      },
    );

    test('mintMcpToken stores only a hash for the caller household', () async {
      final s = await endpoints.demo.start(alice);
      final token = await endpoints.demo.mintMcpToken(alice);
      final clients = await McpClient.db.find(
        db,
        where: (t) => t.householdId.equals(s.householdId),
      );
      expect(clients, hasLength(1));
      expect(clients.single.tokenHash, isNot(token));
    });
  });
}

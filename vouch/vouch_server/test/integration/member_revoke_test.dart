import 'package:test/test.dart';
import 'package:vouch_server/src/approval/approval_endpoint.dart';
import 'package:vouch_server/src/attestation/attestation_service.dart';
import 'package:vouch_server/src/attestation/attestation_signature.dart';
import 'package:vouch_server/src/attestation/transcript_matcher.dart';
import 'package:vouch_server/src/household/household_endpoint.dart';
import 'package:vouch_server/src/generated/protocol.dart';

import 'test_tools/serverpod_test_tools.dart';

/// The "live revoke" demo beat: the owner revokes a member's voice trust,
/// and the very next attestation for that member is rejected outright (not
/// just their currently-live attestations) — see
/// HouseholdEndpoint.revokeMember's doc comment for why both halves matter.
void main() {
  withServerpod(
    'Given a household with an owner and a child',
    (sessionBuilder, endpoints) {
      var session = sessionBuilder.build();

      late Household household;
      late Member owner;
      late Member child;
      late Hub hub;

      const ownerAuthUserId = '77777777-7777-7777-7777-777777777777';
      const childAuthUserId = '88888888-8888-8888-8888-888888888888';
      const otherAuthUserId = '99999999-9999-9999-9999-999999999999';

      setUp(() async {
        household = await Household.db.insertRow(
          session,
          Household(
            name: 'Revoke Demo Household',
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
        child = await Member.db.insertRow(
          session,
          Member(
            householdId: household.id!,
            displayName: 'Child',
            role: MemberRole.child,
            status: MemberStatus.active,
            authUserId: childAuthUserId,
          ),
        );
        // Another household's owner, to prove non-owners (and owners of
        // other households) cannot revoke this member.
        final otherHousehold = await Household.db.insertRow(
          session,
          Household(name: 'Other Household', createdAt: DateTime.now().toUtc()),
        );
        await Member.db.insertRow(
          session,
          Member(
            householdId: otherHousehold.id!,
            displayName: 'Other Owner',
            role: MemberRole.owner,
            status: MemberStatus.active,
            authUserId: otherAuthUserId,
          ),
        );
      });

      TestSessionBuilder ownerSession() => sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          ownerAuthUserId,
          {},
        ),
      );

      test(
        'when the owner revokes the child then the child is marked revoked '
        'and an audit event is written',
        () async {
          final updated = await endpoints.household.revokeMember(
            ownerSession(),
            child.id!,
          );

          expect(updated.status, MemberStatus.revoked);

          final reloaded = await Member.db.findById(session, child.id!);
          expect(reloaded!.status, MemberStatus.revoked);

          final events = await AuditEvent.db.find(
            session,
            where: (t) => t.eventType.equals('member.revoke'),
          );
          expect(events, hasLength(1));
          expect(events.single.memberId, child.id);
          expect(events.single.householdId, household.id);
          expect(events.single.reason, contains('revoked'));
        },
      );

      test(
        'when the owner revokes the child then a subsequent attestation for '
        'the child is rejected as not eligible',
        () async {
          await endpoints.household.revokeMember(ownerSession(), child.id!);

          // A genuine, correctly signed attestation from a real registered
          // hub — so this test proves the member-eligibility check itself
          // rejects it, not merely a bad signature.
          final probe = await AttestationSignature.signForTest('probe');
          hub = await Hub.db.insertRow(
            session,
            Hub(
              householdId: household.id!,
              publicKey: probe.publicKeyBase64,
              version: '0.0.0-test',
            ),
          );

          const transcriptNormalised = 'turn on the lights';
          final capturedAt = DateTime.now().toUtc();
          final payload = AttestationSignature.canonicalPayload(
            hubId: hub.id!,
            memberId: child.id!,
            tier: TrustTier.t1.name,
            confidence: 0.95,
            spoofRisk: SpoofRisk.low.name,
            transcriptHash: TranscriptMatcher.hash(transcriptNormalised),
            capturedAt: capturedAt,
          );
          final signed = await AttestationSignature.signForTest(
            payload,
            keyPair: probe.keyPair,
          );

          await expectLater(
            AttestationService.submit(
              session,
              hubId: hub.id!,
              memberId: child.id!,
              tier: TrustTier.t1,
              confidence: 0.95,
              spoofRisk: SpoofRisk.low,
              transcriptNormalised: transcriptNormalised,
              capturedAt: capturedAt,
              signatureBase64: signed.signatureBase64,
            ),
            throwsA(
              isA<AttestationRejected>().having(
                (e) => e.reason,
                'reason',
                'member_not_eligible',
              ),
            ),
          );
        },
      );

      test(
        'when the owner restores a previously revoked child then the child '
        'is active again and an audit event is written',
        () async {
          await endpoints.household.revokeMember(ownerSession(), child.id!);

          final restored = await endpoints.household.restoreMember(
            ownerSession(),
            child.id!,
          );
          expect(restored.status, MemberStatus.active);

          final reloaded = await Member.db.findById(session, child.id!);
          expect(reloaded!.status, MemberStatus.active);

          final events = await AuditEvent.db.find(
            session,
            where: (t) => t.eventType.equals('member.restore'),
          );
          expect(events, hasLength(1));
          expect(events.single.memberId, child.id);
        },
      );

      test(
        'restore never promotes a member who has not finished enrolment',
        () async {
          await Member.db.updateRow(
            session,
            child.copyWith(status: MemberStatus.needsReenrolment),
          );

          final result = await endpoints.household.restoreMember(
            ownerSession(),
            child.id!,
          );
          expect(result.status, MemberStatus.needsReenrolment);
        },
      );

      test(
        'an unknown member id looks the same as not being the owner',
        () async {
          await expectLater(
            endpoints.household.revokeMember(ownerSession(), 999999),
            throwsA(isA<NotHouseholdOwnerException>()),
          );
        },
      );

      test('a non-owner cannot revoke a member', () async {
        final childSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            childAuthUserId,
            {},
          ),
        );

        await expectLater(
          endpoints.household.revokeMember(childSession, child.id!),
          throwsA(isA<NotHouseholdOwnerException>()),
        );
      });

      test(
        'an owner of a different household cannot revoke this member',
        () async {
          final otherOwnerSession = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              otherAuthUserId,
              {},
            ),
          );

          await expectLater(
            endpoints.household.revokeMember(otherOwnerSession, child.id!),
            throwsA(isA<NotHouseholdOwnerException>()),
          );
        },
      );

      test('the owner cannot revoke themselves', () async {
        await expectLater(
          endpoints.household.revokeMember(ownerSession(), owner.id!),
          throwsA(isA<CannotRevokeOwnerException>()),
        );
      });
    },
  );
}

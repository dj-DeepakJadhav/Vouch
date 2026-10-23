import 'package:cryptography/cryptography.dart';
import 'package:test/test.dart';
import 'package:vouch_server/src/attestation/attestation_service.dart';
import 'package:vouch_server/src/attestation/attestation_signature.dart';
import 'package:vouch_server/src/attestation/transcript_matcher.dart';
import 'package:vouch_server/src/generated/protocol.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given a household with a hub and a member', (
    sessionBuilder,
    endpoints,
  ) {
    var session = sessionBuilder.build();

    late Household household;
    late Member member;
    late Hub hub;
    late String publicKeyBase64;
    late SimpleKeyPair keyPairHandle;

    setUp(() async {
      household = await Household.db.insertRow(
        session,
        Household(name: 'Test Household', createdAt: DateTime.now().toUtc()),
      );
      member = await Member.db.insertRow(
        session,
        Member(
          householdId: household.id!,
          displayName: 'Alice',
          role: MemberRole.owner,
          status: MemberStatus.active,
        ),
      );

      // Generate a keypair via a throwaway signature so we get a public key,
      // then reuse that keypair for every signature in this group.
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
    });

    Future<Map<String, String>> buildSignedPayload({
      int? memberId,
      TrustTier tier = TrustTier.t1,
      double confidence = 0.95,
      SpoofRisk spoofRisk = SpoofRisk.low,
      required String transcriptNormalised,
      required DateTime capturedAt,
    }) async {
      final transcriptHash = TranscriptMatcher.hash(transcriptNormalised);
      final payload = AttestationSignature.canonicalPayload(
        hubId: hub.id!,
        memberId: memberId,
        tier: tier.name,
        confidence: confidence,
        spoofRisk: spoofRisk.name,
        transcriptHash: transcriptHash,
        capturedAt: capturedAt,
      );
      final signed = await AttestationSignature.signForTest(
        payload,
        keyPair: keyPairHandle,
      );
      return {'signatureBase64': signed.signatureBase64};
    }

    group('when submitting a valid attestation', () {
      test('then it is stored and readable', () async {
        final now = DateTime.now().toUtc();
        final signed = await buildSignedPayload(
          memberId: member.id!,
          transcriptNormalised: 'unlock the front door',
          capturedAt: now,
        );

        final attestation = await AttestationService.submit(
          session,
          hubId: hub.id!,
          memberId: member.id!,
          tier: TrustTier.t1,
          confidence: 0.95,
          spoofRisk: SpoofRisk.low,
          transcriptNormalised: 'unlock the front door',
          capturedAt: now,
          signatureBase64: signed['signatureBase64']!,
        );

        expect(attestation.id, isNotNull);
        expect(attestation.consumedAt, isNull);
        expect(attestation.revoked, isFalse);
      });
    });

    Future<void> expectRejectedFor(int memberId) async {
      final now = DateTime.now().toUtc();
      const text = 'unlock the front door';
      final signed = await buildSignedPayload(
        memberId: memberId,
        transcriptNormalised: text,
        capturedAt: now,
      );
      await expectLater(
        AttestationService.submit(
          session,
          hubId: hub.id!,
          memberId: memberId,
          tier: TrustTier.t2,
          confidence: 0.95,
          spoofRisk: SpoofRisk.low,
          transcriptNormalised: text,
          capturedAt: now,
          signatureBase64: signed['signatureBase64']!,
        ),
        throwsA(isA<AttestationRejected>()),
      );
    }

    group('when the hub validly signs for a member of another household', () {
      test('then it is rejected', () async {
        final otherHousehold = await Household.db.insertRow(
          session,
          Household(name: 'Other', createdAt: DateTime.now().toUtc()),
        );
        final outsider = await Member.db.insertRow(
          session,
          Member(
            householdId: otherHousehold.id!,
            displayName: 'Mallory',
            role: MemberRole.owner,
            status: MemberStatus.active,
          ),
        );
        await expectRejectedFor(outsider.id!);
      });
    });

    group('when the hub validly signs for a revoked member', () {
      test('then it is rejected', () async {
        final revoked = await Member.db.insertRow(
          session,
          Member(
            householdId: household.id!,
            displayName: 'Former flatmate',
            role: MemberRole.adult,
            status: MemberStatus.revoked,
          ),
        );
        await expectRejectedFor(revoked.id!);
      });
    });

    group('when submitting an attestation with a tampered signature', () {
      test('then it is rejected', () async {
        final now = DateTime.now().toUtc();

        await expectLater(
          AttestationService.submit(
            session,
            hubId: hub.id!,
            memberId: member.id!,
            tier: TrustTier.t1,
            confidence: 0.95,
            spoofRisk: SpoofRisk.low,
            transcriptNormalised: 'unlock the front door',
            capturedAt: now,
            signatureBase64: 'not-a-real-signature',
          ),
          throwsA(isA<AttestationRejected>()),
        );
      });
    });

    group('when submitting a stale attestation', () {
      test('then it is rejected', () async {
        final stale = DateTime.now().toUtc().subtract(
          const Duration(seconds: 10),
        );
        final signed = await buildSignedPayload(
          memberId: member.id!,
          transcriptNormalised: 'unlock the front door',
          capturedAt: stale,
        );

        await expectLater(
          AttestationService.submit(
            session,
            hubId: hub.id!,
            memberId: member.id!,
            tier: TrustTier.t1,
            confidence: 0.95,
            spoofRisk: SpoofRisk.low,
            transcriptNormalised: 'unlock the front door',
            capturedAt: stale,
            signatureBase64: signed['signatureBase64']!,
          ),
          throwsA(isA<AttestationRejected>()),
        );
      });
    });

    group('when submitting an attestation from the future', () {
      test('then it is rejected', () async {
        final future = DateTime.now().toUtc().add(
          const Duration(seconds: 5),
        );
        final signed = await buildSignedPayload(
          memberId: member.id!,
          transcriptNormalised: 'unlock the front door',
          capturedAt: future,
        );

        await expectLater(
          AttestationService.submit(
            session,
            hubId: hub.id!,
            memberId: member.id!,
            tier: TrustTier.t1,
            confidence: 0.95,
            spoofRisk: SpoofRisk.low,
            transcriptNormalised: 'unlock the front door',
            capturedAt: future,
            signatureBase64: signed['signatureBase64']!,
          ),
          throwsA(isA<AttestationRejected>()),
        );
      });
    });

    group('when a live attestation matches the spoken command', () {
      test('then consumeMatching returns it exactly once', () async {
        final now = DateTime.now().toUtc();
        final signed = await buildSignedPayload(
          memberId: member.id!,
          transcriptNormalised: 'unlock the front door',
          capturedAt: now,
        );
        await AttestationService.submit(
          session,
          hubId: hub.id!,
          memberId: member.id!,
          tier: TrustTier.t1,
          confidence: 0.95,
          spoofRisk: SpoofRisk.low,
          transcriptNormalised: 'unlock the front door',
          capturedAt: now,
          signatureBase64: signed['signatureBase64']!,
        );

        final first = await AttestationService.consumeMatching(
          session,
          householdId: household.id!,
          alexaCommandText: 'Alexa, unlock the front door',
          now: now,
        );
        expect(first, isNotNull);
        expect(first!.memberId, member.id);
        expect(first.consumedAt, isNotNull);

        final second = await AttestationService.consumeMatching(
          session,
          householdId: household.id!,
          alexaCommandText: 'Alexa, unlock the front door',
          now: now,
        );
        expect(second, isNull);
      });
    });

    group('when the matching attestation has expired', () {
      test('then consumeMatching returns null', () async {
        final now = DateTime.now().toUtc();
        final signed = await buildSignedPayload(
          memberId: member.id!,
          transcriptNormalised: 'unlock the front door',
          capturedAt: now,
        );
        await AttestationService.submit(
          session,
          hubId: hub.id!,
          memberId: member.id!,
          tier: TrustTier.t1,
          confidence: 0.95,
          spoofRisk: SpoofRisk.low,
          transcriptNormalised: 'unlock the front door',
          capturedAt: now,
          signatureBase64: signed['signatureBase64']!,
        );

        final afterExpiry = now.add(const Duration(seconds: 10));
        final result = await AttestationService.consumeMatching(
          session,
          householdId: household.id!,
          alexaCommandText: 'Alexa, unlock the front door',
          now: afterExpiry,
        );
        expect(result, isNull);
      });
    });

    group('when the matching attestation has been revoked', () {
      test('then consumeMatching returns null', () async {
        final now = DateTime.now().toUtc();
        final signed = await buildSignedPayload(
          memberId: member.id!,
          transcriptNormalised: 'unlock the front door',
          capturedAt: now,
        );
        await AttestationService.submit(
          session,
          hubId: hub.id!,
          memberId: member.id!,
          tier: TrustTier.t1,
          confidence: 0.95,
          spoofRisk: SpoofRisk.low,
          transcriptNormalised: 'unlock the front door',
          capturedAt: now,
          signatureBase64: signed['signatureBase64']!,
        );

        final revokedCount = await AttestationService.revokeForMember(
          session,
          member.id!,
        );
        expect(revokedCount, 1);

        final result = await AttestationService.consumeMatching(
          session,
          householdId: household.id!,
          alexaCommandText: 'Alexa, unlock the front door',
          now: now,
        );
        expect(result, isNull);
      });
    });

    group(
      'when the attested transcript and the spoken command have '
      'mismatched numbers',
      () {
        test('then consumeMatching does not consume it', () async {
          final now = DateTime.now().toUtc();
          final signed = await buildSignedPayload(
            memberId: member.id!,
            transcriptNormalised: 'set a timer for 10 minutes',
            capturedAt: now,
          );
          await AttestationService.submit(
            session,
            hubId: hub.id!,
            memberId: member.id!,
            tier: TrustTier.t1,
            confidence: 0.95,
            spoofRisk: SpoofRisk.low,
            transcriptNormalised: 'set a timer for 10 minutes',
            capturedAt: now,
            signatureBase64: signed['signatureBase64']!,
          );

          final result = await AttestationService.consumeMatching(
            session,
            householdId: household.id!,
            alexaCommandText: 'set a timer for 5 minutes',
            now: now,
          );
          expect(result, isNull);

          // Still unconsumed and available for the correct command.
          final correctMatch = await AttestationService.consumeMatching(
            session,
            householdId: household.id!,
            alexaCommandText: 'set a timer for 10 minutes',
            now: now,
          );
          expect(correctMatch, isNotNull);
        });
      },
    );

    group('when there are expired unconsumed attestations', () {
      test('then the cleanup marks them revoked and audits once', () async {
        final now = DateTime.now().toUtc();
        final capturedAt = now.subtract(const Duration(seconds: 4));
        final signed = await buildSignedPayload(
          memberId: member.id!,
          transcriptNormalised: 'unlock the front door',
          capturedAt: capturedAt,
        );
        final attestation = await AttestationService.submit(
          session,
          hubId: hub.id!,
          memberId: member.id!,
          tier: TrustTier.t1,
          confidence: 0.95,
          spoofRisk: SpoofRisk.low,
          transcriptNormalised: 'unlock the front door',
          capturedAt: capturedAt,
          signatureBase64: signed['signatureBase64']!,
        );
        expect(attestation.expiresAt.isBefore(DateTime.now().toUtc()), isTrue);

        final marked = await AttestationService.markExpiredUnconsumed(
          session,
        );
        expect(marked, greaterThanOrEqualTo(1));

        final reloaded = await Attestation.db.findById(
          session,
          attestation.id!,
        );
        expect(reloaded!.revoked, isTrue);

        final again = await AttestationService.markExpiredUnconsumed(
          session,
        );
        expect(again, 0);
      });
    });
  });
}

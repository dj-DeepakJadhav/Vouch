import 'package:test/test.dart';
import 'package:vouch_server/src/attestation/attestation_signature.dart';
import 'package:vouch_server/src/generated/protocol.dart';
import 'package:vouch_server/src/identity/enrolment_endpoint.dart';
import 'package:vouch_server/src/identity/enrolment_signature.dart';

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
    late dynamic signed;

    setUp(() async {
      household = await Household.db.insertRow(
        session,
        Household(name: 'Enrolment Test', createdAt: DateTime.now().toUtc()),
      );
      member = await Member.db.insertRow(
        session,
        Member(
          householdId: household.id!,
          displayName: 'Kid',
          role: MemberRole.child,
          status: MemberStatus.active,
        ),
      );
      signed = await AttestationSignature.signForTest('probe');
      hub = await Hub.db.insertRow(
        session,
        Hub(
          householdId: household.id!,
          publicKey: signed.publicKeyBase64,
          version: '0.0.1-test',
          lastSeen: DateTime.now().toUtc(),
        ),
      );
    });

    test(
      'when the hub reports a signed enrolment then it is stored without any voiceprint vector',
      () async {
        final capturedAt = DateTime.now().toUtc();
        final payload = EnrolmentSignature.canonicalPayload(
          hubId: hub.id!,
          memberId: member.id!,
          embeddingRef: 'member-${member.id}',
          qualityScore: 0.91,
          sampleCount: 8,
          capturedAt: capturedAt,
        );
        final reSigned = await AttestationSignature.signForTest(
          payload,
          keyPair: signed.keyPair,
        );

        final enrolment = await EnrolmentEndpoint().report(
          session,
          hubId: hub.id!,
          memberId: member.id!,
          embeddingRef: 'member-${member.id}',
          qualityScore: 0.91,
          sampleCount: 8,
          capturedAt: capturedAt,
          signatureBase64: reSigned.signatureBase64,
        );

        expect(enrolment.memberId, member.id);
        expect(enrolment.embeddingRef, 'member-${member.id}');
        expect(enrolment.sampleCount, 8);
      },
    );

    test(
      'when the signature does not verify then the report is rejected',
      () async {
        final capturedAt = DateTime.now().toUtc();
        await expectLater(
          EnrolmentEndpoint().report(
            session,
            hubId: hub.id!,
            memberId: member.id!,
            embeddingRef: 'member-${member.id}',
            qualityScore: 0.9,
            sampleCount: 8,
            capturedAt: capturedAt,
            signatureBase64: 'not-a-valid-signature',
          ),
          throwsA(isA<EnrolmentRejected>()),
        );
      },
    );

    test(
      'when memberId belongs to a different household then the report is rejected',
      () async {
        final otherHousehold = await Household.db.insertRow(
          session,
          Household(name: 'Other', createdAt: DateTime.now().toUtc()),
        );
        final otherMember = await Member.db.insertRow(
          session,
          Member(
            householdId: otherHousehold.id!,
            displayName: 'Stranger',
            role: MemberRole.adult,
            status: MemberStatus.active,
          ),
        );

        final capturedAt = DateTime.now().toUtc();
        final payload = EnrolmentSignature.canonicalPayload(
          hubId: hub.id!,
          memberId: otherMember.id!,
          embeddingRef: 'member-${otherMember.id}',
          qualityScore: 0.9,
          sampleCount: 8,
          capturedAt: capturedAt,
        );
        final reSigned = await AttestationSignature.signForTest(
          payload,
          keyPair: signed.keyPair,
        );

        await expectLater(
          EnrolmentEndpoint().report(
            session,
            hubId: hub.id!,
            memberId: otherMember.id!,
            embeddingRef: 'member-${otherMember.id}',
            qualityScore: 0.9,
            sampleCount: 8,
            capturedAt: capturedAt,
            signatureBase64: reSigned.signatureBase64,
          ),
          throwsA(isA<EnrolmentRejected>()),
        );
      },
    );
  });
}

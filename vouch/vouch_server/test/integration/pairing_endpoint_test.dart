import 'package:test/test.dart';
import 'package:vouch_server/src/approval/approval_endpoint.dart';
import 'package:vouch_server/src/attestation/attestation_signature.dart';
import 'package:vouch_server/src/generated/protocol.dart';
import 'package:vouch_server/src/pairing/pairing_endpoint.dart';
import 'package:vouch_server/src/pairing/pairing_signature.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given a household with a hub and an unpaired owner', (
    sessionBuilder,
    endpoints,
  ) {
    var session = sessionBuilder.build();

    late Household household;
    late Member owner;
    late Hub hub;
    late dynamic signed;

    const callerAuthUserId = '55555555-5555-5555-5555-555555555555';

    Future<String> mintCode({DateTime? capturedAt}) async {
      final at = capturedAt ?? DateTime.now().toUtc();
      final payload = PairingSignature.canonicalPayload(
        hubId: hub.id!,
        capturedAt: at,
      );
      final reSigned = await AttestationSignature.signForTest(
        payload,
        keyPair: signed.keyPair,
      );
      return endpoints.pairing.createCode(
        sessionBuilder,
        hubId: hub.id!,
        capturedAt: at,
        signatureBase64: reSigned.signatureBase64,
      );
    }

    setUp(() async {
      household = await Household.db.insertRow(
        session,
        Household(name: 'Pairing Test', createdAt: DateTime.now().toUtc()),
      );
      owner = await Member.db.insertRow(
        session,
        Member(
          householdId: household.id!,
          displayName: 'Owner',
          role: MemberRole.owner,
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

    test('a hub-minted code is a 6-digit string', () async {
      final code = await mintCode();
      expect(code, matches(RegExp(r'^\d{6}$')));
    });

    test(
      'redeeming a valid code links the caller to the owner member',
      () async {
        final code = await mintCode();
        final authSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            callerAuthUserId,
            {},
          ),
        );

        final overview = await endpoints.pairing.redeem(authSession, code);
        expect(overview.household.id, household.id);

        final updatedOwner = await Member.db.findById(session, owner.id!);
        expect(updatedOwner!.authUserId, callerAuthUserId);
      },
    );

    test('a wrong code is rejected', () async {
      await mintCode();
      final authSession = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          callerAuthUserId,
          {},
        ),
      );

      await expectLater(
        endpoints.pairing.redeem(authSession, '000000'),
        throwsA(
          isA<PairingRejected>().having(
            (e) => e.reason,
            'reason',
            'invalid_code',
          ),
        ),
      );
    });

    test('an expired code is rejected', () async {
      final code = await mintCode(
        capturedAt: DateTime.now().toUtc().subtract(
          const Duration(minutes: 11),
        ),
      );
      final authSession = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          callerAuthUserId,
          {},
        ),
      );

      await expectLater(
        endpoints.pairing.redeem(authSession, code),
        throwsA(
          isA<PairingRejected>().having(
            (e) => e.reason,
            'reason',
            'expired_code',
          ),
        ),
      );
    });

    test('a code cannot be redeemed twice', () async {
      final code = await mintCode();
      final authSession = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          callerAuthUserId,
          {},
        ),
      );
      const secondCallerAuthUserId = '66666666-6666-6666-6666-666666666666';
      final secondAuthSession = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          secondCallerAuthUserId,
          {},
        ),
      );

      await endpoints.pairing.redeem(authSession, code);

      await expectLater(
        endpoints.pairing.redeem(secondAuthSession, code),
        throwsA(
          isA<PairingRejected>().having(
            (e) => e.reason,
            'reason',
            'already_used',
          ),
        ),
      );
    });

    test(
      'redeem is rate-limited to 5 attempts per caller within the window',
      () async {
        await mintCode();
        final authSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            '77777777-7777-7777-7777-777777777777',
            {},
          ),
        );

        for (var i = 0; i < 5; i++) {
          await expectLater(
            endpoints.pairing.redeem(authSession, '000000'),
            throwsA(
              isA<PairingRejected>().having(
                (e) => e.reason,
                'reason',
                'invalid_code',
              ),
            ),
          );
        }

        await expectLater(
          endpoints.pairing.redeem(authSession, '000000'),
          throwsA(
            isA<PairingRejected>().having(
              (e) => e.reason,
              'reason',
              'rate_limited',
            ),
          ),
        );
      },
    );

    test(
      'pairing into one household does not grant approval rights over another',
      () async {
        final code = await mintCode();
        final authSession = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            callerAuthUserId,
            {},
          ),
        );
        await endpoints.pairing.redeem(authSession, code);

        final otherHousehold = await Household.db.insertRow(
          session,
          Household(
            name: 'Other Household',
            createdAt: DateTime.now().toUtc(),
          ),
        );
        final now = DateTime.now().toUtc();
        final otherApproval = await Approval.db.insertRow(
          session,
          Approval(
            householdId: otherHousehold.id!,
            memberId: null,
            action: 'unlock_door',
            argsJson: '{}',
            utterance: 'unlock the front door',
            status: ApprovalStatus.pending,
            used: false,
            createdAt: now,
            expiresAt: now.add(const Duration(seconds: 60)),
          ),
        );

        await expectLater(
          endpoints.approval.decide(authSession, otherApproval.id!, true),
          throwsA(isA<NotHouseholdOwnerException>()),
        );
      },
    );
  });
}

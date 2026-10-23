@Tags(['live'])
library;

import 'package:test/test.dart';
import 'package:vouch_server/src/generated/protocol.dart';
import 'package:vouch_server/src/policy/rule_compiler.dart';

import 'test_tools/serverpod_test_tools.dart';

/// Live Nemotron calls — only runs when `nebiusApiKey` is actually
/// configured for the run mode the tests execute under (`config/test.yaml`
/// has no such key; set `SERVERPOD_PASSWORD_nebiusApiKey` to run this for
/// real). Skips itself otherwise, so `dart test` stays fully offline by
/// default. Run explicitly with `dart test -t live`.
void main() {
  withServerpod('Given a household with an owner and a child', (
    sessionBuilder,
    endpoints,
  ) {
    var session = sessionBuilder.build();

    late Household household;
    late Member child;
    late Member priya;

    setUp(() async {
      household = await Household.db.insertRow(
        session,
        Household(
          name: 'Live Rule Compiler Test',
          createdAt: DateTime.now().toUtc(),
        ),
      );
      await Member.db.insertRow(
        session,
        Member(
          householdId: household.id!,
          displayName: 'Ana\'s Dad',
          role: MemberRole.owner,
          status: MemberStatus.active,
        ),
      );
      child = await Member.db.insertRow(
        session,
        Member(
          householdId: household.id!,
          displayName: 'Ana',
          role: MemberRole.child,
          status: MemberStatus.active,
        ),
      );
      priya = await Member.db.insertRow(
        session,
        Member(
          householdId: household.id!,
          displayName: 'Priya',
          role: MemberRole.adult,
          status: MemberStatus.active,
        ),
      );
    });

    test(
      'when previewing "Ana can\'t buy anything over 10 euros" then Nemotron '
      'proposes a sensible spending-limit or deny rule',
      () async {
        final apiKey = session.passwords['nebiusApiKey'];
        if (apiKey == null || apiKey.isEmpty) {
          markTestSkipped(
            'no live nebiusApiKey configured for this run mode',
          );
          return;
        }

        final result = await RuleCompiler.preview(
          session,
          householdId: household.id!,
          text: "Ana can't buy anything over 10 euros",
        );

        // ignore: avoid_print
        print(
          '--- Nemotron raw output (spending limit) ---\n${result.rawModelOutput}',
        );
        // ignore: avoid_print
        print(
          '--- accepted proposals ---\n${result.proposals.map((p) => p.toJson())}',
        );
        // ignore: avoid_print
        print('--- rejected ---\n${result.rejected}');

        expect(result.proposals, isNotEmpty);
        final proposal = result.proposals.first;
        expect(proposal.actionPattern, anyOf('place_order', 'place_*'));
        expect(proposal.memberId, child.id);
        // Either a hard deny, or a require + a <=10 EUR maxAmount condition.
        if (proposal.effect == PolicyEffect.require) {
          expect(proposal.argConditions, isNotNull);
        }
      },
    );

    test(
      "when previewing \"guests can't unlock doors\" then Nemotron proposes "
      'a role-scoped deny rule for unlock_*',
      () async {
        final apiKey = session.passwords['nebiusApiKey'];
        if (apiKey == null || apiKey.isEmpty) {
          markTestSkipped(
            'no live nebiusApiKey configured for this run mode',
          );
          return;
        }

        final result = await RuleCompiler.preview(
          session,
          householdId: household.id!,
          text: "guests can't unlock doors",
        );

        // ignore: avoid_print
        print(
          '--- Nemotron raw output (guest unlock) ---\n${result.rawModelOutput}',
        );
        // ignore: avoid_print
        print(
          '--- accepted proposals ---\n${result.proposals.map((p) => p.toJson())}',
        );
        // ignore: avoid_print
        print('--- rejected ---\n${result.rejected}');

        expect(result.proposals, isNotEmpty);
        final proposal = result.proposals.first;
        expect(proposal.actionPattern, anyOf('unlock_front_door', 'unlock_*'));
        expect(proposal.role, MemberRole.guest);
        expect(proposal.effect, PolicyEffect.deny);
      },
    );

    test(
      'when previewing "Only Priya can send messages" then Nemotron proposes '
      'a send_message rule scoped to Priya (and, per the household default, '
      'never weaker than t2)',
      () async {
        final apiKey = session.passwords['nebiusApiKey'];
        if (apiKey == null || apiKey.isEmpty) {
          markTestSkipped(
            'no live nebiusApiKey configured for this run mode',
          );
          return;
        }

        final result = await RuleCompiler.preview(
          session,
          householdId: household.id!,
          text: 'Only Priya can send messages',
        );

        // ignore: avoid_print
        print(
          '--- Nemotron raw output (only Priya sends messages) ---\n${result.rawModelOutput}',
        );
        // ignore: avoid_print
        print(
          '--- accepted proposals ---\n${result.proposals.map((p) => p.toJson())}',
        );
        // ignore: avoid_print
        print('--- rejected ---\n${result.rejected}');

        expect(result.proposals, isNotEmpty);
        // Every accepted proposal must be t2 for send_message (its built-in
        // default) — the validator rejects anything weaker regardless of
        // what the model proposes.
        for (final p in result.proposals) {
          if (p.actionPattern == 'send_message') {
            expect(p.requiredTier, TrustTier.t2);
          }
        }
        // Expect at least one proposal scoped to Priya specifically (either
        // require+t2 for her, and/or deny for everyone else).
        expect(
          result.proposals.any((p) => p.memberId == priya.id) ||
              result.proposals.any((p) => p.effect == PolicyEffect.deny),
          isTrue,
        );
      },
    );
  });
}

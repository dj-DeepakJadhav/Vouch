import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vouch_client/vouch_client.dart';
import 'package:vouch_flutter/logic/approvals_controller.dart';
import 'package:vouch_flutter/screens/alexa_screen.dart';

import '../fakes/fake_repositories.dart';

Approval _pending({String? match, String? heard}) => Approval(
  id: 41,
  householdId: 1,
  memberId: 2,
  action: 'add_to_list',
  argsJson: '{"item":"chocolate"}',
  utterance: 'Put chocolate on the shopping list',
  speakerConfidence: 0.95,
  transcriptMatch: match,
  heardTranscript: heard,
  status: ApprovalStatus.pending,
  used: false,
  createdAt: DateTime.now().toUtc(),
  expiresAt: DateTime.now().toUtc().add(const Duration(seconds: 60)),
);

Future<(FakeApprovalRepository, ApprovalsController)> _pump(
  WidgetTester tester,
  Approval approval,
) async {
  final repo = FakeApprovalRepository(pending: [approval]);
  final controller = ApprovalsController(repository: repo, householdId: 1);
  await controller.load();
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: controller,
      child: const MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: OwnerPhoneCard())),
      ),
    ),
  );
  return (repo, controller);
}

void main() {
  testWidgets('pending step-up shows the inline card; Approve decides it', (
    tester,
  ) async {
    final (repo, _) = await _pump(tester, _pending(match: 'matched'));
    expect(find.byKey(const Key('owner-phone-card')), findsOneWidget);
    expect(find.text("Owner's phone"), findsOneWidget);
    expect(find.byKey(const Key('wording-notice')), findsNothing);

    await tester.tap(find.byKey(const Key('approve-button')));
    await tester.pump();
    expect(repo.decided[41]?.status, ApprovalStatus.approved);
    // Decided: the inline card goes away (the Approvals tab keeps history).
    expect(find.byKey(const Key('owner-phone-card')), findsNothing);
  });

  testWidgets('Deny goes through the same path', (tester) async {
    final (repo, _) = await _pump(tester, _pending(match: 'matched'));
    await tester.tap(find.byKey(const Key('deny-button')));
    await tester.pump();
    expect(repo.decided[41]?.status, ApprovalStatus.denied);
  });

  testWidgets('near-miss shows the wording notice inline too', (tester) async {
    await _pump(
      tester,
      _pending(
        match: 'near_miss',
        heard: 'add chocolate to the shopping list',
      ),
    );
    expect(find.byKey(const Key('wording-notice')), findsOneWidget);
    expect(
      find.textContaining("Heard: 'add chocolate to the shopping list'"),
      findsOneWidget,
    );
  });

  testWidgets('nothing pending renders nothing', (tester) async {
    final controller = ApprovalsController(
      repository: FakeApprovalRepository(),
      householdId: 1,
    );
    await controller.load();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: const MaterialApp(home: Scaffold(body: OwnerPhoneCard())),
      ),
    );
    expect(find.byKey(const Key('owner-phone-card')), findsNothing);
  });
}

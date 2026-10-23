import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vouch_client/vouch_client.dart';
import 'package:vouch_flutter/widgets/approval_card.dart';

Approval _pendingApproval() => Approval(
  id: 1,
  householdId: 1,
  memberId: 2,
  action: 'place_order',
  argsJson: '{"item":"headphones","amount":249,"currency":"EUR"}',
  utterance: 'order the headphones',
  status: ApprovalStatus.pending,
  used: false,
  createdAt: DateTime.now().toUtc(),
  expiresAt: DateTime.now().toUtc().add(const Duration(seconds: 60)),
);

void main() {
  testWidgets('a lapsed pending approval offers no Approve/Deny', (
    tester,
  ) async {
    var tapped = false;
    final lapsed = _pendingApproval().copyWith(
      expiresAt: DateTime.now().toUtc().subtract(const Duration(seconds: 1)),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ApprovalCard(
            approval: lapsed,
            memberName: 'Ana',
            onApprove: () => tapped = true,
            onDeny: () => tapped = true,
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('approve-button')));
    await tester.tap(find.byKey(const Key('deny-button')));
    expect(tapped, isFalse);
    expect(find.text('Expired'), findsOneWidget);
  });

  testWidgets('ApprovalCard shows who asked, action, utterance and args', (
    tester,
  ) async {
    final approval = _pendingApproval();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ApprovalCard(
            approval: approval,
            memberName: 'Ana',
            onApprove: () {},
            onDeny: () {},
          ),
        ),
      ),
    );

    expect(find.textContaining('Ana wants to place an order'), findsOneWidget);
    expect(find.text('"order the headphones"'), findsOneWidget);
    expect(find.textContaining('item: headphones'), findsOneWidget);
    expect(find.byKey(const Key('approve-button')), findsOneWidget);
    expect(find.byKey(const Key('deny-button')), findsOneWidget);
  });

  testWidgets(
    'ApprovalCard shows "unrecognised speaker" when memberName is null',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApprovalCard(
              approval: _pendingApproval(),
              memberName: null,
              onApprove: () {},
              onDeny: () {},
            ),
          ),
        ),
      );

      expect(
        find.textContaining('unrecognised speaker wants to'),
        findsOneWidget,
      );
    },
  );

  testWidgets('Approve/Deny buttons invoke callbacks', (tester) async {
    var approved = false;
    var denied = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ApprovalCard(
            approval: _pendingApproval(),
            memberName: 'Ana',
            onApprove: () => approved = true,
            onDeny: () => denied = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('approve-button')));
    await tester.pump();
    expect(approved, isTrue);

    await tester.tap(find.byKey(const Key('deny-button')));
    await tester.pump();
    expect(denied, isTrue);
  });

  testWidgets('ApprovalCard shows speaker confidence when supplied', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ApprovalCard(
            approval: _pendingApproval(),
            memberName: 'Ana',
            confidence: 0.93,
            onApprove: () {},
            onDeny: () {},
          ),
        ),
      ),
    );

    expect(find.textContaining('93% confidence'), findsOneWidget);
  });

  testWidgets('ApprovalCard omits confidence text when not supplied', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ApprovalCard(
            approval: _pendingApproval(),
            memberName: 'Ana',
            onApprove: () {},
            onDeny: () {},
          ),
        ),
      ),
    );

    expect(find.textContaining('confidence'), findsNothing);
  });

  testWidgets('Decided approval shows decided state, not action buttons', (
    tester,
  ) async {
    final decided = _pendingApproval().copyWith(
      status: ApprovalStatus.approved,
      decidedAt: DateTime.now().toUtc(),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ApprovalCard(
            approval: decided,
            memberName: 'Ana',
            onApprove: () {},
            onDeny: () {},
          ),
        ),
      ),
    );

    expect(find.text('Approved. Alexa will continue'), findsOneWidget);
    expect(find.byKey(const Key('approve-button')), findsNothing);
    expect(find.byKey(const Key('deny-button')), findsNothing);
  });

  testWidgets('near-miss approval shows the amber wording notice', (
    tester,
  ) async {
    final approval = _pendingApproval().copyWith(
      utterance: 'buy the headphones',
      transcriptMatch: 'near_miss',
      heardTranscript: 'order the headphones',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ApprovalCard(
            approval: approval,
            memberName: 'Ana',
            confidence: 0.95,
            onApprove: () {},
            onDeny: () {},
          ),
        ),
      ),
    );
    expect(find.byKey(const Key('wording-notice')), findsOneWidget);
    expect(
      find.textContaining("Heard: 'order the headphones'"),
      findsOneWidget,
    );
    expect(
      find.textContaining("Alexa sent: 'buy the headphones'"),
      findsOneWidget,
    );
    expect(find.textContaining('Recognised: Ana'), findsNothing);
    expect(find.textContaining('wording differs'), findsOneWidget);
  });

  testWidgets('exact-match approval keeps the recognised line, no notice', (
    tester,
  ) async {
    final approval = _pendingApproval().copyWith(transcriptMatch: 'matched');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ApprovalCard(
            approval: approval,
            memberName: 'Ana',
            confidence: 0.95,
            onApprove: () {},
            onDeny: () {},
          ),
        ),
      ),
    );
    expect(find.byKey(const Key('wording-notice')), findsNothing);
    expect(find.textContaining('Recognised: Ana'), findsOneWidget);
  });
}

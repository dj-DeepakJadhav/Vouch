import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vouch_client/vouch_client.dart';
import 'package:vouch_flutter/data/mcp/mcp_gateway.dart';
import 'package:vouch_flutter/logic/alexa_controller.dart';
import 'package:vouch_flutter/screens/alexa_screen.dart';
import 'package:vouch_flutter/widgets/alexa/verdict_model.dart';

import '../fakes/fake_mcp_gateway.dart';
import '../fakes/fake_repositories.dart';

Map<String, dynamic> _vouch(
  String decision, {
  bool known = true,
  String reason = 'Denied by policy rule for "place_order" (Children may not)',
  String role = 'child',
}) => {
  'speaker': known ? {'memberId': 2, 'displayName': 'Ana', 'role': role} : null,
  'confidence': known ? 0.91 : null,
  'attestationMatched': known,
  'matchedTranscript': known ? 'order the new playstation' : null,
  'requiredTier': 't2',
  'presentTier': 't1',
  'decision': decision,
  'reason': reason,
  'ruleSource': 'children may never place orders',
};

void main() {
  group('verdict sentences', () {
    test('replay rejection is not attributed to an owner denial', () {
      final replay = _vouch(
        'denied',
        reason: 'replayed requestState for already-used approval 61',
      );
      expect(
        buildVerdict(replay, inFlight: false).headline,
        'Blocked. This approval has already been used.',
      );
      expect(
        alexaReply(replay, toolText: 'Denied', isError: true),
        "That approval has already been used. I didn't repeat the action.",
      );
    });
    test('allow, deny and waiting read as plain sentences', () {
      final allow = buildVerdict(_vouch('allow'), inFlight: false);
      expect(allow.kind, VerdictKind.allowed);
      expect(allow.headline, startsWith('Allowed.'));

      final deny = buildVerdict(_vouch('deny'), inFlight: false);
      expect(deny.kind, VerdictKind.blocked);
      expect(deny.headline, "Blocked. Ana isn't allowed to do this.");
      expect(deny.detail, contains('Children may not'));

      final wait = buildVerdict(
        _vouch('stepUp'),
        inFlight: true,
        ownerName: 'Priya',
      );
      expect(wait.kind, VerdictKind.waiting);
      expect(wait.headline, 'Waiting for Priya to approve on their phone.');

      expect(
        buildVerdict(_vouch('deny', known: false), inFlight: false).headline,
        "Blocked. Vouch doesn't recognise this voice.",
      );
    });

    test('Alexa speaks naturally; allowed keeps the tool text', () {
      expect(
        alexaReply(
          _vouch('deny'),
          toolText: 'x',
          isError: true,
          ownerName: 'Priya',
          toolName: 'place_order',
        ),
        "Sorry Ana, ordering needs a parent. Priya can see this in the activity log.",
      );
      expect(
        alexaReply(
          _vouch('deny', known: false),
          toolText: 'x',
          isError: true,
        ),
        "Sorry, I don't recognise your voice, so I can't do that.",
      );
      expect(
        alexaReply(
          _vouch('allow'),
          toolText: 'Front door unlocked.',
          isError: false,
        ),
        'Front door unlocked.',
      );
      expect(
        waitingReply('Priya'),
        "I've sent this to Priya's phone to approve.",
      );
    });
  });

  group('alexaReply follows the actual reason', () {
    String reply(Map<String, dynamic> v, {String? tool}) => alexaReply(
      v,
      toolText: 'x',
      isError: true,
      ownerName: 'Priya',
      toolName: tool,
    );

    test('amount limit', () {
      expect(
        reply(
          _vouch('deny', reason: 'Denied: exceeds household limit of EUR 10'),
          tool: 'place_order',
        ),
        "Sorry Ana, that's over your EUR 10 limit.",
      );
    });
    test('amount limit, unknown speaker', () {
      expect(
        reply(
          _vouch(
            'deny',
            known: false,
            reason: 'Denied: exceeds household limit of EUR 10',
          ),
        ),
        "Sorry, that's over the household limit of EUR 10.",
      );
    });
    test('child blanket rule', () {
      expect(
        reply(_vouch('deny'), tool: 'unlock_front_door'),
        'Sorry Ana, unlocking the door needs a parent. Priya can see this in '
        'the activity log.',
      );
    });
    test('rule deny for a non-child', () {
      expect(
        reply(
          _vouch(
            'deny',
            role: 'adult',
            reason: 'Denied by policy rule for "x"',
          ),
        ),
        'Sorry Ana, a household rule says no to that.',
      );
    });
    test('revoked and unknown voices', () {
      expect(
        reply(_vouch('deny', known: false, reason: 'member revoked')),
        "Sorry, that voice's access has been turned off, so I can't do that.",
      );
      expect(
        reply(_vouch('deny', known: false, reason: 'speaker not recognised')),
        "Sorry, I don't recognise your voice, so I can't do that.",
      );
    });
    test('reworded command', () {
      expect(
        reply(
          _vouch('deny', reason: 'attested tier below required tier t1'),
        ),
        "Sorry Ana, I couldn't confirm you said exactly that, so I can't do "
        'it.',
      );
    });
    test('owner said no, expired, fallback', () {
      expect(
        reply(_vouch('denied')),
        "Priya said no, so I didn't do that.",
      );
      expect(
        reply(_vouch('expired')),
        "Nobody approved that in time, so I didn't do it.",
      );
      expect(
        reply(_vouch('deny', role: 'adult', reason: 'whatever')),
        "Sorry Ana, I can't do that for you.",
      );
    });
  });

  testWidgets('waiting bubble is replaced in place; 3 rows, then details', (
    tester,
  ) async {
    final waiting = McpInputRequired(
      buildVouchTraceSteps(
        utterance: 'Order the new PlayStation for 500 euros',
        vouch: _vouch('stepUp'),
      ),
      requestState: 's',
      message: 'Approval required.',
      vouch: _vouch('stepUp'),
    );
    final done = McpComplete(
      buildVouchTraceSteps(
        utterance: 'Order the new PlayStation for 500 euros',
        vouch: _vouch('deny'),
      ),
      text: 'Ordering needs a parent.',
      isError: true,
      vouch: _vouch('deny'),
    );
    final gateway = FakeMcpGateway([waiting, done]);
    final controller = AlexaController(
      demoRepository: FakeDemoRepository(),
      householdRepository: FakeHouseholdRepository(
        overview: HouseholdOverview(
          household: Household(
            id: 1,
            name: 'T',
            createdAt: DateTime.now().toUtc(),
          ),
          members: const [],
          hubs: const [],
        ),
      ),
      householdId: 1,
      mcpUrl: 'http://localhost/mcp',
      gatewayFactory: ({required mcpUrl, required token}) => gateway,
    );
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AlexaController>.value(
          value: controller,
          child: const Scaffold(body: AlexaScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    controller.sendUtterance('Order the new PlayStation for 500 euros');
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      find.text("I've sent this to the owner's phone to approve."),
      findsOneWidget,
    );
    expect(find.textContaining('Waiting for the owner'), findsWidgets);

    // The retry (2 s timer) delivers the outcome.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(
      find.text("I've sent this to the owner's phone to approve."),
      findsNothing,
    );
    expect(
      find.text(
        "Sorry Ana, ordering needs a parent. The owner can see this in the activity log.",
      ),
      findsOneWidget,
    );

    // Collapsed: 3 rows, no timeline.
    expect(find.text('Who spoke'), findsOneWidget);
    expect(find.text('Matches what Alexa sent'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('decision-trace-panel')),
        matching: find.text('Decision'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('trace-details')), findsNothing);
    expect(find.text('Heard'), findsNothing);

    await tester.tap(find.byKey(const Key('trace-toggle')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('trace-details')), findsOneWidget);
    expect(find.text('Heard'), findsOneWidget);
    expect(
      describeToolCall('place_order', {
        'item': 'new PlayStation',
        'amount': 500.0,
        'currency': 'EUR',
      }),
      'Order: new PlayStation · EUR 500',
    );
    expect(find.text('Hide details'), findsOneWidget);
  });
}

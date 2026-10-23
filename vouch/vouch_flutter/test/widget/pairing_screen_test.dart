import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vouch_client/vouch_client.dart';
import 'package:vouch_flutter/data/repositories/pairing_repository.dart';
import 'package:vouch_flutter/screens/pairing_screen.dart';

class _FakePairingRepository implements PairingRepository {
  _FakePairingRepository(this._result);
  final Object Function() _result;

  @override
  Future<HouseholdOverview> redeem(String code) async {
    final result = _result();
    if (result is Exception) throw result;
    return result as HouseholdOverview;
  }
}

HouseholdOverview _overview() => HouseholdOverview(
      household: Household(id: 1, name: 'Paired household', createdAt: DateTime.now().toUtc()),
      members: const [],
      hubs: const [],
    );

void main() {
  Future<void> pump(WidgetTester tester, Size size, PairingRepository repo, {HouseholdOverview? captured}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: PairingScreen(
          pairingRepository: repo,
          onPaired: (overview) => captured = overview,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  const desktop = Size(1280, 860);
  const phone = Size(390, 844);

  for (final size in [desktop, phone]) {
    final label = size == desktop ? '1280x860' : '390x844';

    testWidgets('renders the hub instructions and code field without overflow at $label', (
      tester,
    ) async {
      await pump(tester, size, _FakePairingRepository(_overview));
      expect(tester.takeException(), isNull);
      expect(find.textContaining('python -m vouch_hub pair'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
  }

  testWidgets('a wrong code shows a friendly message, not the raw exception', (tester) async {
    await pump(
      tester,
      desktop,
      _FakePairingRepository(() => Exception('PairingRejected: invalid_code')),
    );
    await tester.enterText(find.byType(TextField), '000000');
    await tester.pump();
    await tester.tap(find.text('Pair'));
    await tester.pumpAndSettle();

    expect(find.textContaining("doesn't match"), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a successful redeem calls onPaired with the household overview', (tester) async {
    HouseholdOverview? captured;
    await tester.pumpWidget(
      MaterialApp(
        home: PairingScreen(
          pairingRepository: _FakePairingRepository(_overview),
          onPaired: (overview) => captured = overview,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '123456');
    await tester.pump();
    await tester.tap(find.text('Pair'));
    // Not pumpAndSettle: on success the screen intentionally stays in its
    // busy state (the real app swaps it out for the shell via onPaired
    // instead of the screen resetting itself), so its spinner keeps
    // animating and pumpAndSettle would never terminate.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(captured, isNotNull);
    expect(captured!.household.name, 'Paired household');
  });
}

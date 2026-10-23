import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../client.dart';
import '../data/demo_session.dart';
import '../data/repos_bundle.dart';
import '../data/repositories/demo_repository.dart';
import '../data/repositories/pairing_repository.dart';
import '../screens/pairing_screen.dart';
import 'router.dart';
import 'shell.dart' show VouchMark;
import 'theme.dart';

/// The app's single root widget. Owns the light/dark theme and switches,
/// at build time, between the plain (signing-in / pairing / loading)
/// chrome and the full router-based shell — see class docs on
/// [_HouseholdGate] for why this is a single `build`-time choice rather
/// than nested apps.
///
/// Sign-in is anonymous + hub pairing, not email: the
/// app signs itself in anonymously on launch with no UI at all, then
/// resolves a household; if that fails, it shows [PairingScreen] rather
/// than any sign-in form. Email sign-in stays configured server-side (a
/// developer/support surface) but is never shown here.
class VouchApp extends StatelessWidget {
  const VouchApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = buildVouchTheme(Brightness.light);
    final darkTheme = buildVouchTheme(Brightness.dark);
    Route<void> gateRoute() => MaterialPageRoute<void>(
      builder: (_) => _HouseholdGate(theme: theme, darkTheme: darkTheme),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vouch',
      theme: theme,
      darkTheme: darkTheme,
      // Dark by default, still following
      // the system's light/dark preference when the platform reports one.
      themeMode: ThemeMode.dark,
      // The browser's deep link (e.g. /alexa) belongs to the inner
      // MaterialApp.router (see router.dart's initialShellLocation), not to
      // this outer app, which only ever shows the gate. A plain `home:`
      // makes the outer Navigator try to push the URL as a named route,
      // fail and log "Could not navigate to initial route"; generating the
      // gate for every route name avoids that.
      onGenerateInitialRoutes: (_) => [gateRoute()],
      onGenerateRoute: (_) => gateRoute(),
    );
  }
}

/// Signs in anonymously (no UI) if not already signed in, then resolves
/// the signed-in user to a household (`household.myHousehold`), then swaps
/// to the full router-based [VouchShellApp] — or, if the user has no
/// linked household yet, shows [PairingScreen].
class _HouseholdGate extends StatefulWidget {
  const _HouseholdGate({required this.theme, required this.darkTheme});

  final ThemeData theme;
  final ThemeData darkTheme;

  @override
  State<_HouseholdGate> createState() => _HouseholdGateState();
}

class _HouseholdGateState extends State<_HouseholdGate> {
  bool _loading = true;
  bool _needsPairing = false;
  int? _householdId;
  String? _signInError;

  /// Which API backs the no-hub demo household: the hosted DemoEndpoint
  /// (demoMode on), the DevEndpoint (local dev), or none (button hidden).
  DemoBackend _demoBackend = DemoBackend.none;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    if (!client.auth.isAuthenticated) {
      try {
        await AnonymousAuthController(client: client).login();
      } catch (e) {
        setState(() {
          _loading = false;
          _signInError = '$e';
        });
        return;
      }
    }
    await _resolve();
  }

  Future<void> _checkDemoAvailable() async {
    final backend = await chooseDemoBackend(
      hostedAvailable: client.demo.available,
      devAvailable: client.dev.demoAvailable,
    );
    if (mounted) setState(() => _demoBackend = backend);
  }

  Future<void> _resolve() async {
    setState(() {
      _loading = true;
      _signInError = null;
    });
    await _checkDemoAvailable();
    try {
      // Unpaired sessions get a clean false instead of the owner check's
      // NotHouseholdOwnerException (a 500 on every cold start).
      if (!await client.household.hasHousehold()) {
        throw StateError('not paired');
      }
      final overview = await client.household.myHousehold();
      DemoSession.current =
          await DemoSession.isRemembered(overview.household.id!)
          ? DemoSession.fromOverview(overview)
          : null;
      setState(() {
        _householdId = overview.household.id;
        _needsPairing = false;
        _loading = false;
      });
    } catch (e) {
      // Any failure to resolve a household (no linked member yet, etc.) is
      // treated as "needs pairing" — the pairing screen's own redeem call
      // surfaces a clearer error if the code the user enters is wrong.
      setState(() {
        _needsPairing = true;
        _loading = false;
      });
    }
  }

  /// Hosted DemoEndpoint when the server has demoMode on, otherwise the
  /// local DevEndpoint (which the server refuses outside development).
  Future<void> _startDemo() async {
    final seed = await demoRepositoryFor(client, _demoBackend).start();
    await DemoSession.remember(seed.householdId);
    DemoSession.current = DemoSession(
      hubId: seed.hubId,
      ownerMemberId: seed.ownerMemberId,
      childMemberId: seed.childMemberId,
    );
    await _resolve();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const _Splash();
    }
    if (_signInError != null) {
      return Scaffold(
        body: Center(
          child: VEmptyState(
            icon: VIcons.warn,
            title: "Couldn't reach the server",
            body: 'Sign-in failed: $_signInError',
            action: OutlinedButton.icon(
              onPressed: _start,
              icon: const Icon(VIcons.retry),
              label: const Text('Try again'),
            ),
          ),
        ),
      );
    }
    if (_needsPairing || _householdId == null) {
      return PairingScreen(
        pairingRepository: ServerpodPairingRepository(client),
        onTryDemo: _demoBackend == DemoBackend.none ? null : _startDemo,
        onPaired: (overview) => setState(() {
          _householdId = overview.household.id;
          _needsPairing = false;
        }),
      );
    }
    return VouchShellApp(
      bundle: ReposBundle.fromClient(
        client,
        householdId: _householdId!,
        demoBackend: _demoBackend,
      ),
      onSignOut: () async {
        await client.auth.signOutDevice();
        // Nothing else listens for sign-out: drop the household and start
        // over, which signs in anonymously afresh and lands on pairing.
        DemoSession.current = null;
        if (!mounted) return;
        setState(() {
          _householdId = null;
          _needsPairing = true;
        });
        await _start();
      },
      theme: widget.theme,
      darkTheme: widget.darkTheme,
    );
  }
}

/// Launch state: the mark, breathing once, then the household name when
/// it resolves. Replaces a bare spinner.
class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    return Scaffold(
      body: Center(
        child: FadeSlideIn(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const VouchMark(size: 44),
              const SizedBox(height: VSpace.s5),
              SizedBox(
                width: 120,
                child: ClipRRect(
                  borderRadius: VRadius.fullR,
                  child: LinearProgressIndicator(
                    minHeight: 2,
                    color: c.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: VSpace.s3),
              Text(
                'Connecting to your household',
                style: VType.supporting.copyWith(color: c.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

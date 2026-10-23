import '../data/demo_session.dart';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/repos_bundle.dart';
import '../logic/alexa_controller.dart';
import '../logic/approvals_controller.dart';
import '../logic/audit_controller.dart';
import '../logic/household_controller.dart';
import '../logic/members_controller.dart';
import '../logic/rules_controller.dart';
import '../screens/activity_screen.dart';
import '../screens/alexa_screen.dart';
import '../screens/approvals_screen.dart';
import '../screens/home_screen.dart';
import '../screens/members_screen.dart';
import '../screens/rules_screen.dart';
import 'shell.dart';
import 'theme.dart';

/// Everything reachable once a signed-in user has a resolved household:
/// wires the shared, screen-spanning controllers (declarative routing via
/// go_router — flutter-setup-declarative-routing) into a responsive shell.
class VouchShellApp extends StatelessWidget {
  const VouchShellApp({
    super.key,
    required this.bundle,
    required this.onSignOut,
    required this.theme,
    required this.darkTheme,
  });

  final ReposBundle bundle;
  final VoidCallback onSignOut;
  final ThemeData theme;
  final ThemeData darkTheme;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ReposBundle>.value(value: bundle),
        ChangeNotifierProvider(
          // Loaded up front too: member names (approval cards) and the hub
          // status chip must not depend on the Home tab having been opened.
          create: (_) => HouseholdController(
            repository: bundle.householdRepository,
            householdId: bundle.householdId,
            auditRepository: bundle.auditRepository,
          )..load(),
        ),
        ChangeNotifierProvider(
          // Loaded up front (not only when the tab opens) so the nav badge
          // and Home's "Awaiting you" count are live from launch.
          create: (_) => ApprovalsController(
            repository: bundle.approvalRepository,
            householdId: bundle.householdId,
          )..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => RulesController(
            repository: bundle.rulesRepository,
            householdId: bundle.householdId,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AuditController(
            repository: bundle.auditRepository,
            householdId: bundle.householdId,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => MembersController(
            repository: bundle.householdRepository,
            householdId: bundle.householdId,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AlexaController(
            demoRepository: bundle.demoRepository,
            householdRepository: bundle.householdRepository,
            householdId: bundle.householdId,
            mcpUrl: bundle.mcpUrl,
          ),
        ),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            title: 'Vouch',
            theme: theme,
            darkTheme: darkTheme,
            themeMode: ThemeMode.dark,
            debugShowCheckedModeBanner: false,
            routerConfig: _buildRouter(onSignOut),
          );
        },
      ),
    );
  }
}

const _tabPaths = {
  '/home',
  '/approvals',
  '/rules',
  '/activity',
  '/alexa',
  '/members',
};

/// The tab to open first: the deep link the page was loaded with (e.g. a
/// reload on /rules) if it names a tab, else Alexa for a demo household and
/// Home otherwise. Captured once at startup: after sign-out the next
/// household starts from the default again.
String initialShellLocation({String? deepLink, required bool demo}) {
  final path = Uri.tryParse(deepLink ?? '')?.path;
  if (path != null && _tabPaths.contains(path)) return path;
  return demo ? '/alexa' : '/home';
}

String? _launchDeepLink;

/// Call once from main(), before runApp: the outer MaterialApp's Navigator
/// reports its own route to the browser as soon as it builds, which would
/// overwrite the deep link the page was loaded with.
void captureLaunchDeepLink() {
  _launchDeepLink = PlatformDispatcher.instance.defaultRouteName;
}

GoRouter _buildRouter(VoidCallback onSignOut) {
  final deepLink = _launchDeepLink;
  _launchDeepLink = null;
  return GoRouter(
    initialLocation: initialShellLocation(
      deepLink: deepLink,
      demo: DemoSession.current != null,
    ),
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          final household = context.watch<HouseholdController>().overview;
          final pending = context.watch<ApprovalsController>().pendingCount;
          final checkedIn =
              household?.hubs.any((h) {
                final lastSeen = h.lastSeen;
                if (lastSeen == null) return false;
                return DateTime.now().toUtc().difference(lastSeen.toUtc()) <
                    const Duration(minutes: 2);
              }) ??
              false;
          // The Alexa tab's live GET /health probe is the fresher signal;
          // prefer it once it has run so the sidebar and the Alexa tab never
          // disagree. (Demo households show "Demo hub" in the shell instead.)
          final probed = context.select<AlexaController, bool?>(
            (a) => a.hubHealthy,
          );
          final hubOnline = probed ?? checkedIn;
          return AppShell(
            currentPath: state.uri.path,
            onSelect: (path) => context.go(path),
            householdName: householdDisplayName(
              household?.household.name ?? 'Vouch',
            ),
            hubOnline: hubOnline,
            pendingApprovalsCount: pending,
            onSignOut: onSignOut,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (_, state) => _tab(state, const HomeScreen()),
          ),
          GoRoute(
            path: '/approvals',
            pageBuilder: (_, state) => _tab(state, const ApprovalsScreen()),
          ),
          GoRoute(
            path: '/rules',
            pageBuilder: (_, state) => _tab(state, const RulesScreen()),
          ),
          GoRoute(
            path: '/activity',
            pageBuilder: (_, state) => _tab(state, const ActivityScreen()),
          ),
          GoRoute(
            path: '/alexa',
            pageBuilder: (_, state) => _tab(state, const AlexaScreen()),
          ),
          GoRoute(
            path: '/members',
            pageBuilder: (_, state) => _tab(state, const MembersScreen()),
          ),
        ],
      ),
    ],
  );
}

/// Tab change: the destination fades in and rises 1% into place; the
/// origin simply fades (motion DR4: no layout jump, no sideways slide
/// implying a hierarchy the tabs don't have).
CustomTransitionPage<void> _tab(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: VMotion.mediumMin,
    reverseTransitionDuration: VMotion.fast,
    transitionsBuilder: (context, animation, secondary, child) {
      if (VMotion.reduced(context)) return child;
      final a = CurvedAnimation(parent: animation, curve: VMotion.standard);
      return FadeTransition(
        opacity: a,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.012),
            end: Offset.zero,
          ).animate(a),
          child: child,
        ),
      );
    },
  );
}

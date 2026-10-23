import 'package:flutter/material.dart';

import '../data/demo_session.dart';

import 'theme.dart';

class NavDestinationSpec {
  const NavDestinationSpec({
    required this.label,
    required this.icon,
    required this.path,
    required this.hint,
  });

  final String label;
  final IconData icon;
  final String path;

  /// One-line description under the page title.
  final String hint;
}

const List<NavDestinationSpec> vouchDestinations = [
  NavDestinationSpec(
    label: 'Home',
    icon: VIcons.home,
    path: '/home',
    hint: 'Who spoke, what they asked, what Vouch decided.',
  ),
  NavDestinationSpec(
    label: 'Approvals',
    icon: VIcons.approvals,
    path: '/approvals',
    hint: 'Requests that need the owner before Alexa continues.',
  ),
  NavDestinationSpec(
    label: 'Rules',
    icon: VIcons.rules,
    path: '/rules',
    hint: 'Household rules in plain language.',
  ),
  NavDestinationSpec(
    label: 'Activity',
    icon: VIcons.activity,
    path: '/activity',
    hint: 'The append-only audit log of every decision.',
  ),
  NavDestinationSpec(
    label: 'Alexa',
    icon: VIcons.alexa,
    path: '/alexa',
    hint: 'Send a command through the real guard and watch it decide.',
  ),
  NavDestinationSpec(
    label: 'Members',
    icon: VIcons.members,
    path: '/members',
    hint: 'People in the household and their voice enrolment.',
  ),
];

/// Key on the navigation container (sidebar or tab bar), so tests can tap
/// destinations without also matching page content.
const vouchNavKey = Key('vouch-nav');

/// The app's persistent chrome: a sidebar on wide screens, a tab bar on
/// narrow ones. Carries the household name, the hub heartbeat, the
/// persistent privacy chip and the live pending-approvals count.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.child,
    required this.currentPath,
    required this.onSelect,
    required this.householdName,
    required this.hubOnline,
    required this.pendingApprovalsCount,
    required this.onSignOut,
  });

  final Widget child;
  final String currentPath;
  final ValueChanged<String> onSelect;
  final String householdName;
  final bool hubOnline;
  final int pendingApprovalsCount;
  final VoidCallback onSignOut;

  int get _selectedIndex {
    final i = vouchDestinations.indexWhere(
      (d) => currentPath.startsWith(d.path),
    );
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 800;
        final page = child;

        if (wide) {
          return Scaffold(
            backgroundColor: c.body,
            body: Row(
              children: [
                _Sidebar(
                  selectedIndex: _selectedIndex,
                  onSelect: onSelect,
                  householdName: householdName,
                  hubOnline: hubOnline,
                  pending: pendingApprovalsCount,
                  onSignOut: onSignOut,
                ),
                Expanded(child: page),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: c.body,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: _TopBar(
              householdName: householdName,
              hubOnline: hubOnline,
              onSignOut: onSignOut,
            ),
          ),
          body: page,
          bottomNavigationBar: _TabBar(
            selectedIndex: _selectedIndex,
            onSelect: onSelect,
            pending: pendingApprovalsCount,
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Wide: sidebar
// ---------------------------------------------------------------------------

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.selectedIndex,
    required this.onSelect,
    required this.householdName,
    required this.hubOnline,
    required this.pending,
    required this.onSignOut,
  });

  final int selectedIndex;
  final ValueChanged<String> onSelect;
  final String householdName;
  final bool hubOnline;
  final int pending;
  final VoidCallback onSignOut;

  static const double _itemHeight = VSize.elementLg;
  static const double _itemGap = 2;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    return Container(
      width: 248,
      decoration: BoxDecoration(
        color: c.body,
        border: Border(right: BorderSide(color: c.border)),
      ),
      padding: const EdgeInsets.fromLTRB(
        VSpace.s3,
        VSpace.s5,
        VSpace.s3,
        VSpace.s3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: VSpace.s2),
            child: Row(
              children: [
                const VouchMark(size: 24),
                const SizedBox(width: VSpace.s2),
                Text(
                  'Vouch',
                  style: VType.h3.copyWith(
                    color: c.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: VSpace.s6),
          _HouseholdCard(name: householdName, hubOnline: hubOnline),
          const SizedBox(height: VSpace.s6),
          Padding(
            padding: const EdgeInsets.only(left: VSpace.s2, bottom: VSpace.s2),
            child: const VEyebrow('Console'),
          ),
          // Selection is one pill that slides between items, so the eye
          // follows where you went (motion DR1 continuity).
          Stack(
            key: vouchNavKey,
            children: [
              AnimatedPositioned(
                duration: VMotion.of(context, VMotion.medium),
                curve: VMotion.standard,
                top: selectedIndex * (_itemHeight + _itemGap),
                left: 0,
                right: 0,
                height: _itemHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: c.brandSoft,
                    borderRadius: VRadius.elementR,
                    border: Border.all(color: c.brand.withValues(alpha: 0.45)),
                  ),
                ),
              ),
              Column(
                children: [
                  for (var i = 0; i < vouchDestinations.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: _itemGap),
                      child: _SidebarItem(
                        spec: vouchDestinations[i],
                        selected: i == selectedIndex,
                        badge: vouchDestinations[i].path == '/approvals'
                            ? pending
                            : 0,
                        onTap: () => onSelect(vouchDestinations[i].path),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const Spacer(),
          const PrivacyChip(),
          const SizedBox(height: VSpace.s2),
          Pressable(
            onTap: onSignOut,
            semanticLabel: 'Sign out',
            child: SizedBox(
              height: _itemHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: VSpace.s3),
                child: Row(
                  children: [
                    Icon(
                      VIcons.signOut,
                      size: VSize.iconSm,
                      color: c.textSecondary,
                    ),
                    const SizedBox(width: VSpace.s3),
                    Text(
                      'Sign out',
                      style: VType.label.copyWith(color: c.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.spec,
    required this.selected,
    required this.badge,
    required this.onTap,
  });

  final NavDestinationSpec spec;
  final bool selected;
  final int badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    final fg = selected ? c.textPrimary : c.textSecondary;
    final d = VMotion.of(context, VMotion.fast);
    return Pressable(
      onTap: onTap,
      selected: selected,
      scale: false,
      child: SizedBox(
        height: _Sidebar._itemHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: VSpace.s3),
          child: Row(
            children: [
              TweenAnimationBuilder<Color?>(
                tween: ColorTween(end: fg),
                duration: d,
                builder: (_, col, _) =>
                    Icon(spec.icon, size: VSize.iconSm, color: col),
              ),
              const SizedBox(width: VSpace.s3),
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: d,
                  style: VType.label.copyWith(color: fg),
                  child: Text(spec.label),
                ),
              ),
              _CountBadge(count: badge),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pending-approval count. Amber, because pending approvals are T2 by
/// definition. Scales in and out rather than popping.
class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count, this.compact = false});

  final int count;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    return AnimatedScale(
      scale: count > 0 ? 1 : 0,
      duration: VMotion.of(context, VMotion.fastMax),
      curve: VMotion.standard,
      child: Container(
        constraints: BoxConstraints(minWidth: compact ? 16 : 20),
        height: compact ? 16 : 20,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: c.t2,
          borderRadius: VRadius.fullR,
          border: compact ? Border.all(color: c.body, width: 2) : null,
        ),
        child: Text(
          count > 99 ? '99+' : '$count',
          style: VType.codeSm.copyWith(
            color: const Color(0xFF2A2400),
            fontSize: compact ? 9.5 : 11,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _HouseholdCard extends StatelessWidget {
  const _HouseholdCard({required this.name, required this.hubOnline});

  final String name;
  final bool hubOnline;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    return Container(
      padding: const EdgeInsets.all(VSpace.s3),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: VRadius.containerR,
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          VIconBox(icon: VIcons.home, size: VSize.elementMd),
          const SizedBox(width: VSpace.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: VType.label.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                _HubStatus(online: hubOnline),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HubStatus extends StatelessWidget {
  const _HubStatus({required this.online});

  final bool online;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    // The no-hub demo household has no physical hub to be "offline": the
    // app signs its attestations itself. Say so, in a neutral tone.
    final demo = DemoSession.current != null;
    final (label, tip, color, live) = demo
        ? (
            'Demo hub',
            'Demo household: voices are simulated in this browser; real households verify on the hub',
            c.success,
            true,
          )
        : online
        ? ('Hub online', 'Hub reachable', c.success, true)
        : ('Hub offline', 'Hub has not checked in recently', c.t0, false);
    return Tooltip(
      message: tip,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PulseDot(color: color, live: live, size: 6),
          const SizedBox(width: VSpace.s1_5),
          Text(
            label,
            style: VType.supporting.copyWith(
              color: c.textSecondary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Narrow: top bar + tab bar
// ---------------------------------------------------------------------------

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.householdName,
    required this.hubOnline,
    required this.onSignOut,
  });

  final String householdName;
  final bool hubOnline;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    return Container(
      decoration: BoxDecoration(
        color: c.body,
        border: Border(bottom: BorderSide(color: c.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.only(left: VSpace.s4, right: VSpace.s1),
            child: Row(
              children: [
                const VouchMark(size: 22),
                const SizedBox(width: VSpace.s3),
                Flexible(
                  child: Text(
                    householdName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: VType.label.copyWith(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: VSpace.s2),
                PulseDot(
                  color: hubOnline || DemoSession.current != null
                      ? c.success
                      : c.t0,
                  live: hubOnline || DemoSession.current != null,
                  size: 6,
                ),
                const Spacer(),
                // Same privacy fact as the sidebar chip, icon-only so it
                // never contests space with the household name (a full chip
                // overflowed the 390px app bar, caught by
                // test/widget/responsive_screens_test.dart).
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: VSpace.s2),
                  child: PrivacyChip(compact: true),
                ),
                IconButton(
                  onPressed: onSignOut,
                  icon: const Icon(VIcons.signOut),
                  tooltip: 'Sign out',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({
    required this.selectedIndex,
    required this.onSelect,
    required this.pending,
  });

  final int selectedIndex;
  final ValueChanged<String> onSelect;
  final int pending;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    return Container(
      key: vouchNavKey,
      decoration: BoxDecoration(
        color: c.body,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              for (var i = 0; i < vouchDestinations.length; i++)
                Expanded(
                  child: _TabItem(
                    spec: vouchDestinations[i],
                    selected: i == selectedIndex,
                    badge: vouchDestinations[i].path == '/approvals'
                        ? pending
                        : 0,
                    onTap: () => onSelect(vouchDestinations[i].path),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.spec,
    required this.selected,
    required this.badge,
    required this.onTap,
  });

  final NavDestinationSpec spec;
  final bool selected;
  final int badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    final d = VMotion.of(context, VMotion.fastMax);
    final fg = selected ? c.textPrimary : c.textDisabled;
    return Pressable(
      onTap: onTap,
      selected: selected,
      borderRadius: VRadius.containerR,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: d,
                curve: VMotion.standard,
                width: selected ? 44 : 32,
                height: 26,
                decoration: BoxDecoration(
                  color: selected ? c.brandSoft : Colors.transparent,
                  borderRadius: VRadius.fullR,
                  border: Border.all(
                    color: selected
                        ? c.brand.withValues(alpha: 0.45)
                        : Colors.transparent,
                  ),
                ),
                child: Icon(spec.icon, size: VSize.iconSm, color: fg),
              ),
              Positioned(
                right: -6,
                top: -5,
                child: _CountBadge(count: badge, compact: true),
              ),
            ],
          ),
          const SizedBox(height: 3),
          AnimatedDefaultTextStyle(
            duration: d,
            style: VType.supporting.copyWith(
              fontSize: 10.5,
              height: 1.2,
              color: fg,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
            child: Text(
              spec.label,
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Brand mark
// ---------------------------------------------------------------------------

/// The Vouch mark: a check whose long stroke is a voice waveform. "This
/// voice, verified." Drawn, not a font glyph, so it's ours.
class VouchMark extends StatelessWidget {
  const VouchMark({super.key, this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: c.brand,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: c.brand.withValues(alpha: 0.45),
            blurRadius: size * 0.5,
          ),
        ],
      ),
      child: CustomPaint(painter: _MarkPainter(c.success)),
    );
  }
}

class _MarkPainter extends CustomPainter {
  _MarkPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.095
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    // Short arm of the check.
    final path = Path()
      ..moveTo(w * 0.24, w * 0.52)
      ..lineTo(w * 0.41, w * 0.70);
    canvas.drawPath(path, p);
    // Long arm as three rising waveform bars.
    final bars = [
      (x: 0.53, top: 0.46, bottom: 0.70),
      (x: 0.645, top: 0.34, bottom: 0.58),
      (x: 0.76, top: 0.24, bottom: 0.46),
    ];
    for (final b in bars) {
      canvas.drawLine(
        Offset(w * b.x, w * b.top),
        Offset(w * b.x, w * b.bottom),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.color != color;
}

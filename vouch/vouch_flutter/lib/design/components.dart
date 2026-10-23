import 'package:flutter/material.dart';

import 'icons.dart';
import 'motion.dart';
import 'tokens.dart';
import 'typography.dart';

/// A container surface: one hairline edge, no shadow (elevation DR3 "one
/// edge language leads"). Optional accent rail on the leading edge follows
/// the container's radius (shape DR4).
class VSurface extends StatelessWidget {
  const VSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(VSpace.s4),
    this.onTap,
    this.accent,
    this.emphasized = false,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  /// A 2px leading rail in a tier/outcome colour.
  final Color? accent;

  /// A stronger edge, for the one surface on a screen that needs attention.
  final bool emphasized;

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    Widget body = Padding(padding: padding, child: child);
    if (accent != null) {
      body = Stack(
        children: [
          body,
          Positioned(
            left: 0,
            top: VSpace.s3,
            bottom: VSpace.s3,
            child: Container(
              width: 2,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: VRadius.fullR,
              ),
            ),
          ),
        ],
      );
    }
    final box = AnimatedContainer(
      duration: VMotion.of(context, VMotion.fast),
      curve: VMotion.standard,
      decoration: BoxDecoration(
        color: color ?? c.surface,
        borderRadius: VRadius.containerR,
        border: Border.all(color: emphasized ? c.borderEmphasized : c.border),
      ),
      child: ClipRRect(borderRadius: VRadius.containerR, child: body),
    );
    if (onTap == null) return box;
    return Pressable(
      onTap: onTap,
      borderRadius: VRadius.containerR,
      scale: false,
      child: box,
    );
  }
}

/// Uppercase micro-label that names a group.
class VEyebrow extends StatelessWidget {
  const VEyebrow(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: VType.eyebrow.copyWith(color: color ?? context.v.textSecondary),
    );
  }
}

/// Section header: eyebrow + optional count + trailing slot.
class VSectionHeader extends StatelessWidget {
  const VSectionHeader(this.title, {super.key, this.count, this.trailing});

  final String title;
  final int? count;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    return Padding(
      padding: const EdgeInsets.only(bottom: VSpace.s3),
      child: Row(
        children: [
          VEyebrow(title),
          if (count != null) ...[
            const SizedBox(width: VSpace.s2),
            Text('$count', style: VType.codeSm.copyWith(color: c.textDisabled)),
          ],
          const Spacer(),
          ?trailing,
        ],
      ),
    );
  }
}

/// The page title block at the top of every tab. Deliberately not the nav
/// label (so it reads as content, not chrome).
class VPageHeader extends StatelessWidget {
  const VPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    final narrow = MediaQuery.sizeOf(context).width < 600;
    return Padding(
      padding: const EdgeInsets.only(bottom: VSpace.s8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: (narrow ? VType.h1 : VType.display3).copyWith(
                    color: c.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: VSpace.s1),
                  Text(
                    subtitle!,
                    style: VType.body.copyWith(color: c.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: VSpace.s4),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Small status pill: a tone, an optional glyph, a label.
class VBadge extends StatelessWidget {
  const VBadge({
    super.key,
    required this.label,
    required this.tone,
    this.icon,
    this.mono = false,
  });

  final String label;
  final VTone tone;
  final IconData? icon;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final style = mono
        ? VType.codeSm.copyWith(color: tone.text)
        : VType.supporting.copyWith(
            color: tone.text,
            fontWeight: FontWeight.w500,
            height: 1.3,
          );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: VSpace.s2, vertical: 3),
      decoration: BoxDecoration(color: tone.bg, borderRadius: VRadius.fullR),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: VSize.iconXs, color: tone.fg),
            const SizedBox(width: VSpace.s1),
          ],
          Text(label, style: style),
        ],
      ),
    );
  }
}

/// An icon in a quiet rounded well. Object identity, not decoration.
class VIconBox extends StatelessWidget {
  const VIconBox({
    super.key,
    required this.icon,
    this.tone,
    this.size = VSize.elementMd,
  });

  final IconData icon;
  final VTone? tone;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tone?.bg ?? c.muted,
        borderRadius: BorderRadius.circular(
          size <= VSize.elementMd ? VRadius.element : VRadius.container,
        ),
        border: tone == null ? Border.all(color: c.border) : null,
      ),
      child: Icon(
        icon,
        size: size <= VSize.elementMd ? VSize.iconSm : VSize.iconMd,
        color: tone?.fg ?? c.textSecondary,
      ),
    );
  }
}

/// Initials avatar with a role-tinted ring.
class VAvatar extends StatelessWidget {
  const VAvatar({
    super.key,
    required this.name,
    this.size = VSize.elementLg,
    this.ring,
  });

  final String name;
  final double size;
  final Color? ring;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    final initials = parts.isEmpty
        ? '?'
        : parts.length == 1
        ? parts.first.characters.first.toUpperCase()
        : '${parts.first.characters.first}${parts.last.characters.first}'
              .toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: c.surfaceRaised,
        border: Border.all(
          color: ring ?? c.borderEmphasized,
          width: ring != null ? 1.5 : 1,
        ),
      ),
      child: Text(
        initials,
        style: VType.label.copyWith(
          color: c.textPrimary,
          fontSize: size * 0.36,
          height: 1,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// A thin determinate meter that animates to its value.
class VMeter extends StatelessWidget {
  const VMeter({
    super.key,
    required this.value,
    required this.color,
    this.height = 4,
  });

  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    return ClipRRect(
      borderRadius: VRadius.fullR,
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: c.track)),
            TweenAnimationBuilder<double>(
              tween: Tween(end: value.clamp(0, 1)),
              duration: VMotion.of(context, VMotion.medium),
              curve: VMotion.standard,
              builder: (context, v, _) => FractionallySizedBox(
                widthFactor: v,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: VRadius.fullR,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty and error states: calm, specific, with one next step.
class VEmptyState extends StatelessWidget {
  const VEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.body,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    return FadeSlideIn(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: VSpace.s12,
          horizontal: VSpace.s6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            VIconBox(icon: icon, size: VSize.elementXl),
            const SizedBox(height: VSpace.s4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: VType.h4.copyWith(color: c.textPrimary),
            ),
            if (body != null) ...[
              const SizedBox(height: VSpace.s1),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Text(
                  body!,
                  textAlign: TextAlign.center,
                  style: VType.body.copyWith(color: c.textSecondary),
                ),
              ),
            ],
            if (action != null) ...[const SizedBox(height: VSpace.s4), action!],
          ],
        ),
      ),
    );
  }
}

/// An inline error line: glyph + text in the error tone. Quiet, never a
/// full-bleed alert.
class VInlineError extends StatelessWidget {
  const VInlineError(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    return FadeSlideIn(
      offset: 4,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(VIcons.warn, size: VSize.iconSm, color: c.error),
          ),
          const SizedBox(width: VSpace.s2),
          Expanded(
            child: Text(
              message,
              style: VType.body.copyWith(color: c.errorText),
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton rows standing in for a list while it loads.
class VListSkeleton extends StatelessWidget {
  const VListSkeleton({super.key, this.rows = 4});

  final int rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < rows; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: VSpace.s2),
            child: VSurface(
              child: Row(
                children: [
                  const Skeleton(
                    width: 32,
                    height: 32,
                    radius: VRadius.element,
                  ),
                  const SizedBox(width: VSpace.s3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FractionallySizedBox(
                          widthFactor: 0.7 - (i % 3) * 0.12,
                          child: const Skeleton(height: 12),
                        ),
                        const SizedBox(height: VSpace.s2),
                        const FractionallySizedBox(
                          widthFactor: 0.3,
                          child: Skeleton(height: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Standard scrolling page body: max reading width, responsive gutters.
class VPage extends StatelessWidget {
  const VPage({
    super.key,
    required this.children,
    this.onRefresh,
    this.maxWidth = 960,
  });

  final List<Widget> children;
  final Future<void> Function()? onRefresh;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 600;
    final list = ListView(
      padding: EdgeInsets.fromLTRB(
        narrow ? VSpace.gutterNarrow : VSpace.s10,
        narrow ? VSpace.s6 : VSpace.s10,
        narrow ? VSpace.gutterNarrow : VSpace.s10,
        VSpace.s12,
      ),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ],
    );
    if (onRefresh == null) return list;
    return RefreshIndicator(onRefresh: onRefresh!, child: list);
  }
}

/// Relative time in a compact form: "now", "4m", "2h", "3d".
String vRelativeTime(DateTime t) {
  final d = DateTime.now().toUtc().difference(t.toUtc());
  if (d.inSeconds < 45) return 'now';
  if (d.inMinutes < 60) return '${d.inMinutes}m';
  if (d.inHours < 24) return '${d.inHours}h';
  return '${d.inDays}d';
}

/// "just now", "2 min ago", "3 h ago", "2 days ago" for a timestamp.
String vAgo(DateTime t) {
  final d = DateTime.now().toUtc().difference(t.toUtc());
  if (d.inSeconds < 45) return 'just now';
  if (d.inMinutes < 60) return '${d.inMinutes < 1 ? 1 : d.inMinutes} min ago';
  if (d.inHours < 24) return '${d.inHours} h ago';
  final days = d.inDays;
  return '$days ${days == 1 ? 'day' : 'days'} ago';
}

/// The full local date and time, for tooltips: "2026-10-16 17:52:59".
String vFullStamp(DateTime t) {
  final l = t.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${l.year}-${two(l.month)}-${two(l.day)} '
      '${two(l.hour)}:${two(l.minute)}:${two(l.second)}';
}

import 'package:flutter/material.dart';
import 'package:vouch_client/vouch_client.dart';

import '../design/design.dart';

export '../design/design.dart';

/// Tier colours: T0 grey · T1 blue · T2 amber. Denials are red, but quiet (a left
/// rail, never a full-bleed alert). These are the dark-theme values. Prefer
/// `context.v` (theme-aware) in new code.
class VouchColors {
  const VouchColors._();

  static const Color t0 = Color(0xFF8C8A9C);
  static const Color t1 = Color(0xFF8E8BD0); // Soft Periwinkle
  static const Color t2 = Color(0xFFFFE347); // Mustard
  static const Color denyRed = Color(0xFFEF767A); // Light Coral
  static const Color allowGreen = Color(0xFF23F0C7); // Tropical Mint
}

Color tierColor(TrustTier? tier) {
  switch (tier) {
    case TrustTier.t0:
    case null:
      return VouchColors.t0;
    case TrustTier.t1:
      return VouchColors.t1;
    case TrustTier.t2:
      return VouchColors.t2;
  }
}

VTone tierTone(BuildContext context, TrustTier? tier) {
  final c = context.v;
  return switch (tier) {
    TrustTier.t1 => c.tier1,
    TrustTier.t2 => c.tier2,
    _ => c.neutral,
  };
}

String tierLabel(TrustTier? tier) {
  switch (tier) {
    case TrustTier.t0:
    case null:
      return 'Anyone';
    case TrustTier.t1:
      return 'Known voice';
    case TrustTier.t2:
      return 'Owner approves';
  }
}

/// One sentence explaining what a trust level means, for tooltips.
String tierMeaning(TrustTier? tier) => switch (tier) {
  TrustTier.t2 =>
    'Owner approves: the owner must confirm on their phone before this runs.',
  TrustTier.t1 =>
    'Known voice: Vouch must recognise an enrolled household voice.',
  _ => 'Anyone: no voice check, any speaker may do this.',
};

/// A trust tier pill. Tiers are the one place hue appears in the chrome.
/// Each tier also carries a distinct *shape* (hollow ring, filled dot, key)
/// so it never depends on colour alone.
class TierChip extends StatelessWidget {
  const TierChip({super.key, required this.tier, this.dense = false});

  final TrustTier? tier;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final tone = tierTone(context, tier);
    final dot = dense ? 5.0 : 6.0;
    return Tooltip(
      message: tierMeaning(tier),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: dense ? 6 : 8,
          vertical: dense ? 2 : 3,
        ),
        decoration: BoxDecoration(
          color: tone.bg,
          borderRadius: VRadius.fullR,
          border: Border.all(color: tone.fg.withValues(alpha: 0.28)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: dot,
              height: dot,
              decoration: BoxDecoration(
                shape: tier == TrustTier.t2
                    ? BoxShape.rectangle
                    : BoxShape.circle,
                borderRadius: tier == TrustTier.t2
                    ? BorderRadius.circular(1.5)
                    : null,
                color: tier == TrustTier.t0 || tier == null ? null : tone.fg,
                border: tier == TrustTier.t0 || tier == null
                    ? Border.all(color: tone.fg, width: 1.2)
                    : null,
              ),
            ),
            SizedBox(width: dense ? 4 : 5),
            Text(
              tierLabel(tier),
              style: VType.supporting.copyWith(
                fontWeight: FontWeight.w500,
                height: 1.3,
                color: tone.text,
                fontSize: dense ? 11 : 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A compact legend for the three trust levels, shown once on Rules and
/// Activity so the chips elsewhere need no decoding.
class TierLegend extends StatelessWidget {
  const TierLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    return Wrap(
      spacing: VSpace.s4,
      runSpacing: VSpace.s2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Trust levels',
          style: VType.eyebrow.copyWith(color: c.textDisabled),
        ),
        for (final t in TrustTier.values)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TierChip(tier: t, dense: true),
              const SizedBox(width: VSpace.s1_5),
              Text(
                switch (t) {
                  TrustTier.t0 => 'any speaker',
                  TrustTier.t1 => 'enrolled voice',
                  TrustTier.t2 => 'owner confirms',
                },
                style: VType.supporting.copyWith(color: c.textSecondary),
              ),
            ],
          ),
      ],
    );
  }
}

const _privacyTooltip =
    'Voiceprints never leave the hub. Serverpod only ever stores an '
    'opaque reference plus quality metadata — never a biometric vector.';

/// The persistent privacy chip required everywhere in the app chrome:
/// "Voiceprints stored on hub · never uploaded" (VOUCH-DESIGN.md §6.3).
class PrivacyChip extends StatelessWidget {
  const PrivacyChip({super.key, this.compact = false, this.prominent = false});

  final bool compact;

  /// A louder variant for first-run screens: success-tinted, larger text.
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final c = context.v;
    if (compact) {
      return Tooltip(
        message: _privacyTooltip,
        child: Icon(VIcons.privacy, size: VSize.iconMd, color: c.success),
      );
    }
    return Tooltip(
      message: _privacyTooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: VSpace.s3,
          vertical: VSpace.s2,
        ),
        decoration: BoxDecoration(
          color: prominent ? c.ok.bg : c.muted,
          borderRadius: VRadius.elementR,
          border: Border.all(color: prominent ? c.ok.fg : c.border),
        ),
        child: Row(
          children: [
            Icon(
              VIcons.privacy,
              size: prominent ? VSize.iconMd : VSize.iconSm,
              color: c.success,
            ),
            const SizedBox(width: VSpace.s2),
            Expanded(
              child: Text(
                'Voiceprints stored on hub · never uploaded',
                style: (prominent ? VType.label : VType.supporting).copyWith(
                  color: prominent ? c.ok.text : c.textSecondary,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A quiet denial marker: a thin red rail on the leading edge, never
/// full-bleed red (VOUCH-DESIGN.md §6.3 / §6.1 principle 5, "calm, not
/// alarmist").
class QuietDenialBorder extends StatelessWidget {
  const QuietDenialBorder({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 2,
            decoration: BoxDecoration(
              color: context.v.error,
              borderRadius: VRadius.fullR,
            ),
          ),
          const SizedBox(width: VSpace.s3),
          Expanded(child: child),
        ],
      ),
    );
  }
}

ThemeData buildVouchTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final c = dark ? VColors.dark : VColors.light;
  final text = VType.textTheme(c);

  final scheme = ColorScheme(
    brightness: brightness,
    primary: c.inverted,
    onPrimary: c.onInverted,
    secondary: c.textSecondary,
    onSecondary: c.body,
    error: c.error,
    onError: Colors.white,
    surface: c.body,
    onSurface: c.textPrimary,
    onSurfaceVariant: c.textSecondary,
    surfaceContainerLowest: c.muted,
    surfaceContainerLow: c.surface,
    surfaceContainer: c.surface,
    surfaceContainerHigh: c.surfaceRaised,
    surfaceContainerHighest: c.surfaceRaised,
    outline: c.borderEmphasized,
    outlineVariant: c.border,
    shadow: c.shadow,
    inverseSurface: c.inverted,
    onInverseSurface: c.onInverted,
    surfaceTint: Colors.transparent,
  );

  WidgetStateProperty<T> states<T>(
    T normal, {
    T? disabled,
    T? hovered,
    T? pressed,
  }) => WidgetStateProperty.resolveWith((s) {
    if (s.contains(WidgetState.disabled) && disabled != null) return disabled;
    if (s.contains(WidgetState.pressed) && pressed != null) return pressed;
    if (s.contains(WidgetState.hovered) && hovered != null) return hovered;
    return normal;
  });

  final buttonShape = WidgetStatePropertyAll<OutlinedBorder>(
    RoundedRectangleBorder(borderRadius: VRadius.elementR),
  );
  const buttonPadding = WidgetStatePropertyAll(
    EdgeInsets.symmetric(horizontal: VSpace.s4, vertical: VSpace.s2),
  );
  final buttonText = WidgetStatePropertyAll(VType.label);
  const buttonSize = WidgetStatePropertyAll(Size(64, VSize.elementLg));
  const buttonIcon = WidgetStatePropertyAll(VSize.iconSm);

  final inputBorder = OutlineInputBorder(
    borderRadius: VRadius.elementR,
    borderSide: BorderSide(color: c.border),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    extensions: [c],
    textTheme: text,
    scaffoldBackgroundColor: c.body,
    canvasColor: c.body,
    dividerColor: c.border,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    hoverColor: c.overlayHover,
    focusColor: c.overlayPressed,
    visualDensity: VisualDensity.standard,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    iconTheme: IconThemeData(color: c.textSecondary, size: VSize.iconSm),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
      },
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: c.body,
      foregroundColor: c.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: VType.h4.copyWith(color: c.textPrimary),
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: VRadius.containerR,
        side: BorderSide(color: c.border),
      ),
    ),
    dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        backgroundColor: states(c.inverted, disabled: c.overlayPressed),
        foregroundColor: states(c.onInverted, disabled: c.textDisabled),
        overlayColor: states(
          Colors.transparent,
          hovered: c.onInverted.withValues(alpha: 0.08),
          pressed: c.onInverted.withValues(alpha: 0.14),
        ),
        shape: buttonShape,
        padding: buttonPadding,
        textStyle: buttonText,
        minimumSize: buttonSize,
        iconSize: buttonIcon,
        elevation: const WidgetStatePropertyAll(0),
        animationDuration: VMotion.fast,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: states(c.textPrimary, disabled: c.textDisabled),
        overlayColor: states(
          Colors.transparent,
          hovered: c.overlayHover,
          pressed: c.overlayPressed,
        ),
        side: states(
          BorderSide(color: c.borderEmphasized),
          disabled: BorderSide(color: c.border),
        ),
        shape: buttonShape,
        padding: buttonPadding,
        textStyle: buttonText,
        minimumSize: buttonSize,
        iconSize: buttonIcon,
        animationDuration: VMotion.fast,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: states(
          c.textSecondary,
          hovered: c.textPrimary,
          disabled: c.textDisabled,
        ),
        overlayColor: states(
          Colors.transparent,
          hovered: c.overlayHover,
          pressed: c.overlayPressed,
        ),
        shape: buttonShape,
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: VSpace.s3, vertical: VSpace.s2),
        ),
        textStyle: buttonText,
        minimumSize: const WidgetStatePropertyAll(Size(0, VSize.elementMd)),
        iconSize: buttonIcon,
        animationDuration: VMotion.fast,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        foregroundColor: states(
          c.textSecondary,
          hovered: c.textPrimary,
          disabled: c.textDisabled,
        ),
        overlayColor: states(
          Colors.transparent,
          hovered: c.overlayHover,
          pressed: c.overlayPressed,
        ),
        shape: buttonShape,
        iconSize: const WidgetStatePropertyAll(VSize.iconSm),
        minimumSize: const WidgetStatePropertyAll(
          Size(VSize.elementLg, VSize.elementLg),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.muted,
      hoverColor: Colors.transparent,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: VSpace.s3,
        vertical: VSpace.s3,
      ),
      hintStyle: VType.body.copyWith(color: c.textDisabled),
      border: inputBorder,
      enabledBorder: inputBorder,
      focusedBorder: inputBorder.copyWith(
        borderSide: BorderSide(color: c.brand, width: 1.5),
      ),
      errorBorder: inputBorder.copyWith(borderSide: BorderSide(color: c.error)),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: c.textPrimary,
      selectionColor: c.brand.withValues(alpha: 0.45),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: states(
        c.textSecondary,
        disabled: c.textDisabled,
      ).resolveWithSelected(c.onInverted),
      trackColor: states(c.track).resolveWithSelected(c.inverted),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      thumbIcon: const WidgetStatePropertyAll(null),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: states(Colors.transparent).resolveWithSelected(c.inverted),
      checkColor: WidgetStatePropertyAll(c.onInverted),
      side: BorderSide(color: c.borderEmphasized, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: VRadius.innerR),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: c.surface,
      side: BorderSide(color: c.border),
      shape: RoundedRectangleBorder(borderRadius: VRadius.fullR),
      labelStyle: VType.supporting.copyWith(color: c.textPrimary, height: 1.3),
      padding: const EdgeInsets.symmetric(horizontal: VSpace.s1, vertical: 0),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: c.textPrimary,
      linearTrackColor: c.track,
      circularTrackColor: Colors.transparent,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: c.inverted,
        borderRadius: VRadius.elementR,
      ),
      textStyle: VType.supporting.copyWith(color: c.onInverted, height: 1.4),
      padding: const EdgeInsets.symmetric(
        horizontal: VSpace.s3,
        vertical: VSpace.s2,
      ),
      waitDuration: const Duration(milliseconds: 400),
      constraints: const BoxConstraints(maxWidth: 280),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: c.inverted,
      contentTextStyle: VType.body.copyWith(color: c.onInverted),
      shape: RoundedRectangleBorder(borderRadius: VRadius.containerR),
      elevation: 0,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: c.textSecondary,
      textColor: c.textPrimary,
      titleTextStyle: VType.label.copyWith(color: c.textPrimary),
      subtitleTextStyle: VType.supporting.copyWith(color: c.textSecondary),
      shape: RoundedRectangleBorder(borderRadius: VRadius.containerR),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStatePropertyAll(c.borderEmphasized),
      radius: const Radius.circular(VRadius.full),
      thickness: const WidgetStatePropertyAll(6),
    ),
    splashColor: Colors.transparent,
  );
}

extension on WidgetStateProperty<Color> {
  WidgetStateProperty<Color> resolveWithSelected(Color selected) =>
      WidgetStateProperty.resolveWith(
        (s) =>
            s.contains(WidgetState.selected) &&
                !s.contains(WidgetState.disabled)
            ? selected
            : resolve(s),
      );
}

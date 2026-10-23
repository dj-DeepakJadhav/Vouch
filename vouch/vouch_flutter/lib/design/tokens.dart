import 'package:flutter/material.dart';

/// Vouch design tokens, a Flutter port of Astryx's core token set
/// (`packages/core/src/theme/tokens.stylex.ts`, facebook/astryx).
///
/// House rules layered on top of Astryx (see DESIGN.md next to this file):
///  * Colour is information. Chrome is grape-tinted graphite. Hue is kept
///    for trust tiers (T0 grey, T1 periwinkle, T2 mustard) and outcomes
///    (mint allowed, coral denied). Dusty Grape is the brand and appears only
///    on chrome (mark, selection, focus), never on data.
///  * The primary action is the inverted surface (near-white on dark), so it
///    can't be confused with any tier or outcome.
///  * Technical facts (tiers, confidence, hashes, countdowns) are set in mono
///    with tabular figures.

// ---------------------------------------------------------------------------
// Spacing: Astryx --spacing-* (4px grid)
// ---------------------------------------------------------------------------
abstract final class VSpace {
  static const double s0_5 = 2;
  static const double s1 = 4;
  static const double s1_5 = 6;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s8 = 32;
  static const double s10 = 40;
  static const double s12 = 48;

  /// Horizontal gutter for page content. Astryx spatial-hierarchy DR2:
  /// separation grows with grouping level (local 8 → group 16 → section 32).
  static const double gutter = 24;
  static const double gutterNarrow = 16;
}

// ---------------------------------------------------------------------------
// Radius: Astryx --radius-* (role-based, DR1 "radius follows role")
// ---------------------------------------------------------------------------
abstract final class VRadius {
  static const double inner = 4;
  static const double element = 8;
  static const double container = 12;
  static const double page = 28;
  static const double full = 9999;

  static const BorderRadius innerR = BorderRadius.all(Radius.circular(inner));
  static const BorderRadius elementR = BorderRadius.all(
    Radius.circular(element),
  );
  static const BorderRadius containerR = BorderRadius.all(
    Radius.circular(container),
  );
  static const BorderRadius fullR = BorderRadius.all(Radius.circular(full));

  /// Concentric nesting (shape-relationships DR2): inner = outer − padding.
  static double nested(double outer, double padding) =>
      (outer - padding).clamp(0, outer).toDouble();
}

// ---------------------------------------------------------------------------
// Size: Astryx --size-element-* and the icon role table (iconography DR4)
// ---------------------------------------------------------------------------
abstract final class VSize {
  static const double elementSm = 28;
  static const double elementMd = 32;
  static const double elementLg = 36;
  static const double elementXl = 44; // touch target floor

  static const double iconXs = 12; // compact indicator
  static const double iconSm = 16; // standard control
  static const double iconMd = 20; // prominent control
  static const double iconLg = 24; // display / object
}

// ---------------------------------------------------------------------------
// Motion: Astryx --duration-* and --ease-standard (motion DR2/DR3)
// ---------------------------------------------------------------------------
abstract final class VMotion {
  static const Duration fastMin = Duration(milliseconds: 130);
  static const Duration fast = Duration(milliseconds: 175);
  static const Duration fastMax = Duration(milliseconds: 230);
  static const Duration mediumMin = Duration(milliseconds: 310);
  static const Duration medium = Duration(milliseconds: 410);
  static const Duration mediumMax = Duration(milliseconds: 550);
  static const Duration slowMin = Duration(milliseconds: 730);
  static const Duration slow = Duration(milliseconds: 975);
  static const Duration slowMax = Duration(milliseconds: 1300);

  /// `cubic-bezier(0.24, 1, 0.4, 1)`: fast out, long controlled settle.
  /// No bounce, no elastic (DR3 "movement settles naturally").
  static const Curve standard = Cubic(0.24, 1, 0.4, 1);

  /// Stagger step between siblings in an entrance.
  static const Duration stagger = Duration(milliseconds: 45);

  /// Ambient (looping) motion: the hub heartbeat, the listening rings.
  /// Switched off by `test/flutter_test_config.dart` so `pumpAndSettle`
  /// can settle; always off when the platform asks for reduced motion.
  static bool ambientEnabled = true;

  /// True when the user (or the platform) asked for reduced motion.
  /// DR5: every animated transition has a no-travel form.
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  static Duration of(BuildContext context, Duration d) =>
      reduced(context) ? Duration.zero : d;
}

// ---------------------------------------------------------------------------
// Type scale: Astryx base 14 × ratio 1.2, 4px-snapped leading
// ---------------------------------------------------------------------------
abstract final class VFontSize {
  static const double xs = 10;
  static const double sm = 12;
  static const double base = 14;
  static const double lg = 17;
  static const double xl = 20;
  static const double x2l = 24;
  static const double x3l = 29;
  static const double x4l = 35;
  static const double x5l = 42;
}

// ---------------------------------------------------------------------------
// Colour: Astryx light-dark() pairs, as a ThemeExtension
// ---------------------------------------------------------------------------
@immutable
class VColors extends ThemeExtension<VColors> {
  const VColors({
    required this.body,
    required this.surface,
    required this.surfaceRaised,
    required this.muted,
    required this.overlayHover,
    required this.overlayPressed,
    required this.border,
    required this.borderEmphasized,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.inverted,
    required this.onInverted,
    required this.skeleton,
    required this.track,
    required this.shadow,
    required this.t0,
    required this.t0Bg,
    required this.t0Text,
    required this.t1,
    required this.t1Bg,
    required this.t1Text,
    required this.t2,
    required this.t2Bg,
    required this.t2Text,
    required this.success,
    required this.successBg,
    required this.successText,
    required this.error,
    required this.errorBg,
    required this.errorText,
    required this.brand,
    required this.brandSoft,
    required this.onBrand,
  });

  /// Page canvas (`--color-background-body`).
  final Color body;

  /// Cards and panels (`--color-background-surface`).
  final Color surface;

  /// Popovers, menus, the selected nav pill (`--color-background-popover`).
  final Color surfaceRaised;

  /// Wells: code blocks, input fills (`--color-background-muted`).
  final Color muted;

  final Color overlayHover;
  final Color overlayPressed;
  final Color border;
  final Color borderEmphasized;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;

  /// The primary-action surface (`--color-background-inverted`).
  final Color inverted;
  final Color onInverted;

  final Color skeleton;
  final Color track;
  final Color shadow;

  // Tiers.
  final Color t0, t0Bg, t0Text;
  final Color t1, t1Bg, t1Text;
  final Color t2, t2Bg, t2Text;

  // Outcomes.
  final Color success, successBg, successText;
  final Color error, errorBg, errorText;

  /// Brand (Dusty Grape): the mark, selection, focus. Never on data, so it
  /// can't be read as a tier.
  final Color brand;
  final Color brandSoft;
  final Color onBrand;

  // Palette: Tropical Mint #23F0C7 · Light Coral #EF767A · Soft Periwinkle
  // #7D7ABC · Dusty Grape #6457A6 · Mustard #FFE347. The graphite neutrals
  // carry a faint grape cast so the palette and the chrome read as one.
  static const dark = VColors(
    body: Color(0xFF100F14),
    surface: Color(0xFF17161D),
    surfaceRaised: Color(0xFF211F2A),
    muted: Color(0xFF0B0A0E),
    overlayHover: Color(0x0CFFFFFF),
    overlayPressed: Color(0x19FFFFFF),
    border: Color(0x17EDEBF7),
    borderEmphasized: Color(0xFF38354A),
    textPrimary: Color(0xFFECEAF3),
    textSecondary: Color(0xFFA19EB2),
    textDisabled: Color(0xFF65627A),
    inverted: Color(0xFFF3F2F8),
    onInverted: Color(0xFF0E0D12),
    skeleton: Color(0xFF262430),
    track: Color(0xFF2C2A38),
    shadow: Color(0x80000000),
    t0: Color(0xFF8C8A9C),
    t0Bg: Color(0x2E6E6B82),
    t0Text: Color(0xFFCBC9D6),
    t1: Color(0xFF8E8BD0), // Soft Periwinkle, lifted for dark contrast
    t1Bg: Color(0x2E7D7ABC),
    t1Text: Color(0xFFC3C1EE),
    t2: Color(0xFFFFE347), // Mustard
    t2Bg: Color(0x24FFE347),
    t2Text: Color(0xFFFFEC85),
    success: Color(0xFF23F0C7), // Tropical Mint
    successBg: Color(0x2123F0C7),
    successText: Color(0xFF93F8E3),
    error: Color(0xFFEF767A), // Light Coral
    errorBg: Color(0x26EF767A),
    errorText: Color(0xFFF8B3B5),
    brand: Color(0xFF6457A6), // Dusty Grape
    brandSoft: Color(0x336457A6),
    onBrand: Color(0xFFFFFFFF),
  );

  static const light = VColors(
    body: Color(0xFFF5F4F9),
    surface: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFFFFFFF),
    muted: Color(0xFFEFEEF5),
    overlayHover: Color(0x0A2A2350),
    overlayPressed: Color(0x142A2350),
    border: Color(0x1A2A2350),
    borderEmphasized: Color(0xFFD2D0E0),
    textPrimary: Color(0xFF15131F),
    textSecondary: Color(0xFF55526A),
    textDisabled: Color(0xFFA6A3B8),
    inverted: Color(0xFF15131F),
    onInverted: Color(0xFFFFFFFF),
    skeleton: Color(0xFFE6E4EF),
    track: Color(0xFFE0DEEA),
    shadow: Color(0x1A2A2350),
    t0: Color(0xFF6E6B82),
    t0Bg: Color(0x1F6E6B82),
    t0Text: Color(0xFF3A3850),
    t1: Color(0xFF5B57A6),
    t1Bg: Color(0x247D7ABC),
    t1Text: Color(0xFF38348A),
    t2: Color(0xFFC9A800),
    t2Bg: Color(0x40FFE347),
    t2Text: Color(0xFF6B5500),
    success: Color(0xFF0FA888),
    successBg: Color(0x2923F0C7),
    successText: Color(0xFF075E4D),
    error: Color(0xFFD9555A),
    errorBg: Color(0x24EF767A),
    errorText: Color(0xFF8E2226),
    brand: Color(0xFF6457A6),
    brandSoft: Color(0x1F6457A6),
    onBrand: Color(0xFFFFFFFF),
  );

  @override
  VColors copyWith() => this;

  @override
  VColors lerp(ThemeExtension<VColors>? other, double t) {
    if (other is! VColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return VColors(
      body: l(body, other.body),
      surface: l(surface, other.surface),
      surfaceRaised: l(surfaceRaised, other.surfaceRaised),
      muted: l(muted, other.muted),
      overlayHover: l(overlayHover, other.overlayHover),
      overlayPressed: l(overlayPressed, other.overlayPressed),
      border: l(border, other.border),
      borderEmphasized: l(borderEmphasized, other.borderEmphasized),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      textDisabled: l(textDisabled, other.textDisabled),
      inverted: l(inverted, other.inverted),
      onInverted: l(onInverted, other.onInverted),
      skeleton: l(skeleton, other.skeleton),
      track: l(track, other.track),
      shadow: l(shadow, other.shadow),
      t0: l(t0, other.t0),
      t0Bg: l(t0Bg, other.t0Bg),
      t0Text: l(t0Text, other.t0Text),
      t1: l(t1, other.t1),
      t1Bg: l(t1Bg, other.t1Bg),
      t1Text: l(t1Text, other.t1Text),
      t2: l(t2, other.t2),
      t2Bg: l(t2Bg, other.t2Bg),
      t2Text: l(t2Text, other.t2Text),
      success: l(success, other.success),
      successBg: l(successBg, other.successBg),
      successText: l(successText, other.successText),
      error: l(error, other.error),
      errorBg: l(errorBg, other.errorBg),
      errorText: l(errorText, other.errorText),
      brand: l(brand, other.brand),
      brandSoft: l(brandSoft, other.brandSoft),
      onBrand: l(onBrand, other.onBrand),
    );
  }
}

/// A tone: a matched foreground/background/text triple
/// (colour-emphasis DR1 "foreground and background are one decision").
@immutable
class VTone {
  const VTone(this.fg, this.bg, this.text);
  final Color fg;
  final Color bg;
  final Color text;
}

extension VContext on BuildContext {
  VColors get v =>
      Theme.of(this).extension<VColors>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? VColors.dark
          : VColors.light);
}

extension VTones on VColors {
  VTone get neutral => VTone(t0, t0Bg, t0Text);
  VTone get tier1 => VTone(t1, t1Bg, t1Text);
  VTone get tier2 => VTone(t2, t2Bg, t2Text);
  VTone get ok => VTone(success, successBg, successText);
  VTone get bad => VTone(error, errorBg, errorText);
}

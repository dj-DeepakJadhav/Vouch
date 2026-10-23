import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

/// Type roles from Astryx's type scale (base 14, ratio 1.2), set in Geist
/// (UI) and Geist Mono (facts). Display sizes use the regular weight, as
/// Astryx does, so large type reads calm rather than loud.
abstract final class VType {
  /// Off in widget tests (no network): see `test/flutter_test_config.dart`.
  static bool useGoogleFonts = true;

  static TextStyle _sans(
    double size,
    FontWeight w,
    double leading, {
    double tracking = 0,
  }) {
    final base = TextStyle(
      fontSize: size,
      fontWeight: w,
      height: leading,
      letterSpacing: tracking,
    );
    return useGoogleFonts ? GoogleFonts.geist(textStyle: base) : base;
  }

  static TextStyle _mono(double size, FontWeight w, double leading) {
    final base = TextStyle(
      fontSize: size,
      fontWeight: w,
      height: leading,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return useGoogleFonts
        ? GoogleFonts.geistMono(textStyle: base)
        : base.copyWith(fontFamily: 'monospace');
  }

  // Display: page heroes only (one per screen).
  static TextStyle get display3 =>
      _sans(VFontSize.x3l, FontWeight.w400, 1.2414, tracking: -0.6);
  static TextStyle get display2 =>
      _sans(VFontSize.x4l, FontWeight.w400, 1.2571, tracking: -0.8);

  // Headings.
  static TextStyle get h1 =>
      _sans(VFontSize.x2l, FontWeight.w600, 1.3333, tracking: -0.4);
  static TextStyle get h2 =>
      _sans(VFontSize.xl, FontWeight.w600, 1.4, tracking: -0.2);
  static TextStyle get h3 =>
      _sans(VFontSize.lg, FontWeight.w600, 1.4118, tracking: -0.1);
  static TextStyle get h4 => _sans(VFontSize.base, FontWeight.w600, 1.4286);

  // Text.
  static TextStyle get body => _sans(VFontSize.base, FontWeight.w400, 1.4286);
  static TextStyle get large => _sans(VFontSize.lg, FontWeight.w500, 1.4118);
  static TextStyle get label => _sans(VFontSize.base, FontWeight.w500, 1.4286);
  static TextStyle get supporting =>
      _sans(VFontSize.sm, FontWeight.w400, 1.6667);

  /// Uppercase micro-label above a group ("eyebrow").
  static TextStyle get eyebrow =>
      _sans(11, FontWeight.w600, 1.45, tracking: 0.9);

  // Facts.
  static TextStyle get code => _mono(VFontSize.sm, FontWeight.w500, 1.6667);
  static TextStyle get codeSm => _mono(11, FontWeight.w600, 1.45);
  static TextStyle get metric => _mono(VFontSize.x2l, FontWeight.w500, 1.3333);

  static TextTheme textTheme(VColors c) {
    TextStyle p(TextStyle s) => s.copyWith(color: c.textPrimary);
    TextStyle s2(TextStyle s) => s.copyWith(color: c.textSecondary);
    return TextTheme(
      displayLarge: p(display2),
      displayMedium: p(display3),
      displaySmall: p(h1),
      headlineLarge: p(h1),
      headlineMedium: p(h1),
      headlineSmall: p(h2),
      titleLarge: p(h2),
      titleMedium: p(h3),
      titleSmall: p(h4),
      bodyLarge: p(body),
      bodyMedium: p(body),
      bodySmall: s2(supporting),
      labelLarge: p(label),
      labelMedium: p(supporting.copyWith(fontWeight: FontWeight.w500)),
      labelSmall: s2(supporting),
    );
  }
}

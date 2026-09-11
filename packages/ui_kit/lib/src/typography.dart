import 'package:aurora_ui_kit/src/colors.dart';
import 'package:flutter/material.dart';

/// Aurora type scale (spec section 4).
///
/// Display font ships with Phase 5 font bundling; until then the names
/// below fall back to the platform default silently (no asset crash).
/// Uppercase is reserved for section labels ([labelSmall]).
abstract final class AuroraType {
  /// Display serif for Now Playing track titles.
  static const String displayFont = 'Fraunces';

  /// UI sans for everything else.
  static const String uiFont = 'Figtree';

  /// Now Playing title, 34-40 / 600.
  static const TextStyle displayLarge = TextStyle(
    fontFamily: displayFont,
    fontSize: 36,
    fontWeight: FontWeight.w600,
    height: 1.1,
    color: AuroraColors.textHi,
  );

  /// Screen + card titles, 22 / 600.
  static const TextStyle titleLarge = TextStyle(
    fontFamily: uiFont,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AuroraColors.textHi,
  );

  /// List titles, 15 / 600.
  static const TextStyle titleSmall = TextStyle(
    fontFamily: uiFont,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AuroraColors.textHi,
  );

  /// Body copy, 15 / 400.
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: uiFont,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AuroraColors.textMid,
  );

  /// Secondary rows (artist, duration), 13 / 400.
  static const TextStyle bodySmall = TextStyle(
    fontFamily: uiFont,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.35,
    color: AuroraColors.textLow,
  );

  /// Section labels ONLY: 12 / 500, 0.02em tracking, uppercase at use.
  static const TextStyle labelSmall = TextStyle(
    fontFamily: uiFont,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.24,
    color: AuroraColors.textLow,
  );

  /// Gold action text (section header links, badges).
  ///
  /// Default-gold const; prefer [actionSmallFor] with the injected
  /// theme accent so the You-tab accent setting applies.
  static const TextStyle actionSmall = TextStyle(
    fontFamily: uiFont,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AuroraColors.accent,
  );

  /// [actionSmall] tinted with the injected theme [accent].
  static TextStyle actionSmallFor(Color accent) => TextStyle(
    fontFamily: uiFont,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: accent,
  );
}

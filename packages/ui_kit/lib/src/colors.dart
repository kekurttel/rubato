import 'package:flutter/material.dart';

/// Aurora palette: "warm dark listening room" (spec section 4).
///
/// Gold ([accent]) is used sparingly — never full-width fills.
/// Artwork-derived tints may color Now Playing gradients only
/// (max 24% opacity).
abstract final class AuroraColors {
  /// Deepest background (app canvas).
  static const Color bg0 = Color(0xFF0B0C0F);

  /// Raised surfaces (scaffold sections, nav bar).
  static const Color bg1 = Color(0xFF12141A);

  /// Cards, tiles, sheets.
  static const Color bg2 = Color(0xFF1A1D26);

  /// Pressed / selected overlays, thumbs.
  static const Color bg3 = Color(0xFF232733);

  /// 1px dividers on dark surfaces.
  static const Color hairline = Color(0x14FFFFFF);

  /// Primary text (warm off-white).
  static const Color textHi = Color(0xFFF4F1EA);

  /// Secondary text.
  static const Color textMid = Color(0xFFC4C0B6);

  /// Tertiary text, timestamps, hints.
  static const Color textLow = Color(0xFF8A867C);

  /// Gold accent — sparse highlights only.
  ///
  /// This is the DEFAULT accent. The active accent is injected via
  /// `buildAuroraTheme(accent: ...)` and resolved in widgets from
  /// `Theme.of(context).colorScheme.primary`.
  static const Color accent = Color(0xFFE8B86D);

  /// Errors, destructive actions.
  static const Color danger = Color(0xFFE85D4C);

  /// Success states (download done, export ready).
  static const Color success = Color(0xFF7DCEA0);

  /// Accent at 24% — the maximum artwork-tint opacity (spec 4).
  ///
  /// Deprecated shim for the default gold only; prefer
  /// [accentWashFor] with the injected accent.
  static const Color accentWash = Color(0x3DE8B86D);

  /// Accent wash derived from the injected [accent] (24% opacity,
  /// the spec-4 maximum for artwork tints and selection indicators).
  static Color accentWashFor(Color accent) =>
      accent.withValues(alpha: 0.24);

  /// Scrim over artwork for legible foreground content.
  static const Color scrim = Color(0x990B0C0F);
}

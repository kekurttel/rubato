import 'package:flutter/material.dart';

/// Aurora motion tokens (spec section 4).
///
/// 60 fps budget: no blur on list surfaces (Now Playing scrim only),
/// no bounce-overshoot except pull-to-refresh.
abstract final class AuroraMotion {
  /// Route fade-through duration.
  static const Duration navFade = Duration(milliseconds: 220);

  /// Route fade-through curve, cubic-bezier(0.2, 0.0, 0, 1).
  static const Curve navCurve = Cubic(0.2, 0, 0, 1);

  /// Mini-player expand (shared-axis vertical) duration.
  static const Duration miniPlayerExpand = Duration(milliseconds: 280);

  /// Mini-player expand curve.
  static const Curve miniPlayerCurve = Curves.easeOutCubic;

  /// Delay before skeletons replace content (avoids flash).
  static const Duration skeletonDelay = Duration(milliseconds: 300);

  /// Like-button press scale (0.92 -> 1.0 + haptic).
  static const double likePressedScale = 0.92;

  /// Snackbars / transient UI duration.
  static const Duration transient = Duration(milliseconds: 2400);
}

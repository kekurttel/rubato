import 'dart:async';

import 'package:aurora_ui_kit/src/colors.dart';
import 'package:aurora_ui_kit/src/motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Heart toggle bound to `UserTrackStats.likeState` (-1/0/1).
///
/// Tap toggles like on/off (1 <-> 0); dislike (-1) is set from overflow
/// menus, not here. Press plays the 0.92 scale + haptic (spec 4).
class LikeButton extends StatefulWidget {
  /// Creates a like button.
  const LikeButton({
    super.key,
    this.likeState = 0,
    this.onChanged,
    this.size = 24,
  });

  /// Current state: -1 dislike, 0 none, 1 like.
  final int likeState;

  /// Called with the next state (1 when off, 0 when liked).
  final ValueChanged<int>? onChanged;

  /// Icon size.
  final double size;

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool _pressed = false;

  /// Last tapped value, shown until the parent frame catches up.
  ///
  /// The Now Playing frame only re-emits on playback events (position
  /// ticks while playing), so without this the heart would stay empty
  /// until the next tick — or indefinitely while paused.
  int? _optimistic;

  void _setPressed(bool value) {
    if (_pressed != value) {
      setState(() => _pressed = value);
    }
  }

  @override
  void didUpdateWidget(covariant LikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Parent caught up with the last tap: drop the optimistic value.
    if (_optimistic != null && widget.likeState == _optimistic) {
      _optimistic = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final liked = (_optimistic ?? widget.likeState) == 1;
    final accent = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onChanged == null
          ? null
          : () {
              unawaited(HapticFeedback.lightImpact());
              final next = liked ? 0 : 1;
              setState(() => _optimistic = next);
              widget.onChanged!(next);
            },
      child: AnimatedScale(
        scale: _pressed ? AuroraMotion.likePressedScale : 1,
        duration: const Duration(milliseconds: 120),
        child: Icon(
          liked ? Icons.favorite : Icons.favorite_border,
          size: widget.size,
          color: liked ? accent : AuroraColors.textMid,
          semanticLabel: liked ? 'Liked' : 'Like',
        ),
      ),
    );
  }
}

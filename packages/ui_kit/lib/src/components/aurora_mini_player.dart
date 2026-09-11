import 'package:aurora_ui_kit/src/colors.dart';
import 'package:aurora_ui_kit/src/components/cover_image.dart';
import 'package:aurora_ui_kit/src/components/like_button.dart';
import 'package:aurora_ui_kit/src/typography.dart';
import 'package:flutter/material.dart';

/// Persistent mini-player above the bottom bar (spec 13.9).
///
/// Fixed height 64: 48 cover, title, artist, play, like, 2px progress.
/// Tap / swipe-up opens Now Playing; horizontal swipe = prev/next.
class AuroraMiniPlayer extends StatelessWidget {
  /// Creates the mini-player.
  const AuroraMiniPlayer({
    required this.title,
    required this.artist,
    super.key,
    this.isPlaying = false,
    this.progress = 0,
    this.likeState = 0,
    this.coverImageUrl,
    this.coverLocalPath,
    this.onTap,
    this.onTogglePlay,
    this.onNext,
    this.onPrevious,
    this.onLikeChanged,
  });

  /// Current track title.
  final String title;

  /// Current track artist line.
  final String artist;

  /// Whether audio is playing (drives the play/pause icon).
  final bool isPlaying;

  /// 0..1 playback progress for the 2px bar.
  final double progress;

  /// Like state for the heart (-1/0/1).
  final int likeState;

  /// Cover artwork URL, if any.
  final String? coverImageUrl;

  /// Cover local path, if any.
  final String? coverLocalPath;

  /// Opens Now Playing.
  final VoidCallback? onTap;

  /// Toggles play/pause. Null renders the button disabled.
  final VoidCallback? onTogglePlay;

  /// Skips to next (also horizontal swipe left).
  final VoidCallback? onNext;

  /// Skips to previous (also horizontal swipe right).
  final VoidCallback? onPrevious;

  /// Like toggle callback.
  final ValueChanged<int>? onLikeChanged;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity < 0) {
          onNext?.call();
        } else if (velocity > 0) {
          onPrevious?.call();
        }
      },
      child: Material(
        color: AuroraColors.bg1,
        child: SizedBox(
          height: 64,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    CoverImage(
                      monogram: title,
                      imageUrl: coverImageUrl,
                      localPath: coverLocalPath,
                      size: 48,
                      borderRadius: 8,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AuroraType.titleSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            artist,
                            style: AuroraType.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    LikeButton(
                      likeState: likeState,
                      onChanged: onLikeChanged,
                    ),
                    IconButton(
                      onPressed: onTogglePlay,
                      icon: Icon(
                        isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_fill,
                      ),
                      iconSize: 36,
                      color: AuroraColors.textHi,
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
              LinearProgressIndicator(
                value: progress.clamp(0, 1).toDouble(),
                minHeight: 2,
                backgroundColor: AuroraColors.bg3,
                valueColor: AlwaysStoppedAnimation<Color>(accent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

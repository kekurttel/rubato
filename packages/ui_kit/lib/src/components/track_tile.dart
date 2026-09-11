import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_ui_kit/src/colors.dart';
import 'package:aurora_ui_kit/src/components/cover_image.dart';
import 'package:aurora_ui_kit/src/components/download_glyph.dart';
import 'package:aurora_ui_kit/src/typography.dart';
import 'package:flutter/material.dart';

/// Track row: cover, title, artist, duration, overflow menu (spec 4).
///
/// Streamable rows additionally expose a stream play button
/// ([onStreamTap]) and a [DownloadGlyph]; both are hidden unless their
/// callbacks/state are provided, so local-only rows stay clean.
class TrackTile extends StatelessWidget {
  /// Creates a track row.
  const TrackTile({
    required this.track,
    required this.artistLine,
    super.key,
    this.isPlaying = false,
    this.coverSize = 56,
    this.coverLocalPath,
    this.coverImageUrl,
    this.downloadState,
    this.downloadProgress = 0,
    this.onTap,
    this.onStreamTap,
    this.onDownloadTap,
    this.onOverflowTap,
  });

  /// Track to render.
  final Track track;

  /// Pre-joined artist names (repositories resolve ids to names).
  final String artistLine;

  /// Whether this track is the current player item.
  final bool isPlaying;

  /// Cover edge length (56 mini, 72 list).
  final double coverSize;

  /// On-disk cover path (local scan cache); wins over [coverImageUrl].
  final String? coverLocalPath;

  /// Remote cover URL (online tracks); monogram when absent.
  final String? coverImageUrl;

  /// Download state for the glyph. Null hides the glyph.
  final DownloadState? downloadState;

  /// 0..1 download progress.
  final double downloadProgress;

  /// Row tap (default: play).
  final VoidCallback? onTap;

  /// Stream-play button tap. Null hides the button.
  final VoidCallback? onStreamTap;

  /// Download glyph tap (retry / open). Null disables the glyph tap.
  final VoidCallback? onDownloadTap;

  /// Overflow menu tap. Null hides the menu button.
  final VoidCallback? onOverflowTap;

  /// mm:ss for display; empty when the duration is unknown.
  static String formatDuration(Duration duration) {
    if (duration.inMilliseconds <= 0) {
      return '';
    }
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final durationLabel = formatDuration(track.duration);
    final accent = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            CoverImage(
              monogram: track.title,
              imageUrl: coverImageUrl,
              localPath: coverLocalPath,
              size: coverSize,
              borderRadius: 8,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    track.title,
                    style: AuroraType.titleSmall.copyWith(
                      color: isPlaying ? accent : AuroraColors.textHi,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (isPlaying)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Icon(
                            Icons.equalizer,
                            size: 14,
                            color: accent,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          artistLine,
                          style: AuroraType.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (durationLabel.isNotEmpty)
                        Text(durationLabel, style: AuroraType.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
            if (onStreamTap != null)
              IconButton(
                onPressed: onStreamTap,
                icon: const Icon(Icons.play_arrow),
                tooltip: 'Stream',
              ),
            if (downloadState != null)
              DownloadGlyph(
                state: downloadState!,
                progress: downloadProgress,
                onTap: onDownloadTap,
              ),
            if (onOverflowTap != null)
              IconButton(
                onPressed: onOverflowTap,
                icon: const Icon(Icons.more_vert),
                tooltip: 'More actions',
              ),
          ],
        ),
      ),
    );
  }
}

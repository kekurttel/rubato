import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_downloads/aurora_downloads.dart';
import 'package:aurora_ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

/// Human label for a download [Quality] rung.
String qualityLabel(Quality quality) => switch (quality) {
  Quality.low => 'Low',
  Quality.medium => 'Medium',
  Quality.high => 'High',
  Quality.original => 'Original',
};

/// Codec/bitrate hint shown under each quality option.
String qualitySubtitle(Quality quality) => switch (quality) {
  Quality.low => 'm4a · ~128k · metered-network friendly',
  Quality.medium => 'opus · ~160k',
  Quality.high => 'm4a · ~256k · default for downloads',
  Quality.original => 'Best audio · no transcode',
};

/// Formats [duration] as `m:ss` (empty when unknown).
String formatTrackDuration(Duration duration) {
  if (duration.inMilliseconds <= 0) {
    return '';
  }
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

/// Airplane/offline pill for app bars (hidden unless [offline]).
class OfflineBadge extends StatelessWidget {
  /// Creates the badge.
  const OfflineBadge({required this.offline, super.key});

  /// Whether the device is offline (airplane / no route).
  final bool offline;

  @override
  Widget build(BuildContext context) {
    if (!offline) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AuroraColors.bg3,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.airplanemode_active,
            size: 14,
            color: AuroraColors.textMid,
            semanticLabel: 'Offline',
          ),
          SizedBox(width: 6),
          Text('Offline', style: AuroraType.labelSmall),
        ],
      ),
    );
  }
}

/// Full-width offline banner (local library + downloads only).
class OfflineBanner extends StatelessWidget {
  /// Creates the banner.
  const OfflineBanner({super.key, this.message});

  /// Override for the guidance line.
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AuroraColors.bg2,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(
            Icons.wifi_off_outlined,
            size: 18,
            color: AuroraColors.textMid,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message ??
                  'You are offline — showing your local library '
                      'and downloads.',
              style: AuroraType.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// Section header for online results with the `[Online]` badge.
class OnlineSectionHeader extends StatelessWidget {
  /// Creates the header.
  const OnlineSectionHeader({super.key, this.title = 'Online'});

  /// Section title.
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Text(title.toUpperCase(), style: AuroraType.labelSmall),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AuroraColors.accentWash,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Online',
              style: TextStyle(
                color: AuroraColors.accent,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Download quality picker (bottom sheet, returns null on dismiss).
abstract final class QualityPickerSheet {
  /// Shows the picker with [initial] selected.
  static Future<Quality?> show(
    BuildContext context, {
    required Quality initial,
  }) => showModalBottomSheet<Quality>(
    context: context,
    builder: (context) => SafeArea(
      child: RadioGroup<Quality>(
        groupValue: initial,
        onChanged: (selected) => Navigator.pop(context, selected),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('Download quality', style: AuroraType.titleSmall),
            ),
            for (final quality in Quality.values)
              RadioListTile<Quality>(
                value: quality,
                title: Text(qualityLabel(quality)),
                subtitle: Text(qualitySubtitle(quality)),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}

/// Online result row: cover, title, artist, stream + download actions.
///
/// Idle tracks (no job yet) show a download button that opens the
/// quality picker; active tracks show a [DownloadGlyph] with progress.
class OnlineTrackRow extends StatelessWidget {
  /// Creates an online row.
  const OnlineTrackRow({
    required this.track,
    required this.artistLine,
    super.key,
    this.imageUrl,
    this.downloadState,
    this.downloadProgress = 0,
    this.onStreamTap,
    this.onDownloadTap,
  });

  /// Track to render.
  final Track track;

  /// Pre-joined artist names.
  final String artistLine;

  /// Cover art URL (null falls back to the monogram tile).
  final String? imageUrl;

  /// Active job state (null = never enqueued).
  final DownloadState? downloadState;

  /// Active job progress (0..1).
  final double downloadProgress;

  /// Stream-play tap.
  final VoidCallback? onStreamTap;

  /// Download tap (picker when idle, retry/open when active).
  final VoidCallback? onDownloadTap;

  @override
  Widget build(BuildContext context) {
    final durationLabel = formatTrackDuration(track.duration);
    final state = downloadState;
    return InkWell(
      onTap: onStreamTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            CoverImage(
              monogram: track.title,
              imageUrl: imageUrl,
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
                    style: AuroraType.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
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
            if (state == null && shouldShowDownloadAction(track))
              IconButton(
                onPressed: onDownloadTap,
                icon: const Icon(Icons.download_outlined),
                tooltip: 'Download',
              )
            else if (state != null)
              DownloadGlyph(
                state: state,
                progress: downloadProgress,
                onTap: onDownloadTap,
              ),
          ],
        ),
      ),
    );
  }
}

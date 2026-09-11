import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_ui_kit/src/colors.dart';
import 'package:flutter/material.dart';

/// Download state glyph: queued / progress / done / failed (spec 4).
///
/// Tapping a failed or paused glyph retries via [onTap]; tapping a
/// completed glyph opens the downloads entry.
class DownloadGlyph extends StatelessWidget {
  /// Creates a download glyph.
  const DownloadGlyph({
    required this.state,
    super.key,
    this.progress = 0,
    this.size = 22,
    this.onTap,
  });

  /// Job lifecycle state.
  final DownloadState state;

  /// 0..1 progress for the active states.
  final double progress;

  /// Icon / indicator size.
  final double size;

  /// Tap callback (retry on failed/paused, open on completed).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final glyph = switch (state) {
      DownloadState.queued => Icon(
        Icons.schedule_outlined,
        size: size,
        color: AuroraColors.textLow,
        semanticLabel: 'Download queued',
      ),
      DownloadState.fetchingMeta => SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(strokeWidth: 2),
      ),
      DownloadState.downloading => SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          value: progress.clamp(0, 1).toDouble(),
          strokeWidth: 2,
        ),
      ),
      DownloadState.verifying => Icon(
        Icons.sync,
        size: size,
        color: accent,
        semanticLabel: 'Verifying download',
      ),
      DownloadState.completed => Icon(
        Icons.download_done,
        size: size,
        color: AuroraColors.success,
        semanticLabel: 'Downloaded',
      ),
      DownloadState.paused => Icon(
        Icons.pause_circle_outline,
        size: size,
        color: AuroraColors.textMid,
        semanticLabel: 'Download paused',
      ),
      DownloadState.failed => Icon(
        Icons.error_outline,
        size: size,
        color: AuroraColors.danger,
        semanticLabel: 'Download failed, tap to retry',
      ),
      DownloadState.canceled => Icon(
        Icons.cancel_outlined,
        size: size,
        color: AuroraColors.textLow,
        semanticLabel: 'Download canceled',
      ),
      DownloadState.fileMissing => Icon(
        Icons.warning_amber_outlined,
        size: size,
        color: AuroraColors.danger,
        semanticLabel: 'Downloaded file missing',
      ),
    };
    if (onTap == null) {
      return glyph;
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size),
      child: Padding(padding: const EdgeInsets.all(4), child: glyph),
    );
  }
}

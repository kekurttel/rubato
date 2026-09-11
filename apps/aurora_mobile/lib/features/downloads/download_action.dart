import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_downloads/aurora_downloads.dart';
import 'package:flutter/material.dart';

/// ⬇ button that hides itself for already-on-device tracks.
///
/// Wraps the single source of truth ([shouldShowDownloadAction]):
/// local rows (`providerId == local`) and verified downloads
/// (`isDownloaded` / usable `localPath`) render as [SizedBox.shrink],
/// online tracks render the normal download [IconButton]. Row builders
/// (search online rows, detail overflows, now-playing action row)
/// should use this instead of branching on `providerId` inline so the
/// rule stays in one place; [DownloadManager.enqueue] rejects strays
/// with `downloads:already-local` as a second line of defence.
class DownloadTrackButton extends StatelessWidget {
  /// Creates the guarded download button.
  const DownloadTrackButton({
    required this.track,
    required this.onPressed,
    super.key,
  });

  /// Track the action would download.
  final Track track;

  /// Tap handler (quality picker + enqueue).
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (!shouldShowDownloadAction(track)) {
      return const SizedBox.shrink();
    }
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.download_outlined),
      tooltip: 'Download',
    );
  }
}

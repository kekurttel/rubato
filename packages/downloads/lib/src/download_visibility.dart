import 'package:aurora_core/aurora_core.dart';

/// Whether the ⬇ download action should be shown for `track`.
///
/// Hidden (false) when the track is already on-device:
/// - `providerId == 'local'` (scanned device files), or
/// - `isDownloaded` is true (verified queue output), or
/// - a usable `localPath` is attached (`Track.hasLocalFile`).
///
/// Visible (true) only for online tracks that still need bytes
/// (`ytdlp`/`fake` without a local file). Row builders (search online
/// rows, library download affordances, now-playing action row) must
/// consult this before rendering any download button/glyph so tapping
/// can never be nonsense; `DownloadManager.enqueue` enforces the same
/// rule with a typed error as a second line of defence.
bool shouldShowDownloadAction(Track track) {
  if (track.providerId == 'local') {
    return false;
  }
  if (track.isDownloaded) {
    return false;
  }
  if (track.hasLocalFile) {
    return false;
  }
  return true;
}

/// Short human reason why `track` is not downloadable (null = show it).
///
/// Surfaced as a snackbar when a guarded enqueue refuses the job so
/// the tap explains itself instead of silently doing nothing.
String? downloadHiddenReason(Track track) {
  if (track.providerId == 'local') {
    return 'Already on this device — no download needed';
  }
  if (track.isDownloaded || track.hasLocalFile) {
    return 'Already downloaded — find it in Library → Downloads';
  }
  return null;
}

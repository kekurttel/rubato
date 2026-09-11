/// Aurora download queue (spec section 12).
///
/// The manager owns the queued → fetchingMeta → downloading →
/// verifying → completed state machine (plus paused / canceled /
/// failed / fileMissing), wifi-only gating, `2^attempts` retries,
/// quota warnings, and size + duration verification. Actual bytes come
/// from an injected executor (the app wires the yt-dlp downloader);
/// completion flips `is_downloaded` to 1 via the tracks DAO.
library;

export 'src/download_manager.dart';
export 'src/download_notifications.dart';
export 'src/download_settings.dart';
export 'src/download_tree_channel.dart';
export 'src/download_verify.dart';
export 'src/download_visibility.dart';

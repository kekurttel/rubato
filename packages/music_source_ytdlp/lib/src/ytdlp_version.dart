/// Pinned yt-dlp version (see README "yt-dlp source (lawful-use only)").
library;

/// Pinned yt-dlp CLI version the provider is validated against.
///
/// Re-check for updates in Settings; automatic binary updates stay off
/// by default (`AuroraDefaults.ytdlpAutoUpdate` is false).
abstract final class YtdlpVersion {
  /// Pinned version string as reported by `yt-dlp --version`.
  static const String pinned = '2026.07.21';

  /// Whether [reported] (raw `yt-dlp --version` output) matches the pin.
  ///
  /// Comparison is exact after trimming; any other version should prompt
  /// the user to update or downgrade in Settings.
  static bool isPinned(String reported) => reported.trim() == pinned;
}

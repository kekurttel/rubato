import 'package:aurora_core/src/models/enums.dart';

/// Default settings (spec section 19). The settings repository persists
/// user overrides; these are the first-launch values.
abstract final class AuroraDefaults {
  /// Share of the Home mix drawn from the exploration pool.
  static const double explorationRate = 0.10;

  /// Share drawn from adjacent (familiar-but-fresh) candidates.
  static const double adjacentRate = 0.20;

  /// Share drawn from top-scored exploitation candidates.
  static const double exploitationRate = 0.70;

  /// Preference decay half-life in days.
  static const double decayHalfLifeDays = 45;

  /// MMR penalty weight for consecutive same-artist picks.
  static const double consecutiveArtistPenalty = 0.05;

  /// Downloads only on unmetered networks by default.
  static const bool wifiOnlyDownloads = true;

  /// Download queue concurrency (1..3).
  static const int downloadConcurrency = 3;

  /// Artwork disk cache budget in megabytes.
  static const int artworkCacheMb = 300;

  /// Crossfade length in milliseconds (0 = off, Phase 5 feature).
  static const int crossfadeMs = 0;

  /// Prefer gapless transitions when codec/sample-rate match.
  static const bool gapless = true;

  /// Playback speed multiplier.
  static const double speed = 1;

  /// Show explicit tracks/badges.
  static const bool showExplicit = true;

  /// Haptic feedback on likes and transport gestures.
  static const bool haptics = true;

  /// Default yt-dlp audio quality for downloads.
  static const Quality ytdlpQuality = Quality.high;

  /// Automatic yt-dlp binary updates (off by default).
  static const bool ytdlpAutoUpdate = false;

  /// Default playback mode: stream without persisting ('stream').
  static const String defaultMode = 'stream';
}

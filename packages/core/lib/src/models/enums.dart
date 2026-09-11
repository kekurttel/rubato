/// Shared domain enumerations (spec section 5).
library;

/// Where a playback originated. Recorded on every `PlayEvent` and
/// `QueueItem`; radio/stream completions weight the same as local plays
/// so on-device learning covers online listening too.
enum PlaySource {
  /// User-initiated search result playback.
  search,

  /// Recommendation surface playback.
  reco,

  /// Explicit queue playback.
  queue,

  /// Generated radio playback.
  radio,

  /// Library / playlist / album browse playback.
  library,

  /// Downloaded-file playback.
  download,

  /// "Similar to ..." playback.
  similar,

  /// Album page playback.
  album,

  /// Artist page playback.
  artist,

  /// External intent / file share.
  external,
}

/// Local-time bucket used for time-context weighting (spec 10.2).
enum TimeOfDayBucket {
  /// 00:00-05:59.
  night,

  /// 06:00-11:59.
  morning,

  /// 12:00-17:59.
  afternoon,

  /// 18:00-23:59.
  evening,
}

/// Audio quality ladder for provider resolution.
enum Quality {
  /// m4a ~128k (metered-network friendly).
  low,

  /// opus ~160k.
  medium,

  /// m4a ~256k (default for downloads).
  high,

  /// Best available audio, no transcode.
  original,
}

/// Download job lifecycle (exact state machine, spec section 12).
enum DownloadState {
  /// Waiting for a worker slot.
  queued,

  /// Resolving metadata / direct URL via the provider.
  fetchingMeta,

  /// Bytes are flowing.
  downloading,

  /// Size / hash / duration verification.
  verifying,

  /// Persisted and verifed; `is_downloaded` flips to 1.
  completed,

  /// Suspended by the user or by the Wi-Fi-only rule.
  paused,

  /// Terminal error (retry with `2^attempts` backoff, max 5).
  failed,

  /// Cancelled by the user; partial bytes discarded.
  canceled,

  /// Previously completed file vanished from disk.
  fileMissing,
}

/// Provider reachability reported to the UI (offline banner, badges).
enum ProviderHealth {
  /// Fully usable.
  online,

  /// Usable but slow / partially failing.
  degraded,

  /// Unreachable or binary missing — UI falls back to library mode.
  offline,

  /// Credentials required (future official providers).
  authRequired,

  /// Operation not supported by this provider.
  unsupported,
}

/// How `MediaHandle.uri` must be interpreted by the player.
enum MediaHandleKind {
  /// App-private or user-owned file path.
  localFile,

  /// Provider-authorized HTTPS URL (may expire, see `expiresAt`).
  authorizedStream,
}

/// Searchable entity kinds (spec section 11 tabs).
enum SearchType {
  /// Tracks (Songs tab).
  track,

  /// Artists tab.
  artist,

  /// Albums tab.
  album,

  /// Playlists tab (local only in v1).
  playlist,
}

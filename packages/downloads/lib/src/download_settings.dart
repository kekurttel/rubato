import 'package:aurora_core/aurora_core.dart';
import 'package:meta/meta.dart';

/// Download queue settings (spec sections 12 + 19).
///
/// Defaults come from [AuroraDefaults]: wifi-only on, concurrency 1,
/// quality high. Concurrency is clamped to 1..3 on construction and in
/// [copyWith] so the UI slider can never over-commit workers.
@immutable
final class DownloadSettings {
  /// Creates settings (const defaults match first-launch values).
  const DownloadSettings({
    this.wifiOnly = AuroraDefaults.wifiOnlyDownloads,
    this.quality = AuroraDefaults.ytdlpQuality,
    this.concurrency = AuroraDefaults.downloadConcurrency,
  }) : assert(
         concurrency >= 1 && concurrency <= 3,
         'Download concurrency must stay within 1..3',
       );

  /// Only download on unmetered networks (default true).
  final bool wifiOnly;

  /// yt-dlp quality rung for new jobs (default high = m4a ~256k).
  final Quality quality;

  /// Worker slots (1..3, default 1).
  final int concurrency;

  /// Copies with overrides (concurrency re-clamped to 1..3).
  DownloadSettings copyWith({
    bool? wifiOnly,
    Quality? quality,
    int? concurrency,
  }) => DownloadSettings(
    wifiOnly: wifiOnly ?? this.wifiOnly,
    quality: quality ?? this.quality,
    concurrency: concurrency == null
        ? this.concurrency
        : concurrency.clamp(1, 3),
  );
}

/// SharedPreferences key for the SAF tree URI string (custom folder).
///
/// Empty / absent means no custom folder was ever picked. The URI is
/// persisted via `takePersistableUriPermission` on the native side so
/// it survives reinstalls of the activity (but not app uninstall).
const String downloadCustomFolderUriKey = 'aurora.downloadCustomFolderUri';

/// SharedPreferences key for the custom folder display name.
///
/// Shown in the settings row subtitle; falls back to the raw URI when
/// absent (e.g. after a raw reinstall restore).
const String downloadCustomFolderNameKey = 'aurora.downloadCustomFolderName';

/// Where extracted audio files land (spec sections 12 + 19).
///
/// - [appPrivate]: app-internal files (`.../files/downloads`, the
///   historical behavior). Private to Aurora, always writable, removed
///   on uninstall.
/// - [externalMusic]: app-specific external `Music/Aurora` folder
///   (`Android/data/<pkg>/files/Music/Aurora`). Visible in file
///   managers without any storage permission (scoped-storage safe);
///   still removed on uninstall (a truly shared `Music/` collection
///   would need a native MediaStore insert, which is out of scope).
/// - [custom]: user-picked folder via the Storage Access Framework
///   (`ACTION_OPEN_DOCUMENT_TREE`). No storage permission is needed
///   (SAF grant only); bytes are staged to a temp file and then
///   streamed into the tree via `ContentResolver.openOutputStream`
///   (`aurora.player/downloads` channel `copyToTree`). Falls back to
///   [appPrivate] when the grant is revoked or missing.
enum DownloadLocation {
  /// App-internal storage (default, current behavior).
  appPrivate,

  /// App-specific external Music folder (visible in file managers).
  externalMusic,

  /// User-picked SAF tree (system folder picker, no permission).
  custom;

  /// Display title for the setting row / picker.
  String get title => switch (this) {
    DownloadLocation.appPrivate => 'App storage (private)',
    DownloadLocation.externalMusic => 'External Music/Aurora',
    DownloadLocation.custom => 'Choose a folder…',
  };

  /// One-line explanation shown under the title.
  String get blurb => switch (this) {
    DownloadLocation.appPrivate =>
      'Default — only Aurora can access these files',
    DownloadLocation.externalMusic =>
      'Visible in file managers; removed if Aurora is uninstalled',
    DownloadLocation.custom =>
      'Pick any folder via the system picker (no extra permission)',
  };

  /// Parses a persisted [name] (null when unknown).
  static DownloadLocation? fromName(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    for (final location in DownloadLocation.values) {
      if (location.name == raw) {
        return location;
      }
    }
    return null;
  }
}

/// Free-space warning level for the download directory.
enum QuotaWarning {
  /// Plenty of room (or free space is unknown on this platform).
  none,

  /// Below 10 GB free: show an info hint in Downloads settings.
  info,

  /// Below 5 GB free: warn before enqueueing large jobs.
  warning,

  /// Below 2 GB free: refuse new jobs until space is freed.
  blocked,
}

/// Free-space thresholds driving [QuotaWarning] (spec section 12).
abstract final class DownloadQuota {
  /// Info hint below this many free bytes (10 GB).
  static const int infoThresholdBytes = 10 * 1024 * 1024 * 1024;

  /// Warning below this many free bytes (5 GB).
  static const int warningThresholdBytes = 5 * 1024 * 1024 * 1024;

  /// New jobs are refused below this many free bytes (2 GB).
  static const int blockedThresholdBytes = 2 * 1024 * 1024 * 1024;

  /// Maps [freeBytes] to a warning (null = unknown → none).
  static QuotaWarning warningForFreeBytes(int? freeBytes) {
    if (freeBytes == null) {
      return QuotaWarning.none;
    }
    if (freeBytes < blockedThresholdBytes) {
      return QuotaWarning.blocked;
    }
    if (freeBytes < warningThresholdBytes) {
      return QuotaWarning.warning;
    }
    if (freeBytes < infoThresholdBytes) {
      return QuotaWarning.info;
    }
    return QuotaWarning.none;
  }
}

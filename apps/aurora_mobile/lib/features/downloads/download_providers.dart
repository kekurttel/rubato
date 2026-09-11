import 'dart:async';
import 'dart:io';

import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_downloads/aurora_downloads.dart';
import 'package:aurora_mobile/features/downloads/downloads_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Download queue boundary (null until the app lane injects it).
final Provider<DownloadsService?> downloadsServiceProvider =
    Provider<DownloadsService?>((ref) => null);

/// Wifi-only downloads (default true, spec section 19).
final StateProvider<bool> wifiOnlyDownloadsProvider = StateProvider<bool>(
  (ref) => AuroraDefaults.wifiOnlyDownloads,
);

/// Default yt-dlp quality for new downloads (default high).
final StateProvider<Quality> downloadQualityProvider = StateProvider<Quality>(
  (ref) => AuroraDefaults.ytdlpQuality,
);

/// Download queue concurrency, 1..3 (default 1).
final StateProvider<int> downloadConcurrencyProvider = StateProvider<int>(
  (ref) => AuroraDefaults.downloadConcurrency,
);

/// SharedPreferences key for the download folder choice.
const String downloadLocationPrefsKey = 'aurora.downloadLocation';

/// Resolved download folder path for the setting row (empty until the
/// location notifier restores it). For [DownloadLocation.custom] this
/// is the staging dir path; the row shows [downloadCustomNameProvider]
/// instead (see `DownloadSettingsStrip`).
final StateProvider<String> downloadLocationDirProvider = StateProvider<String>(
  (ref) => '',
);

/// Persisted SAF tree URI string for [DownloadLocation.custom]
/// (empty = none picked yet).
final StateProvider<String> downloadCustomUriProvider = StateProvider<String>(
  (ref) => '',
);

/// Display name of the picked folder for the settings row subtitle.
final StateProvider<String> downloadCustomNameProvider = StateProvider<String>(
  (ref) => '',
);

/// Active download folder choice (default app-private storage).
///
/// The persisted choice is read at startup from inside this feature
/// (no `main()` changes, same pattern as the accent restore): the
/// first watch kicks off the async restore and the state flips to the
/// saved location once it arrives.
final NotifierProvider<DownloadLocationNotifier, DownloadLocation>
downloadLocationProvider =
    NotifierProvider<DownloadLocationNotifier, DownloadLocation>(
      DownloadLocationNotifier.new,
    );

/// Holds the download folder choice + restores the persisted one.
final class DownloadLocationNotifier extends Notifier<DownloadLocation> {
  @override
  DownloadLocation build() {
    unawaited(_restore());
    return DownloadLocation.appPrivate;
  }

  /// Reads the persisted choice and applies it to the queue manager
  /// (best-effort; the app-private default stands on failure).
  ///
  /// For [DownloadLocation.custom] the SAF tree URI + display name are
  /// also restored into [downloadCustomUriProvider] /
  /// [downloadCustomNameProvider] and [DownloadTreeDestination.treeUri].
  /// A `custom` choice with no stored URI falls back to app-private so
  /// the queue never strands without a writable dir.
  Future<void> _restore() async {
    final service = ref.read(downloadsServiceProvider);
    if (service == null) {
      return;
    }
    try {
      final restored = await service.restoreDownloadLocation();
      var location = restored.$1;
      ref.read(downloadLocationDirProvider.notifier).state = restored.$2;
      if (location == DownloadLocation.custom) {
        try {
          final prefs = await SharedPreferences.getInstance();
          final uri = prefs.getString(downloadCustomFolderUriKey) ?? '';
          final name = prefs.getString(downloadCustomFolderNameKey) ?? '';
          if (uri.isEmpty) {
            location = DownloadLocation.appPrivate;
          } else {
            ref.read(downloadCustomUriProvider.notifier).state = uri;
            ref.read(downloadCustomNameProvider.notifier).state = name;
            DownloadTreeDestination.treeUri = uri;
          }
        } on Exception {
          location = DownloadLocation.appPrivate;
          DownloadTreeDestination.treeUri = null;
        }
        if (location != DownloadLocation.custom) {
          // Stale custom choice without a grant: repair to app-private.
          DownloadTreeDestination.treeUri = null;
          try {
            final path = await service.setDownloadLocation(
              DownloadLocation.appPrivate,
            );
            ref.read(downloadLocationDirProvider.notifier).state = path;
          } on Exception {
            // In-memory fallback stands.
          }
        }
      } else {
        DownloadTreeDestination.treeUri = null;
      }
      state = location;
    } on Object {
      // Persisted location is best-effort (a disposed ref throws
      // StateError here); the default stands.
    }
  }

  /// Persists [next] and applies its folder to the queue manager.
  ///
  /// [DownloadLocation.custom] without a prior [setCustomFolder] has
  /// no tree URI, so the manager stages without exporting (graceful);
  /// the picker flow must call [setCustomFolder] instead.
  Future<void> setLocation(DownloadLocation next) async {
    final service = ref.read(downloadsServiceProvider);
    if (service == null) {
      state = next;
      if (next != DownloadLocation.custom) {
        DownloadTreeDestination.treeUri = null;
      }
      return;
    }
    try {
      final path = await service.setDownloadLocation(next);
      state = next;
      ref.read(downloadLocationDirProvider.notifier).state = path;
      if (next != DownloadLocation.custom) {
        DownloadTreeDestination.treeUri = null;
      }
    } on Object {
      // The in-memory choice stands when persistence/IO fails.
      state = next;
    }
  }

  /// Persists a SAF-picked folder and switches to [DownloadLocation.custom].
  ///
  /// Stores [uri] + [displayName], points
  /// [DownloadTreeDestination.treeUri] at it for the manager export,
  /// and resolves the staging dir through the queue service.
  Future<void> setCustomFolder({
    required String uri,
    required String displayName,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(downloadCustomFolderUriKey, uri);
      await prefs.setString(downloadCustomFolderNameKey, displayName);
    } on Exception {
      // Persistence is best-effort; the in-memory switch still stands.
    }
    ref.read(downloadCustomUriProvider.notifier).state = uri;
    ref.read(downloadCustomNameProvider.notifier).state = displayName;
    DownloadTreeDestination.treeUri = uri;
    final service = ref.read(downloadsServiceProvider);
    if (service == null) {
      state = DownloadLocation.custom;
      return;
    }
    try {
      final path = await service.setDownloadLocation(
        DownloadLocation.custom,
      );
      state = DownloadLocation.custom;
      ref.read(downloadLocationDirProvider.notifier).state = path;
    } on Object {
      state = DownloadLocation.custom;
    }
  }

  /// Falls back to app-private after the tree grant is revoked.
  ///
  /// Keeps the last picked URI in prefs (so the picker can reopen
  /// there) but clears the live export so future jobs stage locally.
  /// Callers show a snackbar with the reason.
  Future<void> fallBackToAppPrivate() async {
    DownloadTreeDestination.treeUri = null;
    await setLocation(DownloadLocation.appPrivate);
  }
}

/// Resolves the on-disk folder for [location] (creating it).
///
/// `externalMusic` is the app-specific `Music/Aurora` folder under the
/// external files dir: visible in file managers, no storage permission
/// needed (scoped-storage safe). `custom` resolves to the same
/// app-private staging dir: bytes land there first, then the manager
/// exports a copy into the SAF tree via `ContentResolver` (the tree
/// itself has no `File` path). Falls back to the app-private folder
/// when external storage is unavailable (desktop, failures).
Future<Directory> resolveDownloadDir(DownloadLocation location) async {
  if (location == DownloadLocation.externalMusic) {
    try {
      final external = await getExternalStorageDirectory();
      if (external != null) {
        final dir = Directory(
          '${external.path}${Platform.pathSeparator}Music'
          '${Platform.pathSeparator}Aurora',
        );
        await dir.create(recursive: true);
        return dir;
      }
    } on Exception {
      // Fall through to the app-private folder below.
    }
  }
  final docs = await getApplicationDocumentsDirectory();
  final dir = Directory(
    '${docs.path}${Platform.pathSeparator}downloads',
  );
  await dir.create(recursive: true);
  return dir;
}

/// All jobs, newest-first (empty until the service is wired).
final StreamProvider<List<DownloadJob>> downloadJobsProvider =
    StreamProvider<List<DownloadJob>>((ref) {
      final service = ref.watch(downloadsServiceProvider);
      if (service == null) {
        return Stream<List<DownloadJob>>.value(const <DownloadJob>[]);
      }
      return service.watchJobs();
    });

/// Jobs still in flight (queued → fetchingMeta → downloading → …).
final Provider<List<DownloadJob>> activeDownloadJobsProvider =
    Provider<List<DownloadJob>>((ref) {
      final jobs = ref.watch(downloadJobsProvider).valueOrNull;
      if (jobs == null) {
        return const <DownloadJob>[];
      }
      return <DownloadJob>[
        for (final job in jobs)
          if (!job.isTerminal) job,
      ];
    });

/// Finished jobs (completed / failed / canceled / fileMissing).
final Provider<List<DownloadJob>> finishedDownloadJobsProvider =
    Provider<List<DownloadJob>>((ref) {
      final jobs = ref.watch(downloadJobsProvider).valueOrNull;
      if (jobs == null) {
        return const <DownloadJob>[];
      }
      return <DownloadJob>[
        for (final job in jobs)
          if (job.isTerminal) job,
      ];
    });

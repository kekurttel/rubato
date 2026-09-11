import 'dart:io';
import 'dart:math';

import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_database/aurora_database.dart';
import 'package:aurora_mobile/features/home/home_providers.dart';
import 'package:aurora_mobile/features/home/home_service.dart';
import 'package:aurora_mobile/features/library/library_providers.dart';
import 'package:aurora_mobile/wiring.dart';
import 'package:aurora_music_source_local/aurora_music_source_local.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences key for the artwork backfill generation.
///
/// `adb install -r` preserves the app DB: without this, fixed backfill
/// code never reprocesses rows whose artwork row already exists (or was
/// skipped by an older buggy pass). Bump [artBackfillVersion] whenever
/// the resolve lanes change; older installs force a full re-resolve of
/// missing art on the next scan/launch.
const String artBackfillPrefsKey = 'aurora.artBackfillVersion';

/// Current artwork backfill generation (bump to force reprocessing).
///
/// v2: MP4 `udta` box fix + file-byte extraction + content-URI sniff +
/// thumbnail fallback + content-URI playback lane. Any install whose
/// stored version is older re-resolves every chunk once.
const int artBackfillVersion = 2;

/// Outcome of one on-device MediaStore scan.
enum DeviceLibraryScanStatus {
  /// Rows indexed from MediaStore.
  ok,

  /// Audio permission denied (UI shows empty state + Settings button).
  denied,

  /// Unexpected failure (scan never throws; failures land here).
  error,
}

/// Summary returned by [scanDeviceLibrary].
final class DeviceLibraryScan {
  /// Creates a summary.
  const DeviceLibraryScan({
    required this.status,
    this.tracks = 0,
    this.covers = 0,
  });

  /// What happened.
  final DeviceLibraryScanStatus status;

  /// Tracks (re)indexed (0 unless [status] is [DeviceLibraryScanStatus.ok]).
  final int tracks;

  /// Tracks with a resolvable cover after this scan (0 unless [status]
  /// is [DeviceLibraryScanStatus.ok]). User-reportable without logcat:
  /// the Library UI renders `Library: N tracks, M covers`.
  final int covers;
}

/// Whether the post-first-frame auto scan already ran (auto once).
final StateProvider<bool> hasScannedProvider = StateProvider<bool>(
  (ref) => false,
);

/// Latest scan outcome (null until the first scan finishes).
final StateProvider<DeviceLibraryScan?> libraryScanStateProvider =
    StateProvider<DeviceLibraryScan?>((ref) => null);

/// Cached on-disk cover for one local track, if the scan persisted one.
///
/// Resolution follows the stored rows only (never the network): the
/// direct `local-art-<sourceTrackId>` artwork row first, then the
/// parent album's linked artwork. Null when unwired, non-local,
/// unknown, or the cached file vanished. Never throws.
final FutureProviderFamily<String?, String> localTrackArtProvider =
    FutureProvider.family<String?, String>((ref, trackId) async {
      final wiring = ref.watch(auroraWiringProvider);
      if (wiring == null) {
        return null;
      }
      return resolveLocalTrackArt(wiring.db, trackId);
    });

/// Cached on-disk cover for one album, if the scan linked one.
///
/// Follows `albums.artwork_id` into the artworks table and returns the
/// stored path only when the file still exists. Never throws.
final FutureProviderFamily<String?, String> localAlbumArtProvider =
    FutureProvider.family<String?, String>((ref, albumId) async {
      final wiring = ref.watch(auroraWiringProvider);
      if (wiring == null) {
        return null;
      }
      return resolveLocalAlbumArt(wiring.db, albumId);
    });

/// Rows upserted per Drift transaction (scan path).
const int deviceLibraryScanBatchSize = 200;

/// Release-visible diagnostic line.
///
/// `debugPrint` reaches logcat in release via the flutter print path
/// (the user's logcat already shows `I/flutter` lines), while
/// `dart:developer log(name: 'AURORA_DIAG')` is invisible without the
/// observatory — so scan/backfill diagnostics go through here.
void diag(String message) {
  debugPrint('AURORA_DIAG $message');
}

/// Indexes the on-device music library from MediaStore (spec section 7).
///
/// Flow: permission check (request once on denial; still denied →
/// `denied` so the UI shows the empty state + Settings button) →
/// `MediaStoreReader.fetchAudioFiles` → upsert artists/albums/tracks +
/// `track_artists` joins in 200-row transactions → `upsertFtsEntry` per
/// track (title/artist/album) → backfill cover art per chunk for the
/// FULL result (embedded `DATA` bytes first, `content://` byte sniff
/// second, MediaStore thumbnails third; every scan walks all rows, so
/// first installs backfill everything and rescans retry every track
/// still missing art) → fill `wiring.artistNames`.
///
/// `Track.localPath` is the `content://` URI (just_audio/ExoPlayer plays
/// `content://` directly); `durationMs` comes from MediaStore. MYT
/// `Title(_ID_)` filenames resolve to clean titles + stable ids via
/// [MediaStoreAudio]. Never throws: failures return `error`.
Future<DeviceLibraryScan> scanDeviceLibrary(AuroraWiring wiring) async {
  var photos = 'unknown';
  try {
    var access = await wiring.local.permissions.checkAudioAccess();
    if (access != LocalPermissionStatus.granted) {
      access = await wiring.local.permissions.requestAudioAccess();
    }
    if (access != LocalPermissionStatus.granted) {
      diag('device scan denied access=$access');
      return const DeviceLibraryScan(status: DeviceLibraryScanStatus.denied);
    }
    // Images grant on EVERY scan (not only inside the audio-denied
    // branch): existing users with audio already granted otherwise never
    // get prompted for READ_MEDIA_IMAGES, and MediaStore thumbnails
    // throw SecurityException. Best-effort: never gates scan success.
    try {
      photos = await wiring.local.permissions.requestImagesGrant();
    } on Object catch (_) {
      photos = 'error';
    }
    final files = await MediaStoreReader.fetchAudioFiles();
    final nowMs = wiring.clock.nowEpochMs();
    // Update-gated reprocessing: preserved DBs skip fixed lanes unless
    // the stored generation is older (see [artBackfillPrefsKey]).
    final forceArt = await _artBackfillForce();
    if (files.isEmpty) {
      diag('device scan empty files=0 forceArt=$forceArt photos=$photos');
    }
    var indexed = 0;
    var covers = 0;
    for (var i = 0; i < files.length; i += deviceLibraryScanBatchSize) {
      final chunk = files.sublist(
        i,
        min(i + deviceLibraryScanBatchSize, files.length),
      );
      indexed += await _indexChunk(wiring, chunk, nowMs);
      // Cover art lands after the rows it links (albums must exist
      // before `artwork_id` is set). Batched per chunk, never throws.
      covers += await backfillLocalArtwork(
        wiring,
        chunk,
        nowMs,
        force: forceArt,
      );
    }
    // Post-scan seam: refresh cold-start Home snapshots so a fresh
    // install is never empty (forced: the library just changed; the
    // writer still skips warm mix surfaces once real history exists).
    // Best-effort: Home must never fail the library scan (or skip the
    // version persist + cover counts below) when tracks+art landed.
    try {
      await computeColdStartHome(
        db: wiring.db,
        clock: wiring.clock,
        force: true,
      );
    } on Object {
      // Home keeps its stats fallback / hidden sections.
    }
    await _persistArtBackfillVersion();
    diag(
      'device scan ok files=${files.length} tracks=$indexed covers=$covers '
      'forceArt=$forceArt photos=$photos',
    );
    return DeviceLibraryScan(
      status: DeviceLibraryScanStatus.ok,
      tracks: indexed,
      covers: covers,
    );
  } on Object catch (e) {
    diag('device scan error cause=$e photos=$photos');
    return const DeviceLibraryScan(status: DeviceLibraryScanStatus.error);
  }
}

/// Whether the artwork backfill must ignore fresh-cache skips.
///
/// True when the stored [artBackfillPrefsKey] generation is older than
/// [artBackfillVersion] (or absent: fresh installs and pre-version
/// updates). Never throws (a prefs failure forces reprocessing once).
Future<bool> _artBackfillForce() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getInt(artBackfillPrefsKey);
    return stored == null || stored < artBackfillVersion;
  } on Exception {
    return true;
  }
}

/// Persists [artBackfillVersion] after a successful scan (never throws).
Future<void> _persistArtBackfillVersion() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(artBackfillPrefsKey, artBackfillVersion);
  } on Exception {
    // Next launch retries the force pass; scan results already landed.
  }
}

/// Refreshes library streams after a scan (the wired service re-reads
/// one-shot DAO queries, so external writes need explicit invalidation).
///
/// Also invalidates the Home snapshot providers: the post-scan cold
/// recompute above rewrote `reco_snapshots`, and Home must re-read
/// without waiting for a manual pull-to-refresh.
void invalidateLibraryAfterScan(WidgetRef ref) {
  ref
    ..invalidate(likedTracksProvider)
    ..invalidate(libraryPlaylistsProvider)
    ..invalidate(libraryAlbumsProvider)
    ..invalidate(libraryArtistsProvider)
    ..invalidate(libraryDownloadsProvider)
    ..invalidate(libraryRecentlyProvider)
    ..invalidate(localTrackArtProvider)
    ..invalidate(localAlbumArtProvider)
    ..invalidate(homeEntriesProvider)
    ..invalidate(continueListeningProvider)
    ..invalidate(homeHealthProvider);
}

/// Upserts one chunk atomically, then enriches FTS with artist/album.
Future<int> _indexChunk(
  AuroraWiring wiring,
  List<MediaStoreAudio> chunk,
  int nowMs,
) async {
  final db = wiring.db;
  final artists = <String, ArtistsCompanion>{};
  final albums = <String, AlbumsCompanion>{};
  final tracks = <TracksCompanion>[];
  final credits = <String, List<String>>{};
  final ftsTitles = <String, String>{};
  final ftsArtists = <String, String>{};
  final ftsAlbums = <String, String>{};

  for (final file in chunk) {
    final sourceTrackId = file.sourceTrackId;
    final trackId = AuroraIds.trackId('local', sourceTrackId);
    final title = file.cleanTitle;

    String? artistId;
    final artistName = file.artist?.trim();
    if (artistName != null && artistName.isNotEmpty) {
      final slug = _slug(artistName);
      artistId = AuroraIds.trackId('local', 'artist-$slug');
      artists.putIfAbsent(
        artistId,
        () => ArtistsCompanion(
          id: Value(artistId!),
          providerId: const Value('local'),
          sourceId: Value('artist-$slug'),
          name: Value(artistName),
        ),
      );
      wiring.artistNames[artistId] = artistName;
    }

    String? albumId;
    final albumTitle = file.album?.trim();
    if (albumTitle != null && albumTitle.isNotEmpty) {
      final slug = _slug(albumTitle);
      albumId = AuroraIds.trackId('local', 'album-$slug');
      albums.putIfAbsent(
        albumId,
        () => AlbumsCompanion(
          id: Value(albumId!),
          providerId: const Value('local'),
          sourceId: Value('album-$slug'),
          title: Value(albumTitle),
          year: file.year == null ? const Value.absent() : Value(file.year),
        ),
      );
    }

    tracks.add(
      TracksCompanion(
        id: Value(trackId),
        providerId: const Value('local'),
        sourceTrackId: Value(sourceTrackId),
        title: Value(title),
        durationMs: Value(file.durationMs),
        // Absent (not null) on rescans preserves download/stats-side
        // columns that MediaStore knows nothing about.
        albumId: albumId == null ? const Value.absent() : Value(albumId),
        year: file.year == null ? const Value.absent() : Value(file.year),
        localPath: Value(file.contentUri),
        createdAt: Value(nowMs),
        updatedAt: Value(nowMs),
      ),
    );
    credits[trackId] = artistId == null ? const <String>[] : <String>[artistId];
    ftsTitles[trackId] = title;
    ftsArtists[trackId] = artistName ?? '';
    ftsAlbums[trackId] = albumTitle ?? '';
  }

  await db.transaction(() async {
    if (artists.isNotEmpty) {
      await db.artistsDao.upsertAll(artists.values.toList());
    }
    if (albums.isNotEmpty) {
      await db.albumsDao.upsertAll(albums.values.toList());
    }
    if (tracks.isNotEmpty) {
      await db.tracksDao.upsertAll(tracks);
    }
    for (final entry in credits.entries) {
      await db.tracksDao.setArtists(entry.key, entry.value);
    }
  });

  // FTS triggers already indexed bare titles on insert; enrich each row
  // with its artist/album names (single rowid lookup per chunk).
  final rowIds = await _rowIdsFor(db, credits.keys.toList());
  for (final trackId in credits.keys) {
    final rowId = rowIds[trackId];
    if (rowId == null) {
      continue;
    }
    await db.searchDao.upsertFtsEntry(
      rowId: rowId,
      title: ftsTitles[trackId] ?? '',
      artistNames: ftsArtists[trackId] ?? '',
      albumTitle: ftsAlbums[trackId] ?? '',
    );
  }
  return tracks.length;
}

/// `tracks.rowid` per composite id (one query per chunk).
Future<Map<String, int>> _rowIdsFor(
  AuroraDatabase db,
  List<String> ids,
) async {
  if (ids.isEmpty) {
    return const <String, int>{};
  }
  final placeholders = List.filled(ids.length, '?').join(', ');
  final rows = await db
      .customSelect(
        'SELECT id, rowid AS rowid FROM tracks WHERE id IN ($placeholders)',
        variables: <Variable<Object>>[
          for (final id in ids) Variable<String>(id),
        ],
        readsFrom: {db.tracks},
      )
      .get();
  return <String, int>{
    for (final row in rows) row.read<String>('id'): row.read<int>('rowid'),
  };
}

/// Stable slug for deterministic artist/album ids across rescans.
String _slug(String raw) {
  final slug = raw
      .toLowerCase()
      .replaceAll(RegExp('[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  return slug.isEmpty ? 'unknown' : slug;
}

/// Artwork row id for one local track (the tracks table carries no
/// artwork column, so the id convention is the link).
String trackArtworkId(String sourceTrackId) => 'local-art-$sourceTrackId';

/// Artwork row id for one local album shelf.
String albumArtworkId(String albumSlug) => 'local-art-album-$albumSlug';

/// Backfills cover art for one scan chunk (call after [_indexChunk]).
///
/// Source priority per track: embedded art first — the `DATA` path via
/// [TagParser] when it is readable, else the same sniff through the
/// row's `content://` URI (scoped-storage-safe under the granted audio
/// permission; head window first, file tail second for `moov`-at-end
/// mp4s) — cached with the `local-<sourceTrackId>.<ext>` layout, else
/// the native `artworkFor` thumbnail (already a cached file, so it is
/// adopted in place). Unchanged art is never re-fetched: tracks whose
/// stored path still exists are skipped unless the source file grew
/// newer than the cached art (keyed by media content + source mtime,
/// no extra columns) — unless [force] is true (post-update generation
/// bump: every chunk re-resolves once so fixed lanes reprocess
/// preserved-DB rows). Every scan walks the FULL chunk it is handed,
/// and [scanDeviceLibrary] hands every chunk of the full MediaStore
/// result — first scans and reinstalls therefore backfill the whole
/// library, rescans backfill only tracks still missing art.
///
/// Persists into `artworks` (one row per track id, one row per album)
/// and links albums via `albums.artwork_id`; FTS and catalog rows are
/// untouched. Batched per chunk, off the UI isolate via async I/O,
/// never throws.
///
/// Channel contract (verified, no code change): Dart calls
/// `aurora.player/media_store`.`readAudioBytes` with
/// `{audioId, offset, length}` and `artworkFor` with
/// `{audioId, albumId?}`; `MainActivity` registers exactly those names.
/// UI refresh (verified): both scan entry points call
/// [invalidateLibraryAfterScan], which invalidates
/// [localTrackArtProvider]/[localAlbumArtProvider], so persisted art
/// repaints without a second rescan.
///
/// Returns the number of tracks in [chunk] with resolvable art after
/// this pass (retained fresh rows + newly resolved), for the
/// user-reportable `Library: N tracks, M covers` line. Never throws
/// (0 on any failure: the catalog rows above already landed).
Future<int> backfillLocalArtwork(
  AuroraWiring wiring,
  List<MediaStoreAudio> chunk,
  int nowMs, {
  bool force = false,
}) async {
  try {
    final db = wiring.db;
    final artIds = <String>[
      for (final file in chunk) trackArtworkId(file.sourceTrackId),
    ];
    final stored = force
        ? const <String, String>{}
        : await _storedTrackArt(db, artIds);
    Directory? cacheDir;
    final fresh = <String, String>{};
    final albumOfTrack = <String, String>{};
    var embeddedHits = 0;
    var embeddedFileHits = 0;
    var embeddedContentHits = 0;
    var thumbHits = 0;
    for (final file in chunk) {
      final sourceTrackId = file.sourceTrackId;
      final artId = trackArtworkId(sourceTrackId);
      final albumTitle = file.album?.trim();
      final albumId = (albumTitle == null || albumTitle.isEmpty)
          ? null
          : AuroraIds.trackId('local', 'album-${_slug(albumTitle)}');
      final known = stored[artId];
      if (!force && known != null) {
        if (await _storedArtFresh(known, file.dataPath)) {
          fresh[artId] = known;
          if (albumId != null) {
            albumOfTrack.putIfAbsent(albumId, () => known);
          }
          continue;
        }
      }
      final resolved = await _resolveTrackArt(
        file,
        () async => cacheDir ??= await _artworkCacheDir(),
      );
      if (resolved != null) {
        if (resolved.embedded) {
          embeddedHits++;
          if (resolved.viaFile) {
            embeddedFileHits++;
          } else {
            embeddedContentHits++;
          }
        } else {
          thumbHits++;
        }
        fresh[artId] = resolved.path;
        if (albumId != null) {
          albumOfTrack.putIfAbsent(albumId, () => resolved.path);
        }
      }
    }
    if (fresh.isNotEmpty) {
      await db.artworksDao.upsertAll(<ArtworksCompanion>[
        for (final entry in fresh.entries)
          ArtworksCompanion(
            id: Value(entry.key),
            localPath: Value(entry.value),
            updatedAt: Value(nowMs),
          ),
      ]);
    }
    await _linkAlbumArtwork(db, albumOfTrack, nowMs, force: force);
    diag(
      'local-art backfill scanned=${chunk.length} '
      'embedded=$embeddedHits embeddedFile=$embeddedFileHits '
      'embeddedContent=$embeddedContentHits mediastore-thumb=$thumbHits '
      'persisted=${fresh.length} albums=${albumOfTrack.length} '
      'force=$force',
    );
    return fresh.length;
  } on Exception {
    // Art is best-effort: the catalog rows above already landed.
    return 0;
  }
}

/// Resolves one track's cover path (embedded first, thumbnail second).
///
/// Embedded is tried in two lanes: the `DATA` path first (direct file
/// read), then the row's `content://` URI byte sniff (works when
/// `DATA` is null/unreadable under scoped storage, needing only the
/// granted audio permission; head window, then the file tail for
/// `moov`-at-end mp4s). Returns the path plus which source produced
/// it, or null when no source yields art. The [cacheDirOf] callback
/// lazily creates the temp artwork dir only when embedded bytes
/// actually need a home. Never throws.
Future<({String path, bool embedded, bool viaFile})?> _resolveTrackArt(
  MediaStoreAudio file,
  Future<Directory?> Function() cacheDirOf,
) async {
  try {
    final dataPath = file.dataPath;
    var readable = false;
    if (dataPath != null && dataPath.isNotEmpty) {
      // Artwork probes must not block the UI isolate (spec 15).
      // ignore: avoid_slow_async_io
      readable = await File(dataPath).exists();
    }
    if (readable && dataPath != null && dataPath.isNotEmpty) {
      final tags = await TagParser.parseFile(dataPath);
      if (tags.hasArtwork) {
        final dir = await cacheDirOf();
        if (dir != null) {
          final cached = await _cacheEmbeddedArt(
            dir,
            file.sourceTrackId,
            tags,
          );
          if (cached != null) {
            return (path: cached, embedded: true, viaFile: true);
          }
        }
      }
    }
    // `DATA` missing/unreadable (or its head-window parse missed art):
    // sniff the same bytes through the `content://` URI. Audio-read
    // permission is already granted for the scan, so no extra grant.
    final head = await MediaStoreReader.readAudioBytes(file.mediaId);
    if (head != null && head.isNotEmpty) {
      var tags = TagParser.parseBytes(head);
      if (!tags.hasArtwork &&
          head.length >= MediaStoreReader.audioBytesDefaultLength) {
        final tail = await MediaStoreReader.readAudioBytes(
          file.mediaId,
          offset: -TagParser.sniffBytes,
        );
        if (tail != null && tail.isNotEmpty) {
          final tailTags = TagParser.parseMp4(tail);
          if (tailTags.hasArtwork) {
            tags = tailTags;
          }
        }
      }
      if (tags.hasArtwork) {
        final dir = await cacheDirOf();
        if (dir != null) {
          final cached = await _cacheEmbeddedArt(
            dir,
            file.sourceTrackId,
            tags,
          );
          if (cached != null) {
            return (path: cached, embedded: true, viaFile: false);
          }
        }
      }
    }
    // No (usable) embedded art: adopt the native thumbnail file when
    // the row carries one (`loadThumbnail` returned non-null there).
    final thumb = await MediaStoreReader.artworkFor(
      file.mediaId,
      albumId: file.albumId,
    );
    if (thumb == null || thumb.isEmpty) {
      return null;
    }
    // Artwork probes must not block the UI isolate (spec 15).
    // ignore: avoid_slow_async_io
    final exists = await File(thumb).exists();
    return exists ? (path: thumb, embedded: false, viaFile: false) : null;
  } on Exception {
    return null;
  }
}

/// Caches embedded [tags] bytes beside the native thumbnails.
///
/// Mirrors the file-walk provider layout
/// (`local-<sourceTrackId>.<ext>`). A cached file with identical
/// bytes is adopted as-is (no rewrite); changed bytes overwrite.
/// Returns the absolute path, or null on any I/O error.
Future<String?> _cacheEmbeddedArt(
  Directory dir,
  String sourceTrackId,
  AudioTags tags,
) async {
  try {
    final bytes = tags.artworkBytes;
    if (bytes == null || bytes.isEmpty) {
      return null;
    }
    final ext = tags.artworkMime == 'image/png' ? 'png' : 'jpg';
    final out = File(
      '${dir.path}${Platform.pathSeparator}local-$sourceTrackId.$ext',
    );
    // Cached-art probes must not block the UI isolate (spec 15).
    // ignore: avoid_slow_async_io
    if (await out.exists() && await out.length() == bytes.length) {
      final current = await out.readAsBytes();
      if (_bytesEqual(current, bytes)) {
        return out.path;
      }
    }
    await out.writeAsBytes(bytes, flush: true);
    return out.path;
  } on Exception {
    return null;
  }
}

/// Whether the cached [artPath] is still current for [dataPath].
///
/// True when the source file is absent (nothing to key freshness on —
/// keep the stored row instead of churning) or not newer than the
/// cached art. False only when the source provably changed after the
/// art was cached, licensing one re-fetch. Never throws.
Future<bool> _storedArtFresh(String artPath, String? dataPath) async {
  try {
    if (dataPath == null || dataPath.isEmpty) {
      return true;
    }
    final source = await FileStat.stat(dataPath);
    if (source.type == FileSystemEntityType.notFound) {
      return true;
    }
    final cached = await FileStat.stat(artPath);
    if (cached.type == FileSystemEntityType.notFound) {
      return false;
    }
    return !source.modified.isAfter(cached.modified);
  } on Exception {
    return true;
  }
}

/// Stored track-art paths for [artIds] whose files still exist.
///
/// One covering query for the whole chunk; rows naming vanished files
/// are treated as missing so the rescan backfills them. Never throws.
Future<Map<String, String>> _storedTrackArt(
  AuroraDatabase db,
  List<String> artIds,
) async {
  if (artIds.isEmpty) {
    return const <String, String>{};
  }
  try {
    final placeholders = List.filled(artIds.length, '?').join(', ');
    final rows = await db
        .customSelect(
          'SELECT id, local_path AS local_path FROM artworks '
          'WHERE id IN ($placeholders)',
          variables: <Variable<Object>>[
            for (final id in artIds) Variable<String>(id),
          ],
          readsFrom: {db.artworks},
        )
        .get();
    final out = <String, String>{};
    for (final row in rows) {
      final path = row.read<String?>('local_path');
      if (path == null || path.isEmpty) {
        continue;
      }
      // Stored-art probes must not block the UI isolate (spec 15).
      // ignore: avoid_slow_async_io
      if (await File(path).exists()) {
        out[row.read<String>('id')] = path;
      }
    }
    return out;
  } on Exception {
    return const <String, String>{};
  }
}

/// Links each album in [artByAlbum] to its cover artwork.
///
/// Albums whose `artwork_id` already resolves to an existing file are
/// left alone (unless [force] re-links every album once after an
/// update); otherwise one `local-art-album-<slug>` row is upserted
/// (pointing at the first track art of that album) and the album row
/// is pointed at it. Never throws.
Future<void> _linkAlbumArtwork(
  AuroraDatabase db,
  Map<String, String> artByAlbum,
  int nowMs, {
  bool force = false,
}) async {
  try {
    final links = <ArtworksCompanion>[];
    final targets = <String, String>{};
    for (final entry in artByAlbum.entries) {
      final album = await db.albumsDao.getById(entry.key);
      if (album == null) {
        continue;
      }
      if (!force) {
        final currentId = album.artworkId;
        if (currentId != null && currentId.isNotEmpty) {
          final current = await db.artworksDao.localPathFor(currentId);
          if (current != null) {
            // Stored-art probes must not block the UI isolate (spec 15).
            // ignore: avoid_slow_async_io
            if (await File(current).exists()) {
              continue;
            }
          }
        }
      }
      final slug = album.sourceId?.replaceFirst('album-', '') ?? 'unknown';
      final artId = albumArtworkId(slug);
      links.add(
        ArtworksCompanion(
          id: Value(artId),
          localPath: Value(entry.value),
          updatedAt: Value(nowMs),
        ),
      );
      targets[entry.key] = artId;
    }
    if (links.isNotEmpty) {
      await db.artworksDao.upsertAll(links);
    }
    for (final target in targets.entries) {
      try {
        await db.albumsDao.setArtworkId(
          target.key,
          artworkId: target.value,
        );
      } on Exception {
        // One bad album link must not block the rest.
      }
    }
  } on Exception {
    // Album covers are best-effort; track art above already landed.
  }
}

/// App-cache artwork dir (`<temp>/artwork`, shared with the native
/// thumbnails). Null when the dir cannot be created.
Future<Directory?> _artworkCacheDir() async {
  try {
    final tmp = await getTemporaryDirectory();
    final dir = Directory(
      '${tmp.path}${Platform.pathSeparator}artwork',
    );
    await dir.create(recursive: true);
    return dir;
  } on Exception {
    return null;
  }
}

/// Cached on-disk cover for one track id (see [localTrackArtProvider]).
Future<String?> resolveLocalTrackArt(
  AuroraDatabase db,
  String trackId,
) async {
  try {
    final track = await db.tracksDao.getById(trackId);
    if (track == null || track.providerId != 'local') {
      return null;
    }
    final direct = await db.artworksDao.localPathFor(
      trackArtworkId(track.sourceTrackId),
    );
    final hit = await _existingFile(direct);
    if (hit != null) {
      return hit;
    }
    final albumId = track.albumId;
    if (albumId == null) {
      return null;
    }
    return resolveLocalAlbumArt(db, albumId);
  } on Exception {
    return null;
  }
}

/// Cached on-disk cover for one album id (see [localAlbumArtProvider]).
Future<String?> resolveLocalAlbumArt(
  AuroraDatabase db,
  String albumId,
) async {
  try {
    final album = await db.albumsDao.getById(albumId);
    final artId = album?.artworkId;
    if (artId == null || artId.isEmpty) {
      return null;
    }
    return _existingFile(await db.artworksDao.localPathFor(artId));
  } on Exception {
    return null;
  }
}

/// [path] when it names an existing file, else null. Never throws.
Future<String?> _existingFile(String? path) async {
  if (path == null || path.isEmpty) {
    return null;
  }
  try {
    // Stored-art probes must not block the UI isolate (spec 15).
    // ignore: avoid_slow_async_io
    return await File(path).exists() ? path : null;
  } on Exception {
    return null;
  }
}

/// Byte equality without allocating hex strings.
bool _bytesEqual(List<int> a, List<int> b) {
  if (a.length != b.length) {
    return false;
  }
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}

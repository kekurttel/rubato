import 'dart:async';
import 'dart:io';

import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_music_source/aurora_music_source.dart';
import 'package:aurora_music_source_local/src/audio_hash.dart';
import 'package:aurora_music_source_local/src/myt_filename.dart';
import 'package:aurora_music_source_local/src/permission.dart';
import 'package:aurora_music_source_local/src/tag_parser.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

/// Audio container extensions scanned (lowercase, with dot).
const Set<String> localAudioExtensions = <String>{
  '.m4a',
  '.mp3',
  '.opus',
  '.ogg',
  '.oga',
  '.flac',
  '.wav',
  '.aac',
};

/// Whether [path] is a platform URI (`content://`/`file://`) rather than
/// a raw filesystem path.
///
/// `content://` rows come from the MediaStore scan (scoped storage);
/// `file://` URIs survive DB round-trips from older installs. Both play
/// via `AudioSource.uri(Uri.parse(...))` — never `Uri.file(...)` and
/// never a `File.exists` probe. Pure (no I/O), safe in unit tests.
bool isLocalContentUri(String path) {
  final lower = path.toLowerCase();
  return lower.startsWith('content://') || lower.startsWith('file://');
}

/// Result of one library scan.
@immutable
final class LocalScanSummary {
  /// Creates a summary.
  const LocalScanSummary({
    required this.filesSeen,
    required this.tracksIndexed,
    required this.artistsIndexed,
    required this.albumsIndexed,
    required this.unreadable,
  });

  /// Audio files walked (including unreadable ones).
  final int filesSeen;

  /// Tracks (re)indexed.
  final int tracksIndexed;

  /// Distinct artists indexed.
  final int artistsIndexed;

  /// Distinct albums indexed.
  final int albumsIndexed;

  /// Files skipped after I/O errors (scan never crashes on them).
  final int unreadable;
}

/// User-owned on-device files, incl. the MYT `Title(_ID_).m4a` collection.
///
/// Scan flow: walk roots → parse tags → MYT filename fallback → hash →
/// index in memory (repositories persist via the database DAOs).
/// Permission UX goes through [permissions]; denial yields an empty
/// index (the UI shows the empty state + Settings button) instead of an
/// error. Deletions surface as `fileMissing` failures from
/// [resolvePlayable] — playback skips, the queue survives.
final class LocalFilesProvider extends MusicProvider {
  /// Creates the provider (inject fakes in tests).
  LocalFilesProvider({
    this.permissions = const PermissionHandlerAudioAccess(),
    this.artworkCacheDir,
    this.clock = const SystemClock(),
  });

  /// Permission UX hook (UI explains, then requests).
  final LocalPermissionHandler permissions;

  /// Where embedded covers are copied (null keeps them in tags only).
  final Directory? artworkCacheDir;

  /// Injectable clock for index timestamps.
  final Clock clock;

  final Map<String, Track> _tracks = <String, Track>{};
  final Map<String, Artist> _artists = <String, Artist>{};
  final Map<String, Album> _albums = <String, Album>{};
  final Map<String, String> _artworkPaths = <String, String>{};

  ProviderHealth _health = ProviderHealth.offline;
  final StreamController<ProviderHealth> _healthUpdates =
      StreamController<ProviderHealth>.broadcast();

  /// Currently indexed tracks (unmodifiable).
  List<Track> get indexedTracks => List<Track>.unmodifiable(_tracks.values);

  @override
  String get id => 'local';

  @override
  String get displayName => 'On this device';

  @override
  bool get supportsDownload => false;

  @override
  bool get supportsSearch => true;

  @override
  bool get supportsStream => true;

  @override
  Stream<ProviderHealth> health() async* {
    yield _health;
    yield* _healthUpdates.stream;
  }

  /// Scans [rootPaths] for audio files and (re)indexes them.
  ///
  /// Denied permission → empty success summary (0 files), never an
  /// error. Unreadable files are counted, not thrown.
  Future<Result<LocalScanSummary, AppError>> scanRoots(
    List<String> rootPaths,
  ) async {
    final access = await permissions.checkAudioAccess();
    if (access != LocalPermissionStatus.granted) {
      _setHealth(ProviderHealth.offline);
      return const Success(
        LocalScanSummary(
          filesSeen: 0,
          tracksIndexed: 0,
          artistsIndexed: 0,
          albumsIndexed: 0,
          unreadable: 0,
        ),
      );
    }
    var seen = 0;
    var unreadable = 0;
    for (final root in rootPaths) {
      final dir = Directory(root);
      // Scans run off the UI isolate; async I/O keeps them cancellable.
      // ignore: avoid_slow_async_io
      if (!await dir.exists()) {
        continue;
      }
      await for (final entity in dir.list(recursive: true)) {
        try {
          if (entity is! File) {
            continue;
          }
          if (!localAudioExtensions.contains(
            p.extension(entity.path).toLowerCase(),
          )) {
            continue;
          }
          seen++;
          await _indexFile(entity);
        } on Exception {
          unreadable++;
        }
      }
    }
    _setHealth(ProviderHealth.online);
    return Success(
      LocalScanSummary(
        filesSeen: seen,
        tracksIndexed: _tracks.length,
        artistsIndexed: _artists.length,
        albumsIndexed: _albums.length,
        unreadable: unreadable,
      ),
    );
  }

  /// Re-checks indexed files; returns tracks whose bytes vanished.
  ///
  /// Callers mark them `fileMissing` (DB + UI badge) without crashing.
  /// `content://`/`file://` URIs cannot be probed with `File.exists`
  /// (scoped storage): they are assumed present here — ExoPlayer reports
  /// a gone row at load time instead of a false missing badge.
  Future<List<Track>> checkMissing() async {
    final missing = <Track>[];
    for (final track in _tracks.values) {
      final path = track.localPath;
      if (path == null || path.isEmpty) {
        missing.add(track);
        continue;
      }
      if (isLocalContentUri(path)) {
        continue;
      }
      // Missing-file probes must not block the UI isolate (spec 15).
      try {
        // Single probe per check, off the UI isolate.
        // ignore: avoid_slow_async_io
        if (!await File(path).exists()) {
          missing.add(track);
        }
      } on Exception {
        missing.add(track);
      }
    }
    return missing;
  }

  /// Closes the health stream (call on dispose).
  Future<void> dispose() => _healthUpdates.close();

  Future<void> _indexFile(File file) async {
    final path = file.path;
    final base = p.basename(path);
    final tags = await TagParser.parseFile(path);
    final myt = MytFilename.parse(base);
    final hash = await AudioHash.hashFile(path);
    final title = tags.title ?? myt?.title ?? MytFilename.titleFallback(base);
    final sourceTrackId =
        myt?.sourceTrackId ??
        (hash.isNotEmpty ? 'h-$hash' : 'file-${_slug(base)}');
    final trackId = AuroraIds.trackId(id, sourceTrackId);
    final now = clock.nowUtc();

    var artistIds = const <String>[];
    String? albumId;
    final artistName = tags.artist?.trim();
    if (artistName != null && artistName.isNotEmpty) {
      final artistId = AuroraIds.trackId(id, 'artist-${_slug(artistName)}');
      artistIds = <String>[artistId];
      _artists[artistId] = Artist(
        id: artistId,
        name: artistName,
        sourceId: 'artist-${_slug(artistName)}',
        providerId: id,
      );
    }
    final albumTitle = tags.album?.trim();
    if (albumTitle != null && albumTitle.isNotEmpty) {
      albumId = AuroraIds.trackId(id, 'album-${_slug(albumTitle)}');
      _albums[albumId] = Album(
        id: albumId,
        title: albumTitle,
        providerId: id,
        sourceId: 'album-${_slug(albumTitle)}',
        artistIds: artistIds,
        year: tags.year,
      );
    }
    if (tags.hasArtwork && artworkCacheDir != null) {
      final cached = await _cacheArtwork(sourceTrackId, tags);
      if (cached != null) {
        _artworkPaths[trackId] = cached;
      }
    }
    _tracks[trackId] = Track(
      id: trackId,
      providerId: id,
      sourceTrackId: sourceTrackId,
      title: title,
      createdAt: now,
      updatedAt: now,
      artistIds: artistIds,
      albumId: albumId,
      year: tags.year,
      audioHash: hash.isEmpty ? null : hash,
      localPath: path,
    );
  }

  Future<String?> _cacheArtwork(String sourceTrackId, AudioTags tags) async {
    try {
      final dir = artworkCacheDir!;
      await dir.create(recursive: true);
      final ext = tags.artworkMime == 'image/png' ? 'png' : 'jpg';
      final out = File(p.join(dir.path, 'local-$sourceTrackId.$ext'));
      await out.writeAsBytes(tags.artworkBytes!, flush: true);
      return out.path;
    } on Exception {
      return null;
    }
  }

  void _setHealth(ProviderHealth next) {
    if (_health == next) {
      return;
    }
    _health = next;
    if (!_healthUpdates.isClosed) {
      _healthUpdates.add(next);
    }
  }

  static String _slug(String raw) {
    final slug = raw
        .toLowerCase()
        .replaceAll(RegExp('[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return slug.isEmpty ? 'unknown' : slug;
  }

  @override
  Future<Result<Artwork, AppError>> artwork(Track track) async {
    final cached = _artworkPaths[track.id];
    // Artwork probes must not block the UI isolate (spec 15).
    // ignore: avoid_slow_async_io
    if (cached != null && await File(cached).exists()) {
      return Success(
        Artwork(
          id: 'local-art-${track.sourceTrackId}',
          updatedAt: clock.nowUtc(),
          localPath: cached,
        ),
      );
    }
    final fallbackUrl = trackFallbackThumbnailUrl(track);
    if (fallbackUrl != null) {
      return Success(
        Artwork(
          id: 'local-art-${track.sourceTrackId}',
          updatedAt: clock.nowUtc(),
          url: fallbackUrl,
        ),
      );
    }
    return Failure(
      AppError(
        code: AppErrorCode.notFound,
        message: 'No cached artwork for local track',
        details: track.id,
      ),
    );
  }

  @override
  Future<Result<AlbumDetails, AppError>> getAlbum(String sourceId) async {
    final album = _albums[AuroraIds.trackId(id, sourceId)];
    if (album == null) {
      return Failure(
        AppError(
          code: AppErrorCode.notFound,
          message: 'Local album not found',
          details: sourceId,
        ),
      );
    }
    final tracks = _tracks.values
        .where((t) => t.albumId == album.id)
        .toList(growable: false);
    return Success(AlbumDetails(album: album, tracks: tracks));
  }

  @override
  Future<Result<ArtistDetails, AppError>> getArtist(String sourceId) async {
    final artist = _artists[AuroraIds.trackId(id, sourceId)];
    if (artist == null) {
      return Failure(
        AppError(
          code: AppErrorCode.notFound,
          message: 'Local artist not found',
          details: sourceId,
        ),
      );
    }
    final top = _tracks.values
        .where((t) => t.artistIds.contains(artist.id))
        .take(10)
        .toList(growable: false);
    return Success(ArtistDetails(artist: artist, topTracks: top));
  }

  @override
  Future<Result<Track, AppError>> getTrack(String sourceId) async {
    final track = _tracks[AuroraIds.trackId(id, sourceId)];
    if (track == null) {
      return Failure(
        AppError(
          code: AppErrorCode.notFound,
          message: 'Local track not found',
          details: sourceId,
        ),
      );
    }
    return Success(track);
  }

  @override
  Future<Result<MediaHandle, AppError>> resolvePlayable(
    Track track,
    Quality quality,
  ) async {
    final path = track.localPath ?? _tracks[track.id]?.localPath;
    if (path == null || path.isEmpty) {
      return Failure(
        AppError(
          code: AppErrorCode.io,
          message: 'Local file is missing; skipping without clearing the queue',
          details: 'fileMissing:${track.id}',
        ),
      );
    }
    // Device-proven: the MediaStore scan stores `content://` URIs in
    // `Track.localPath` (scoped storage, no `File` access). `File.exists`
    // is always false for them, so they must resolve without a probe —
    // just_audio/ExoPlayer plays `content://` (and `file://`) directly.
    // Never throws: an I/O error degrades to fileMissing, never an escape.
    if (isLocalContentUri(path)) {
      return Success(
        MediaHandle(
          kind: MediaHandleKind.localFile,
          uri: path,
          qualityLabel: Quality.original.name,
        ),
      );
    }
    // Resolve probes must not block the UI isolate (spec 15).
    try {
      // Single probe per resolve, off the UI isolate.
      // ignore: avoid_slow_async_io
      if (await File(path).exists()) {
        return Success(
          MediaHandle(
            kind: MediaHandleKind.localFile,
            uri: path,
            qualityLabel: Quality.original.name,
          ),
        );
      }
    } on Exception {
      // Fall through to fileMissing below.
    }
    return Failure(
      AppError(
        code: AppErrorCode.io,
        message: 'Local file is missing; skipping without clearing the queue',
        details: 'fileMissing:${track.id}',
      ),
    );
  }

  @override
  Future<Result<SearchPage, AppError>> search(SearchQuery query) async {
    final text = query.text.trim().toLowerCase();
    if (text.length < 2) {
      return const Failure(
        AppError(
          code: AppErrorCode.provider,
          message: 'Local search needs at least 2 characters',
        ),
      );
    }
    final offset = int.tryParse(query.cursor ?? '') ?? 0;
    var tracks = const <Track>[];
    var artists = const <Artist>[];
    var albums = const <Album>[];
    if (query.types.contains(SearchType.track)) {
      tracks = _page(
        _tracks.values
            .where((t) => t.title.toLowerCase().contains(text))
            .toList(growable: false),
        offset,
        query.limit,
      );
    }
    if (query.types.contains(SearchType.artist)) {
      artists = _page(
        _artists.values
            .where((a) => a.name.toLowerCase().contains(text))
            .toList(growable: false),
        offset,
        query.limit,
      );
    }
    if (query.types.contains(SearchType.album)) {
      albums = _page(
        _albums.values
            .where((a) => a.title.toLowerCase().contains(text))
            .toList(growable: false),
        offset,
        query.limit,
      );
    }
    return Success(
      SearchPage(
        providerId: id,
        fetchedAt: clock.nowUtc(),
        tracks: tracks,
        artists: artists,
        albums: albums,
      ),
    );
  }

  List<T> _page<T>(List<T> hits, int offset, int limit) {
    if (offset >= hits.length) {
      return const [];
    }
    final end = (offset + limit).clamp(0, hits.length);
    return hits.sublist(offset, end);
  }
}

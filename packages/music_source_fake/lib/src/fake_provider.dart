import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_music_source/aurora_music_source.dart';

import 'package:aurora_music_source_fake/src/fake_catalog.dart';

/// Deterministic fake provider for tests, reco, and UI goldens.
///
/// Catalog lookups never touch the network (reco T6 asserts this by
/// counting [searchCallCount]). There are no bundled audio bytes, so
/// [resolvePlayable] always fails with a clear skip-safe error instead
/// of hanging the player.
final class FakeMusicProvider extends MusicProvider {
  /// Creates the provider over [catalog] (a fresh one by default).
  FakeMusicProvider({FakeCatalog? catalog, Clock? clock})
    : _catalog = catalog ?? FakeCatalog(),
      _clock = clock ?? const SystemClock();

  final FakeCatalog _catalog;

  /// Injectable clock for `fetchedAt` timestamps.
  final Clock _clock;

  /// How often [search] was called (reco offline test hook).
  int searchCallCount = 0;

  /// How often [resolvePlayable] was called.
  int resolveCallCount = 0;

  /// The deterministic catalog (tests inspect counts + ids).
  FakeCatalog get catalog => _catalog;

  @override
  String get id => 'fake';

  @override
  String get displayName => 'Fake catalog';

  @override
  bool get supportsDownload => true;

  @override
  bool get supportsSearch => true;

  @override
  bool get supportsStream => true;

  @override
  Stream<ProviderHealth> health() async* {
    yield ProviderHealth.online;
  }

  @override
  Future<Result<Artwork, AppError>> artwork(Track track) async => Failure(
    AppError(
      code: AppErrorCode.notFound,
      message: 'Fake provider has no artwork bytes (catalog use only)',
      details: track.id,
    ),
  );

  @override
  Future<Result<AlbumDetails, AppError>> getAlbum(String sourceId) async {
    Album? found;
    for (final album in _catalog.albums) {
      if (album.sourceId == sourceId) {
        found = album;
      }
    }
    if (found == null) {
      return Failure(
        AppError(
          code: AppErrorCode.notFound,
          message: 'Fake album not found',
          details: sourceId,
        ),
      );
    }
    final album = found;
    final tracks = _catalog.tracks
        .where((t) => t.albumId == album.id)
        .toList(growable: false);
    return Success(AlbumDetails(album: album, tracks: tracks));
  }

  @override
  Future<Result<ArtistDetails, AppError>> getArtist(String sourceId) async {
    Artist? found;
    for (final artist in _catalog.artists) {
      if (artist.sourceId == sourceId) {
        found = artist;
      }
    }
    if (found == null) {
      return Failure(
        AppError(
          code: AppErrorCode.notFound,
          message: 'Fake artist not found',
          details: sourceId,
        ),
      );
    }
    final artist = found;
    final top = _catalog.tracksForArtist(artist.id).take(5).toList();
    final albums = _catalog.albums
        .where((a) => a.artistIds.contains(artist.id))
        .toList(growable: false);
    return Success(
      ArtistDetails(artist: artist, albums: albums, topTracks: top),
    );
  }

  @override
  Future<Result<Track, AppError>> getTrack(String sourceId) async {
    for (final track in _catalog.tracks) {
      if (track.sourceTrackId == sourceId) {
        return Success(track);
      }
    }
    return Failure(
      AppError(
        code: AppErrorCode.notFound,
        message: 'Fake track not found',
        details: sourceId,
      ),
    );
  }

  @override
  Future<Result<MediaHandle, AppError>> resolvePlayable(
    Track track,
    Quality quality,
  ) async {
    resolveCallCount++;
    return Failure(
      AppError(
        code: AppErrorCode.provider,
        message:
            'Fake track has no bundled audio bytes; '
            'skip it (catalog/reco use only)',
        details: track.id,
      ),
    );
  }

  @override
  Future<Result<SearchPage, AppError>> search(SearchQuery query) async {
    searchCallCount++;
    final text = query.text.trim().toLowerCase();
    if (text.length < 2) {
      return const Failure(
        AppError(
          code: AppErrorCode.provider,
          message: 'Fake search needs at least 2 characters',
        ),
      );
    }
    final wantTracks = query.types.contains(SearchType.track);
    final wantArtists = query.types.contains(SearchType.artist);
    final wantAlbums = query.types.contains(SearchType.album);
    final offset = int.tryParse(query.cursor ?? '') ?? 0;

    var tracks = const <Track>[];
    var artists = const <Artist>[];
    var albums = const <Album>[];
    if (wantTracks) {
      final hits = _catalog.tracks
          .where((t) => t.title.toLowerCase().contains(text))
          .toList(growable: false);
      tracks = _page(hits, offset, query.limit);
    }
    if (wantArtists) {
      final hits = _catalog.artists
          .where((a) => a.name.toLowerCase().contains(text))
          .toList(growable: false);
      artists = _page(hits, offset, query.limit);
    }
    if (wantAlbums) {
      final hits = _catalog.albums
          .where((a) => a.title.toLowerCase().contains(text))
          .toList(growable: false);
      albums = _page(hits, offset, query.limit);
    }
    final biggest = <int>[
      tracks.length,
      artists.length,
      albums.length,
    ].reduce((a, b) => a > b ? a : b);
    final hasMore = biggest >= query.limit;
    return Success(
      SearchPage(
        providerId: id,
        fetchedAt: _clock.nowUtc(),
        tracks: tracks,
        artists: artists,
        albums: albums,
        nextCursor: hasMore ? '${offset + query.limit}' : null,
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

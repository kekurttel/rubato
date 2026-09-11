import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_music_source/src/models.dart';
import 'package:aurora_music_source/src/music_provider.dart';

/// Registry of active music providers (spec section 7).
///
/// `local` is always present. `fake` is registered in debug builds and
/// tests. `ytdlp` is registered when its binary is available. `remote`
/// stays null in v1 (reserved for future official APIs).
final class ProviderRegistry {
  /// Creates a registry.
  ProviderRegistry({
    required this.local,
    this.fake,
    this.ytdlp,
    this.remote,
  });

  /// User-owned on-device files.
  final MusicProvider local;

  /// Deterministic fake catalog (may be null in release).
  final MusicProvider? fake;

  /// yt-dlp online provider (null when its binary is unavailable).
  final MusicProvider? ytdlp;

  /// Future official API provider (null in v1).
  final MusicProvider? remote;

  /// Every registered provider in priority order.
  List<MusicProvider> get all => <MusicProvider>[local, ?fake, ?ytdlp, ?remote];

  /// Looks up a provider by [id].
  ///
  /// Throws [AppException] with [AppErrorCode.notFound] when unknown so
  /// call sites fail loudly instead of silently picking the wrong source.
  MusicProvider byId(String id) {
    for (final provider in all) {
      if (provider.id == id) {
        return provider;
      }
    }
    throw AppException(
      AppError(
        code: AppErrorCode.notFound,
        message: 'Unknown music provider',
        details: id,
      ),
    );
  }
}

/// Placeholder for future official provider APIs (spec section 7).
///
/// Always reports [ProviderHealth.unsupported] and fails every operation
/// with [AppErrorCode.provider]. Kept so app wiring can reference a
/// `remote` slot without branching on null everywhere.
final class NoopRemoteProvider extends MusicProvider {
  /// Creates the no-op remote provider.
  NoopRemoteProvider();

  @override
  String get id => 'remote';

  @override
  String get displayName => 'Remote (coming soon)';

  @override
  bool get supportsDownload => false;

  @override
  bool get supportsSearch => false;

  @override
  bool get supportsStream => false;

  @override
  Stream<ProviderHealth> health() async* {
    yield ProviderHealth.unsupported;
  }

  AppError _unsupported(String operation) => AppError(
    code: AppErrorCode.provider,
    message: 'Remote provider is not available in v1',
    details: operation,
  );

  @override
  Future<Result<Artwork, AppError>> artwork(Track track) async =>
      Failure(_unsupported('artwork'));

  @override
  Future<Result<AlbumDetails, AppError>> getAlbum(String sourceId) async =>
      Failure(_unsupported('getAlbum'));

  @override
  Future<Result<ArtistDetails, AppError>> getArtist(String sourceId) async =>
      Failure(_unsupported('getArtist'));

  @override
  Future<Result<Track, AppError>> getTrack(String sourceId) async =>
      Failure(_unsupported('getTrack'));

  @override
  Future<Result<MediaHandle, AppError>> resolvePlayable(
    Track track,
    Quality quality,
  ) async => Failure(_unsupported('resolvePlayable'));

  @override
  Future<Result<SearchPage, AppError>> search(SearchQuery query) async =>
      Failure(_unsupported('search'));
}

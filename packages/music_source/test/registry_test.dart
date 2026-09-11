import 'package:aurora_music_source/aurora_music_source.dart';
import 'package:test/test.dart';

class _StubProvider extends MusicProvider {
  _StubProvider(this._id);

  final String _id;

  @override
  String get id => _id;

  @override
  String get displayName => _id;

  @override
  bool get supportsDownload => false;

  @override
  bool get supportsSearch => true;

  @override
  bool get supportsStream => true;

  @override
  Stream<ProviderHealth> health() async* {
    yield ProviderHealth.online;
  }

  @override
  Future<Result<Artwork, AppError>> artwork(Track track) =>
      throw UnimplementedError();

  @override
  Future<Result<AlbumDetails, AppError>> getAlbum(String sourceId) =>
      throw UnimplementedError();

  @override
  Future<Result<ArtistDetails, AppError>> getArtist(String sourceId) =>
      throw UnimplementedError();

  @override
  Future<Result<Track, AppError>> getTrack(String sourceId) =>
      throw UnimplementedError();

  @override
  Future<Result<MediaHandle, AppError>> resolvePlayable(
    Track track,
    Quality quality,
  ) => throw UnimplementedError();

  @override
  Future<Result<SearchPage, AppError>> search(SearchQuery query) =>
      throw UnimplementedError();
}

void main() {
  test('registry resolves by id and throws on unknown', () {
    final registry = ProviderRegistry(local: _StubProvider('local'));
    expect(registry.byId('local').id, 'local');
    expect(
      () => registry.byId('missing'),
      throwsA(isA<AppException>()),
    );
  });

  test('noop remote reports unsupported', () async {
    final remote = NoopRemoteProvider();
    expect(remote.supportsStream, isFalse);
    await expectLater(remote.health(), emits(ProviderHealth.unsupported));
    final result = await remote.search(
      const SearchQuery(text: 'metal'),
    );
    expect(result.isFailure, isTrue);
  });
}

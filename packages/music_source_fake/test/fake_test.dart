import 'package:aurora_music_source/aurora_music_source.dart';
import 'package:aurora_music_source_fake/aurora_music_source_fake.dart';
import 'package:test/test.dart';

void main() {
  test('catalog holds 200 tracks, 12 artists, 8 genres', () {
    final catalog = FakeCatalog();
    expect(catalog.tracks.length, 200);
    expect(catalog.artists.length, 12);
    expect(FakeCatalog.genreNames.length, 8);
    expect(
      catalog.tracks.map((t) => t.id).toSet().length,
      200,
      reason: 'track ids must be unique',
    );
  });

  test('catalog is deterministic across builds', () {
    final first = FakeCatalog();
    final second = FakeCatalog();
    expect(second.tracks.first.title, first.tracks.first.title);
    expect(second.tracks.last.id, first.tracks.last.id);
  });

  test('search filters in memory and counts calls', () async {
    final provider = FakeMusicProvider();
    final result = await provider.search(
      const SearchQuery(text: 'Silent', limit: 10),
    );
    expect(result.isSuccess, isTrue);
    expect(provider.searchCallCount, 1);
    expect(result.valueOrNull!.tracks, isNotEmpty);
  });

  test('resolvePlayable fails with a clear skip-safe error', () async {
    final provider = FakeMusicProvider();
    final track = provider.catalog.tracks.first;
    final result = await provider.resolvePlayable(track, Quality.original);
    expect(result.isFailure, isTrue);
    expect(
      result.errorOrNull!.message,
      contains('no bundled audio'),
    );
  });

  test('unknown ids return notFound', () async {
    final provider = FakeMusicProvider();
    expect(
      (await provider.getTrack('missing')).errorOrNull?.code,
      AppErrorCode.notFound,
    );
    expect(
      (await provider.getArtist('missing')).errorOrNull?.code,
      AppErrorCode.notFound,
    );
    expect(
      (await provider.getAlbum('missing')).errorOrNull?.code,
      AppErrorCode.notFound,
    );
  });
}

// Smoke-test console output only; never ships.
// ignore_for_file: avoid_print
import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_music_source_ytdlp/src/explode_client.dart';
import 'package:test/test.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

void main() {
  test('dudu manifest + url params', () async {
    final client = ExplodeClient(timeout: const Duration(seconds: 25));
    final search = await client.searchVideos(
      'TARKAN Dudu official music video',
      limit: 3,
    );
    switch (search) {
      case Failure(:final error):
        fail('search: ${error.message}');
      case Success(value: final hits):
        for (final h in hits) {
          print('HIT ${h.videoId} | ${h.title}');
        }
        final vid = hits.first.videoId;
        final yt = YoutubeExplode();
        try {
          final manifest = await yt.videos.streams
              .getManifest(vid)
              .timeout(const Duration(seconds: 25));
          final audios = manifest.audioOnly.toList();
          print('audio count: ${audios.length}');
          if (audios.isNotEmpty) {
            audios.sort(
              (a, b) =>
                  a.bitrate.bitsPerSecond.compareTo(b.bitrate.bitsPerSecond),
            );
            final uri = audios.last.url;
            print('PARAMS: ${uri.queryParameters.keys.toList()}');
            print(
              'has ratebypass: '
              "${uri.queryParameters.containsKey('ratebypass')}",
            );
            print(
              'has sig: ${uri.queryParameters.containsKey('sig')} '
              'lsig: ${uri.queryParameters.containsKey('lsig')} '
              'n: ${uri.queryParameters.containsKey('n')} '
              'pot: ${uri.queryParameters.containsKey('pot')}',
            );
          }
        } finally {
          yt.close();
        }
    }
  }, timeout: const Timeout(Duration(minutes: 3)));
}

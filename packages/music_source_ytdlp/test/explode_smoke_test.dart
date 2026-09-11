// Smoke-test console output only; never ships.
// ignore_for_file: avoid_print
import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_music_source_ytdlp/src/explode_client.dart';
import 'package:test/test.dart';

void main() {
  test('piped search + explode audio URL', () async {
    final client = ExplodeClient(timeout: const Duration(seconds: 25));
    final result = await client.searchVideos('tarkan kuzu kuzu', limit: 5);
    switch (result) {
      case Failure(:final error):
        fail('search failed: ${error.message} (${error.details})');
      case Success(value: final hits):
        expect(hits, isNotEmpty);
        for (final hit in hits) {
          print('HIT ${hit.videoId} | ${hit.title} | ${hit.uploader} | '
              '${hit.durationMs}ms');
        }
        final audio = await client.bestAudio(hits.first.videoId, Quality.low);
        switch (audio) {
          case Failure(:final error):
            fail('manifest failed: ${error.message}');
          case Success(value: final stream):
            expect(stream.url, startsWith('https://'));
            print('AUDIO ${stream.bitrateKbps}kbps ${stream.containerName}');
        }
    }
  }, timeout: const Timeout(Duration(minutes: 3)));
}

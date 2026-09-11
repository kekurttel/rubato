// Smoke-test console output only; never ships.
// ignore_for_file: avoid_print
import 'package:test/test.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

void main() {
  test('manifest resolves audio streams', () async {
    final yt = YoutubeExplode();
    try {
      final manifest = await yt.videos.streams
          .getManifest('dQw4w9WgXcQ')
          .timeout(const Duration(seconds: 25));
      final audios = manifest.audioOnly.toList();
      expect(audios, isNotEmpty);
      audios.sort(
        (a, b) => a.bitrate.bitsPerSecond.compareTo(b.bitrate.bitsPerSecond),
      );
      final top = audios.last;
      print('AUDIO count=${audios.length} top=${top.bitrate.bitsPerSecond}bps '
          '${top.container.name} ${top.url.toString().substring(0, 60)}...');
      expect(top.url.toString(), startsWith('https://'));
    } finally {
      yt.close();
    }
  }, timeout: const Timeout(Duration(minutes: 2)));
}

import 'package:aurora_music_source_local/aurora_music_source_local.dart';
import 'package:test/test.dart';

void main() {
  test('parses MYT filenames into title + stable id', () {
    final parsed = MytFilename.parse('Hello World(_aB3dEf7hI2k_).m4a');
    expect(parsed, isNotNull);
    expect(parsed!.title, 'Hello World');
    expect(parsed.sourceTrackId, 'aB3dEf7hI2k');
  });

  test('keeps real parentheses outside the suffix', () {
    final parsed = MytFilename.parse('Song (live)(_12345678901_).mp3');
    expect(parsed?.title, 'Song (live)');
    expect(parsed?.sourceTrackId, '12345678901');
  });

  test('rejects non-MYT names and falls back to basename', () {
    expect(MytFilename.parse('plain song.mp3'), isNull);
    expect(MytFilename.parse('noext'), isNull);
    expect(
      MytFilename.titleFallback('/music/plain song.mp3'),
      'plain song',
    );
  });
}

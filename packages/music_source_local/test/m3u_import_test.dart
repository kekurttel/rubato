import 'package:aurora_music_source_local/aurora_music_source_local.dart';
import 'package:test/test.dart';

void main() {
  test('empty content imports as an empty playlist, not an error', () {
    expect(M3uImport.parseContent(null), isEmpty);
    expect(M3uImport.parseContent(''), isEmpty);
    expect(M3uImport.parseContent('  \n # comment\n'), isEmpty);
  });

  test('keeps entries, attaches EXTINF titles, skips comments', () {
    const content =
        '#EXTM3U\n'
        '#EXTINF:123,First Song\n'
        '/music/first.m4a\n'
        '# a comment\n'
        '\n'
        '/music/second.mp3\n';
    final entries = M3uImport.parseContent(content);
    expect(entries.length, 2);
    expect(entries[0].location, '/music/first.m4a');
    expect(entries[0].title, 'First Song');
    expect(entries[1].location, '/music/second.mp3');
    expect(entries[1].title, isNull);
  });

  test('tolerates missing entries without crashing', () {
    const content = '/gone/song.m4a\nnot-a-path??\n';
    final entries = M3uImport.parseContent(content);
    expect(entries.length, 2);
  });
}

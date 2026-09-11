// Forbidden-import graze for packages/reco (spec section 1).
//
// Reco must never import network or UI libraries: no `http`, no
// `dio`, no Flutter (including foundation and widget libraries), and
// no yt-dlp provider internals. It reads only the database via plain
// models handed in by the app layer. This test scans every Dart file
// under `lib/` and `test/` so violations fail loudly.
//
// NOTE: only real `import`/`export` statements are matched, so this
// very comment (and the pattern source below) cannot trip the test.
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('reco has no forbidden imports', () {
    // Split literal so the pattern source never matches itself.
    const ytdlp =
        'music_source_'
        'ytdlp';
    final statement = RegExp("^\\s*(import|export)\\s+['\"]");
    final bannedSource = RegExp(
      'package:(http|dio|flutter|aurora_ui_kit)/'
      '|dart:ui'
      r'|widgets\.dart',
    );
    bool isViolation(String line) {
      if (!statement.hasMatch(line)) {
        return false;
      }
      return bannedSource.hasMatch(line) || line.contains(ytdlp);
    }

    final violations = <String>[];
    for (final root in <String>['lib', 'test']) {
      final dir = Directory(root);
      if (!dir.existsSync()) {
        continue;
      }
      final files = dir
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));
      for (final file in files) {
        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          if (isViolation(lines[i])) {
            violations.add('${file.path}:${i + 1}: ${lines[i].trim()}');
          }
        }
      }
    }
    expect(
      violations,
      isEmpty,
      reason:
          'Forbidden imports in packages/reco:\n'
          '${violations.join('\n')}',
    );
  });
}

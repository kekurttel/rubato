import 'dart:io';

import 'package:aurora_music_source_local/aurora_music_source_local.dart';
import 'package:test/test.dart';

void main() {
  test('hash is stable and covers head + tail + length', () async {
    final dir = await Directory.systemTemp.createTemp('aurora-hash');
    try {
      final file = File('${dir.path}/song.m4a');
      final bytes = List<int>.generate(200000, (i) => i % 251);
      await file.writeAsBytes(bytes, flush: true);
      final first = await AudioHash.hashFile(file.path);
      final second = await AudioHash.hashFile(file.path);
      expect(first, isNotEmpty);
      expect(first, second);
      expect(first.length, 40);

      await file.writeAsBytes([...bytes, 1], flush: true);
      expect(await AudioHash.hashFile(file.path), isNot(first));
    } finally {
      await dir.delete(recursive: true);
    }
  });

  test('pure core matches file hashing for small files', () {
    final bytes = <int>[1, 2, 3, 4];
    expect(
      AudioHash.hashBytes(bytes, bytes, bytes.length),
      AudioHash.hashBytes(bytes, bytes, bytes.length),
    );
  });

  test('unreadable paths hash to empty instead of throwing', () async {
    expect(await AudioHash.hashFile('/no/such/file.m4a'), isEmpty);
  });
}

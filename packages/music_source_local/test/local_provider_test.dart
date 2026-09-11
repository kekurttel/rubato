import 'dart:io';

import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_music_source/aurora_music_source.dart';
import 'package:aurora_music_source_local/aurora_music_source_local.dart';
import 'package:flutter_test/flutter_test.dart';

/// Grants audio access without touching platform channels.
final class _FakePermissions extends LocalPermissionHandler {
  const _FakePermissions();

  @override
  Future<LocalPermissionStatus> checkAudioAccess() async =>
      LocalPermissionStatus.granted;

  @override
  Future<LocalPermissionStatus> requestAudioAccess() async =>
      LocalPermissionStatus.granted;

  @override
  Future<bool> openSettings() async => true;
}

void main() {
  test('scan indexes MYT names with clean titles + stable ids', () async {
    final root = await Directory.systemTemp.createTemp('aurora-scan');
    try {
      await File(
        '${root.path}/Midnight Harbor(_dQw4w9WgXcQ_).m4a',
      ).writeAsBytes(List<int>.filled(1000, 7), flush: true);
      await File(
        '${root.path}/plain song.mp3',
      ).writeAsBytes(List<int>.filled(500, 3), flush: true);

      final provider = LocalFilesProvider(
        permissions: const _FakePermissions(),
      );
      addTearDown(provider.dispose);
      final result = await provider.scanRoots(<String>[root.path]);
      expect(result.isSuccess, isTrue);
      final summary = result.valueOrNull!;
      expect(summary.filesSeen, 2);
      expect(provider.indexedTracks.length, 2);

      final myt = provider.indexedTracks.firstWhere(
        (t) => t.sourceTrackId == 'dQw4w9WgXcQ',
      );
      expect(myt.title, 'Midnight Harbor');
      expect(myt.title, isNot(contains('(_')));

      final playable = await provider.resolvePlayable(myt, Quality.original);
      expect(playable.isSuccess, isTrue);
      expect(
        playable.valueOrNull!.kind,
        MediaHandleKind.localFile,
      );
    } finally {
      await root.delete(recursive: true);
    }
  });

  test('missing files fail as fileMissing without throwing', () async {
    final root = await Directory.systemTemp.createTemp('aurora-missing');
    try {
      final file = File('${root.path}/gone(_dQw4w9WgXcR_).m4a');
      await file.writeAsBytes(List<int>.filled(100, 1), flush: true);
      final provider = LocalFilesProvider(
        permissions: const _FakePermissions(),
      );
      addTearDown(provider.dispose);
      await provider.scanRoots(<String>[root.path]);
      await file.delete();

      final missing = await provider.checkMissing();
      expect(missing.length, 1);
      final result = await provider.resolvePlayable(
        missing.first,
        Quality.original,
      );
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull!.details, contains('fileMissing'));
    } finally {
      await root.delete(recursive: true);
    }
  });

  test('artwork falls back to YouTube thumbnail for 11-char ids', () async {
    final provider = LocalFilesProvider(
      permissions: const _FakePermissions(),
    );
    addTearDown(provider.dispose);
    final track = Track(
      id: 'local:dQw4w9WgXcQ',
      providerId: 'local',
      sourceTrackId: 'dQw4w9WgXcQ',
      title: 'Midnight Harbor',
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
    final artResult = await provider.artwork(track);
    expect(artResult.isSuccess, isTrue);
    expect(
      artResult.valueOrNull?.url,
      'https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg',
    );
  });
}

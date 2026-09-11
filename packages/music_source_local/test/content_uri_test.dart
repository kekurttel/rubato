import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_music_source_local/aurora_music_source_local.dart';
import 'package:flutter_test/flutter_test.dart';

Track _contentTrack() => Track(
  id: 'local:mediastore-42',
  providerId: 'local',
  sourceTrackId: 'mediastore-42',
  title: 'Device Song',
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
  durationMs: 180000,
  localPath: 'content://media/external/audio/media/42',
);

void main() {
  test('isLocalContentUri distinguishes URIs from raw paths', () {
    expect(
      isLocalContentUri('content://media/external/audio/media/42'),
      isTrue,
    );
    expect(isLocalContentUri('file:///sdcard/Music/a.m4a'), isTrue);
    expect(isLocalContentUri('/sdcard/Music/a.m4a'), isFalse);
    expect(isLocalContentUri(''), isFalse);
  });

  test('resolvePlayable trusts content:// without a File probe', () async {
    final provider = LocalFilesProvider();
    addTearDown(provider.dispose);

    final resolved = await provider.resolvePlayable(
      _contentTrack(),
      Quality.original,
    );

    expect(resolved.isSuccess, isTrue);
    expect(resolved.valueOrNull!.kind, MediaHandleKind.localFile);
    expect(
      resolved.valueOrNull!.uri,
      'content://media/external/audio/media/42',
    );
  });

  test('resolvePlayable trusts file:// without a File probe', () async {
    final provider = LocalFilesProvider();
    addTearDown(provider.dispose);
    final track = Track(
      id: 'local:file-1',
      providerId: 'local',
      sourceTrackId: 'file-1',
      title: 'File URI',
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
      localPath: 'file:///sdcard/Music/a.m4a',
    );

    final resolved = await provider.resolvePlayable(track, Quality.original);

    expect(resolved.isSuccess, isTrue);
    expect(resolved.valueOrNull!.uri, 'file:///sdcard/Music/a.m4a');
  });

  test('resolvePlayable still fails cleanly when path is missing', () async {
    final provider = LocalFilesProvider();
    addTearDown(provider.dispose);
    final track = Track(
      id: 'local:gone',
      providerId: 'local',
      sourceTrackId: 'gone',
      title: 'Gone',
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
      localPath: '/tmp/aurora-definitely-missing-42.m4a',
    );

    final resolved = await provider.resolvePlayable(track, Quality.original);

    expect(resolved.isFailure, isTrue);
    expect(resolved.errorOrNull!.details, contains('fileMissing'));
  });
}

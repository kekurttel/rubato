import 'dart:math';

import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_playback/aurora_playback.dart';
import 'package:flutter_test/flutter_test.dart';

Track _track(int i) => Track(
  id: 'local:track-$i',
  providerId: 'local',
  sourceTrackId: 'track-$i',
  title: 'Song $i',
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

void main() {
  test('setQueue + step walk the play order', () {
    final queue = QueueController()
      ..setQueue(
        <Track>[_track(0), _track(1), _track(2)],
        startIndex: 0,
        origin: PlaySource.queue,
        now: DateTime.utc(2026),
      );
    expect(queue.length, 3);
    expect(queue.current?.trackId, 'local:track-0');
    queue.step(1);
    expect(queue.current?.trackId, 'local:track-1');
  });

  test('move reorders entries and keeps the playhead on its item', () {
    final queue = QueueController()
      ..setQueue(
        <Track>[_track(0), _track(1), _track(2)],
        startIndex: 1,
        origin: PlaySource.queue,
        now: DateTime.utc(2026),
      )
      ..move(0, 2);
    expect(
      queue.items.map((i) => i.trackId),
      <String>['local:track-1', 'local:track-2', 'local:track-0'],
    );
    expect(queue.current?.trackId, 'local:track-1');
    expect(queue.currentIndex, 0);
  });

  test('shuffle keeps the set; unshuffle restores insertion order', () {
    final tracks = <Track>[for (var i = 0; i < 10; i++) _track(i)];
    final queue = QueueController(random: Random(7))
      ..setQueue(
        tracks,
        startIndex: 0,
        origin: PlaySource.queue,
        now: DateTime.utc(2026),
      )
      ..setShuffle(enabled: true);
    expect(
      queue.items.map((i) => i.trackId).toSet(),
      tracks.map((t) => t.id).toSet(),
    );
    expect(queue.current?.trackId, 'local:track-0');
    queue.setShuffle(enabled: false);
    expect(
      queue.items.map((i) => i.trackId),
      tracks.map((t) => t.id),
    );
  });

  test('addNext inserts after the playhead; removeAt fixes the cursor', () {
    final queue = QueueController()
      ..setQueue(
        <Track>[_track(0), _track(1)],
        startIndex: 0,
        origin: PlaySource.queue,
        now: DateTime.utc(2026),
      )
      ..addNext(
        _track(9),
        origin: PlaySource.queue,
        now: DateTime.utc(2026),
      );
    expect(
      queue.items.map((i) => i.trackId),
      <String>['local:track-0', 'local:track-9', 'local:track-1'],
    );
    expect(queue.current?.trackId, 'local:track-0');
    queue.removeAt(0);
    expect(queue.current?.trackId, 'local:track-9');
  });
}

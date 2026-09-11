import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_playback/aurora_playback.dart';
import 'package:flutter_test/flutter_test.dart';

Track _track(String id, {int durationMs = 180000}) => Track(
  id: id,
  providerId: 'local',
  sourceTrackId: id,
  title: 'Song $id',
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
  durationMs: durationMs,
);

ListeningEventSink _sink(FakeClock clock, List<PlayEvent> out) =>
    ListeningEventSink(
      clock: clock,
      writer: (events) async => out.addAll(events),
    );

void main() {
  test('short non-skip plays are dropped as noise', () async {
    final clock = FakeClock(DateTime.utc(2026, 5, 1, 12));
    final out = <PlayEvent>[];
    final sink = _sink(clock, out)..onStarted(_track('a'), PlaySource.library);
    clock.advance(const Duration(seconds: 2));
    sink.onStopped();
    await Future<void>.delayed(Duration.zero);
    expect(out, isEmpty);
  });

  test('pause then complete flushes one event with seek counts', () async {
    // Local 02:30 → night bucket in any host timezone (local clock in,
    // local conversion out).
    final clock = FakeClock(DateTime(2026, 5, 1, 2, 30));
    final out = <PlayEvent>[];
    final sink = _sink(clock, out);
    final track = _track('b');
    sink.onStarted(track, PlaySource.library);
    clock.advance(const Duration(seconds: 4));
    sink
      ..onSeek(Duration.zero, const Duration(seconds: 30))
      ..onSeek(const Duration(seconds: 30), const Duration(seconds: 60))
      ..onPaused();
    await Future<void>.delayed(Duration.zero);
    expect(out.length, 1);
    clock.advance(const Duration(seconds: 10));
    sink.onResumed();
    clock.advance(const Duration(seconds: 170));
    sink.onCompleted();
    await Future<void>.delayed(Duration.zero);
    expect(out.length, 2);
    final done = out.last;
    expect(done.trackId, 'b');
    expect(done.seekCount, 2);
    expect(done.timeOfDayBucket, TimeOfDayBucket.night);
    expect(done.completionRatio, greaterThan(0.85));
    expect(done.skipped, isFalse);
  });

  test('skips are always recorded, however short', () async {
    final clock = FakeClock(DateTime.utc(2026));
    final out = <PlayEvent>[];
    final sink = _sink(clock, out)..onStarted(_track('c'), PlaySource.search);
    clock.advance(const Duration(milliseconds: 500));
    sink.onSkipped(atMs: 500);
    await Future<void>.delayed(Duration.zero);
    expect(out.length, 1);
    expect(out.first.skipped, isTrue);
    expect(out.first.skipAtMs, 500);
    expect(out.first.source, PlaySource.search);
  });

  test('periodic flush fires only with >=1000ms unflushed', () async {
    final clock = FakeClock(DateTime.utc(2026));
    final out = <PlayEvent>[];
    final sink = _sink(clock, out)..onStarted(_track('d'), PlaySource.queue);
    clock.advance(const Duration(milliseconds: 500));
    await sink.flush();
    expect(out, isEmpty);
    clock.advance(const Duration(seconds: 5));
    await sink.flush();
    expect(out.length, 1);
    clock.advance(const Duration(milliseconds: 500));
    await sink.flush();
    expect(out.length, 1);
  });

  test('quick restart of an incomplete play merges (replay signal)', () async {
    final clock = FakeClock(DateTime.utc(2026));
    final out = <PlayEvent>[];
    final track = _track('e');
    final sink = _sink(clock, out)..onStarted(track, PlaySource.library);
    clock.advance(const Duration(seconds: 1));
    sink.onStopped();
    await Future<void>.delayed(Duration.zero);
    expect(out, isEmpty);
    clock.advance(const Duration(seconds: 1));
    sink.onStarted(track, PlaySource.library);
    expect(sink.replaysDetected, 1);
  });
}

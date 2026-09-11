import 'package:aurora_core/src/models/enums.dart';

/// Injectable clock. All time reads in business logic (reco math, event
/// timestamps, TTL checks) go through [Clock] so tests can freeze time.
///
/// Never call `DateTime.now()` directly in reco/database code.
///
/// Subclass via `extends` (not `implements`) so the UTC/epoch helpers
/// are inherited rather than re-implemented.
abstract class Clock {
  /// Creates a clock.
  const Clock();

  /// Current local time.
  DateTime now();

  /// Current UTC time.
  DateTime nowUtc() => now().toUtc();

  /// Epoch milliseconds (UTC) — the unit stored in Drift columns.
  int nowEpochMs() => nowUtc().millisecondsSinceEpoch;
}

/// Production clock backed by the system wall clock.
final class SystemClock extends Clock {
  /// Creates the production clock.
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}

/// Mutable clock for tests. Starts at `initial` (default 2026-01-01).
final class FakeClock extends Clock {
  /// Creates a fake clock pinned at [currentTime].
  FakeClock([DateTime? initialTime])
    : currentTime = initialTime ?? DateTime(2026);

  /// The currently pinned time. Assign to travel; [advance] to step.
  DateTime currentTime;

  @override
  DateTime now() => currentTime;

  /// Advances the clock by [delta].
  void advance(Duration delta) {
    currentTime = currentTime.add(delta);
  }
}

/// Time-bucket helpers shared by event recording and reco (spec 5).
extension DateTimeAuroraX on DateTime {
  /// Maps the local hour to its bucket:
  /// night 00-05, morning 06-11, afternoon 12-17, evening 18-23.
  TimeOfDayBucket get timeOfDayBucket {
    final h = hour;
    if (h < 6) {
      return TimeOfDayBucket.night;
    }
    if (h < 12) {
      return TimeOfDayBucket.morning;
    }
    if (h < 18) {
      return TimeOfDayBucket.afternoon;
    }
    return TimeOfDayBucket.evening;
  }

  /// `weekday % 7` (Monday 1 .. Saturday 6, Sunday 0), per spec section 5.
  int get auroraDayOfWeek => weekday % 7;
}

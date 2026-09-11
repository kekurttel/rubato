import 'package:aurora_core/src/models/enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'play_event.freezed.dart';
part 'play_event.g.dart';

/// One flushed listening observation (spec section 5).
///
/// Written by the listening-event sink on pause / skip / complete /
/// track change / background / periodic flush — never every second.
/// Stream plays (`source` stream/radio/search) weight the same as local
/// plays so on-device learning covers online listening.
@freezed
abstract class PlayEvent with _$PlayEvent {
  /// Creates a play event.
  const factory PlayEvent({
    /// Event id (uuid v7).
    required String id,

    /// Played track id.
    required String trackId,

    /// Playback session id (rotated on cold start / 30 min idle).
    required String sessionId,

    /// Playback start (UTC).
    required DateTime startedAt,

    /// Track length at play time, in milliseconds.
    required int durationMs,

    /// Milliseconds actually heard (excluding seeks over content).
    required int listenedMs,

    /// `listenedMs / max(durationMs, 1)`, clamped 0..1.
    required double completionRatio,

    /// User moved on before `completionRatio` reached 0.85.
    /// Auto-next after a genuine complete is NOT a skip.
    required bool skipped,

    /// Where playback originated.
    required PlaySource source,

    /// Local-time bucket derived from [startedAt].
    required TimeOfDayBucket timeOfDayBucket,

    /// `startedAt.weekday % 7` (Monday 1 .. Sunday 0).
    required int dayOfWeek,

    /// Playback end, if the observation window closed (UTC).
    DateTime? endedAt,

    /// Position of the skip, if `skipped`.
    int? skipAtMs,

    /// Playback speed multiplier (1.0 until Phase 5).
    @Default(1.0) double playbackSpeed,

    /// Whether the device was offline during playback.
    @Default(false) bool wasOffline,

    /// Seek gestures observed during this event.
    @Default(0) int seekCount,
  }) = _PlayEvent;

  const PlayEvent._();

  /// Deserializes an event from JSON.
  factory PlayEvent.fromJson(Map<String, dynamic> json) =>
      _$PlayEventFromJson(json);

  /// Whether this counts as a genuine complete (>= 0.85).
  bool get isComplete => completionRatio >= 0.85;
}

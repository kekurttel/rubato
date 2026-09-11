// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'play_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlayEvent _$PlayEventFromJson(Map<String, dynamic> json) => _PlayEvent(
  id: json['id'] as String,
  trackId: json['trackId'] as String,
  sessionId: json['sessionId'] as String,
  startedAt: DateTime.parse(json['startedAt'] as String),
  durationMs: (json['durationMs'] as num).toInt(),
  listenedMs: (json['listenedMs'] as num).toInt(),
  completionRatio: (json['completionRatio'] as num).toDouble(),
  skipped: json['skipped'] as bool,
  source: $enumDecode(_$PlaySourceEnumMap, json['source']),
  timeOfDayBucket: $enumDecode(
    _$TimeOfDayBucketEnumMap,
    json['timeOfDayBucket'],
  ),
  dayOfWeek: (json['dayOfWeek'] as num).toInt(),
  endedAt: json['endedAt'] == null
      ? null
      : DateTime.parse(json['endedAt'] as String),
  skipAtMs: (json['skipAtMs'] as num?)?.toInt(),
  playbackSpeed: (json['playbackSpeed'] as num?)?.toDouble() ?? 1.0,
  wasOffline: json['wasOffline'] as bool? ?? false,
  seekCount: (json['seekCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$PlayEventToJson(_PlayEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'trackId': instance.trackId,
      'sessionId': instance.sessionId,
      'startedAt': instance.startedAt.toIso8601String(),
      'durationMs': instance.durationMs,
      'listenedMs': instance.listenedMs,
      'completionRatio': instance.completionRatio,
      'skipped': instance.skipped,
      'source': _$PlaySourceEnumMap[instance.source]!,
      'timeOfDayBucket': _$TimeOfDayBucketEnumMap[instance.timeOfDayBucket]!,
      'dayOfWeek': instance.dayOfWeek,
      'endedAt': instance.endedAt?.toIso8601String(),
      'skipAtMs': instance.skipAtMs,
      'playbackSpeed': instance.playbackSpeed,
      'wasOffline': instance.wasOffline,
      'seekCount': instance.seekCount,
    };

const _$PlaySourceEnumMap = {
  PlaySource.search: 'search',
  PlaySource.reco: 'reco',
  PlaySource.queue: 'queue',
  PlaySource.radio: 'radio',
  PlaySource.library: 'library',
  PlaySource.download: 'download',
  PlaySource.similar: 'similar',
  PlaySource.album: 'album',
  PlaySource.artist: 'artist',
  PlaySource.external: 'external',
};

const _$TimeOfDayBucketEnumMap = {
  TimeOfDayBucket.night: 'night',
  TimeOfDayBucket.morning: 'morning',
  TimeOfDayBucket.afternoon: 'afternoon',
  TimeOfDayBucket.evening: 'evening',
};

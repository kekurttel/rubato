// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_track_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserTrackStats _$UserTrackStatsFromJson(Map<String, dynamic> json) =>
    _UserTrackStats(
      trackId: json['trackId'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      playCount: (json['playCount'] as num?)?.toInt() ?? 0,
      skipCount: (json['skipCount'] as num?)?.toInt() ?? 0,
      completeCount: (json['completeCount'] as num?)?.toInt() ?? 0,
      replayCount: (json['replayCount'] as num?)?.toInt() ?? 0,
      totalListenMs: (json['totalListenMs'] as num?)?.toInt() ?? 0,
      lastPlayedAt: json['lastPlayedAt'] == null
          ? null
          : DateTime.parse(json['lastPlayedAt'] as String),
      likeState: (json['likeState'] as num?)?.toInt() ?? 0,
      decayedScore: (json['decayedScore'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$UserTrackStatsToJson(_UserTrackStats instance) =>
    <String, dynamic>{
      'trackId': instance.trackId,
      'updatedAt': instance.updatedAt.toIso8601String(),
      'playCount': instance.playCount,
      'skipCount': instance.skipCount,
      'completeCount': instance.completeCount,
      'replayCount': instance.replayCount,
      'totalListenMs': instance.totalListenMs,
      'lastPlayedAt': instance.lastPlayedAt?.toIso8601String(),
      'likeState': instance.likeState,
      'decayedScore': instance.decayedScore,
    };

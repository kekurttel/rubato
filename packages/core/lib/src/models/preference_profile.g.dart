// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preference_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PreferenceProfile _$PreferenceProfileFromJson(Map<String, dynamic> json) =>
    _PreferenceProfile(
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      version: (json['version'] as num?)?.toInt() ?? 1,
      artistWeights:
          (json['artistWeights'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const <String, double>{},
      genreWeights:
          (json['genreWeights'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const <String, double>{},
      timeContext:
          (json['timeContext'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
              k,
              (e as Map<String, dynamic>).map(
                (k, e) => MapEntry(k, (e as num).toDouble()),
              ),
            ),
          ) ??
          const <String, Map<String, double>>{},
      recentIntent:
          (json['recentIntent'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const <String, double>{},
      explorationRate: (json['explorationRate'] as num?)?.toDouble() ?? 0.10,
      adjacentRate: (json['adjacentRate'] as num?)?.toDouble() ?? 0.20,
      exploitationRate: (json['exploitationRate'] as num?)?.toDouble() ?? 0.70,
      decayHalfLifeDays: (json['decayHalfLifeDays'] as num?)?.toDouble() ?? 45,
      consecutiveArtistPenalty:
          (json['consecutiveArtistPenalty'] as num?)?.toDouble() ?? 0.05,
    );

Map<String, dynamic> _$PreferenceProfileToJson(_PreferenceProfile instance) =>
    <String, dynamic>{
      'updatedAt': instance.updatedAt.toIso8601String(),
      'version': instance.version,
      'artistWeights': instance.artistWeights,
      'genreWeights': instance.genreWeights,
      'timeContext': instance.timeContext,
      'recentIntent': instance.recentIntent,
      'explorationRate': instance.explorationRate,
      'adjacentRate': instance.adjacentRate,
      'exploitationRate': instance.exploitationRate,
      'decayHalfLifeDays': instance.decayHalfLifeDays,
      'consecutiveArtistPenalty': instance.consecutiveArtistPenalty,
    };

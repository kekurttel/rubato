// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Track _$TrackFromJson(Map<String, dynamic> json) => _Track(
  id: json['id'] as String,
  providerId: json['providerId'] as String,
  sourceTrackId: json['sourceTrackId'] as String,
  title: json['title'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  durationMs: (json['durationMs'] as num?)?.toInt() ?? 0,
  explicit: json['explicit'] as bool? ?? false,
  artistIds:
      (json['artistIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  albumId: json['albumId'] as String?,
  genreIds:
      (json['genreIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  year: (json['year'] as num?)?.toInt(),
  audioHash: json['audioHash'] as String?,
  localPath: json['localPath'] as String?,
  isDownloaded: json['isDownloaded'] as bool? ?? false,
  streamExpiresAt: json['streamExpiresAt'] == null
      ? null
      : DateTime.parse(json['streamExpiresAt'] as String),
);

Map<String, dynamic> _$TrackToJson(_Track instance) => <String, dynamic>{
  'id': instance.id,
  'providerId': instance.providerId,
  'sourceTrackId': instance.sourceTrackId,
  'title': instance.title,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'durationMs': instance.durationMs,
  'explicit': instance.explicit,
  'artistIds': instance.artistIds,
  'albumId': instance.albumId,
  'genreIds': instance.genreIds,
  'year': instance.year,
  'audioHash': instance.audioHash,
  'localPath': instance.localPath,
  'isDownloaded': instance.isDownloaded,
  'streamExpiresAt': instance.streamExpiresAt?.toIso8601String(),
};

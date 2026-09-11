// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artwork.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Artwork _$ArtworkFromJson(Map<String, dynamic> json) => _Artwork(
  id: json['id'] as String,
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  url: json['url'] as String?,
  localPath: json['localPath'] as String?,
  dominantColorArgb: (json['dominantColorArgb'] as num?)?.toInt(),
  width: (json['width'] as num?)?.toInt(),
  height: (json['height'] as num?)?.toInt(),
);

Map<String, dynamic> _$ArtworkToJson(_Artwork instance) => <String, dynamic>{
  'id': instance.id,
  'updatedAt': instance.updatedAt.toIso8601String(),
  'url': instance.url,
  'localPath': instance.localPath,
  'dominantColorArgb': instance.dominantColorArgb,
  'width': instance.width,
  'height': instance.height,
};

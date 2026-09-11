// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'album.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Album _$AlbumFromJson(Map<String, dynamic> json) => _Album(
  id: json['id'] as String,
  title: json['title'] as String,
  providerId: json['providerId'] as String,
  sourceId: json['sourceId'] as String,
  artistIds:
      (json['artistIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  year: (json['year'] as num?)?.toInt(),
  artworkId: json['artworkId'] as String?,
  trackCount: (json['trackCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$AlbumToJson(_Album instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'providerId': instance.providerId,
  'sourceId': instance.sourceId,
  'artistIds': instance.artistIds,
  'year': instance.year,
  'artworkId': instance.artworkId,
  'trackCount': instance.trackCount,
};

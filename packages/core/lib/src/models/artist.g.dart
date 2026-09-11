// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Artist _$ArtistFromJson(Map<String, dynamic> json) => _Artist(
  id: json['id'] as String,
  name: json['name'] as String,
  sourceId: json['sourceId'] as String,
  providerId: json['providerId'] as String,
  genres:
      (json['genres'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$ArtistToJson(_Artist instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'sourceId': instance.sourceId,
  'providerId': instance.providerId,
  'genres': instance.genres,
  'imageUrl': instance.imageUrl,
};

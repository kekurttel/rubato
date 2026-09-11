// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SearchQuery _$SearchQueryFromJson(Map<String, dynamic> json) => _SearchQuery(
  text: json['text'] as String,
  types:
      (json['types'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$SearchTypeEnumMap, e))
          .toList() ??
      SearchType.values,
  limit: (json['limit'] as num?)?.toInt() ?? 20,
  cursor: json['cursor'] as String?,
);

Map<String, dynamic> _$SearchQueryToJson(_SearchQuery instance) =>
    <String, dynamic>{
      'text': instance.text,
      'types': instance.types.map((e) => _$SearchTypeEnumMap[e]!).toList(),
      'limit': instance.limit,
      'cursor': instance.cursor,
    };

const _$SearchTypeEnumMap = {
  SearchType.track: 'track',
  SearchType.artist: 'artist',
  SearchType.album: 'album',
  SearchType.playlist: 'playlist',
};

_SearchPage _$SearchPageFromJson(Map<String, dynamic> json) => _SearchPage(
  providerId: json['providerId'] as String,
  fetchedAt: DateTime.parse(json['fetchedAt'] as String),
  tracks:
      (json['tracks'] as List<dynamic>?)
          ?.map((e) => Track.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Track>[],
  artists:
      (json['artists'] as List<dynamic>?)
          ?.map((e) => Artist.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Artist>[],
  albums:
      (json['albums'] as List<dynamic>?)
          ?.map((e) => Album.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Album>[],
  nextCursor: json['nextCursor'] as String?,
);

Map<String, dynamic> _$SearchPageToJson(_SearchPage instance) =>
    <String, dynamic>{
      'providerId': instance.providerId,
      'fetchedAt': instance.fetchedAt.toIso8601String(),
      'tracks': instance.tracks.map((e) => e.toJson()).toList(),
      'artists': instance.artists.map((e) => e.toJson()).toList(),
      'albums': instance.albums.map((e) => e.toJson()).toList(),
      'nextCursor': instance.nextCursor,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_QueueItem _$QueueItemFromJson(Map<String, dynamic> json) => _QueueItem(
  id: json['id'] as String,
  trackId: json['trackId'] as String,
  origin: $enumDecode(_$PlaySourceEnumMap, json['origin']),
  addedAt: DateTime.parse(json['addedAt'] as String),
  frozenScore: (json['frozenScore'] as num?)?.toDouble(),
);

Map<String, dynamic> _$QueueItemToJson(_QueueItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'trackId': instance.trackId,
      'origin': _$PlaySourceEnumMap[instance.origin]!,
      'addedAt': instance.addedAt.toIso8601String(),
      'frozenScore': instance.frozenScore,
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

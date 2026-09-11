// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlaylistEntry _$PlaylistEntryFromJson(Map<String, dynamic> json) =>
    _PlaylistEntry(
      playlistId: json['playlistId'] as String,
      trackId: json['trackId'] as String,
      position: (json['position'] as num).toInt(),
      addedAt: DateTime.parse(json['addedAt'] as String),
    );

Map<String, dynamic> _$PlaylistEntryToJson(_PlaylistEntry instance) =>
    <String, dynamic>{
      'playlistId': instance.playlistId,
      'trackId': instance.trackId,
      'position': instance.position,
      'addedAt': instance.addedAt.toIso8601String(),
    };

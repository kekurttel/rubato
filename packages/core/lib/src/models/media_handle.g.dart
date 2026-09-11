// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_handle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MediaHandle _$MediaHandleFromJson(Map<String, dynamic> json) => _MediaHandle(
  kind: $enumDecode(_$MediaHandleKindEnumMap, json['kind']),
  uri: json['uri'] as String,
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
  mimeType: json['mimeType'] as String?,
  qualityLabel: json['qualityLabel'] as String?,
  headers:
      (json['headers'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
);

Map<String, dynamic> _$MediaHandleToJson(_MediaHandle instance) =>
    <String, dynamic>{
      'kind': _$MediaHandleKindEnumMap[instance.kind]!,
      'uri': instance.uri,
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'mimeType': instance.mimeType,
      'qualityLabel': instance.qualityLabel,
      'headers': instance.headers,
    };

const _$MediaHandleKindEnumMap = {
  MediaHandleKind.localFile: 'localFile',
  MediaHandleKind.authorizedStream: 'authorizedStream',
};

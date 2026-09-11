// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'errors.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppError _$AppErrorFromJson(Map<String, dynamic> json) => _AppError(
  code: $enumDecode(_$AppErrorCodeEnumMap, json['code']),
  message: json['message'] as String,
  details: json['details'] as String?,
);

Map<String, dynamic> _$AppErrorToJson(_AppError instance) => <String, dynamic>{
  'code': _$AppErrorCodeEnumMap[instance.code]!,
  'message': instance.message,
  'details': instance.details,
};

const _$AppErrorCodeEnumMap = {
  AppErrorCode.network: 'network',
  AppErrorCode.notFound: 'notFound',
  AppErrorCode.permission: 'permission',
  AppErrorCode.io: 'io',
  AppErrorCode.codec: 'codec',
  AppErrorCode.cancelled: 'cancelled',
  AppErrorCode.unknown: 'unknown',
  AppErrorCode.provider: 'provider',
  AppErrorCode.db: 'db',
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_job.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DownloadJob _$DownloadJobFromJson(Map<String, dynamic> json) => _DownloadJob(
  id: json['id'] as String,
  trackId: json['trackId'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  state:
      $enumDecodeNullable(_$DownloadStateEnumMap, json['state']) ??
      DownloadState.queued,
  progress: (json['progress'] as num?)?.toDouble() ?? 0,
  bytesReceived: (json['bytesReceived'] as num?)?.toInt() ?? 0,
  bytesTotal: (json['bytesTotal'] as num?)?.toInt(),
  errorCode: json['errorCode'] as String?,
  errorMessage: json['errorMessage'] as String?,
  attempts: (json['attempts'] as num?)?.toInt() ?? 0,
  qualityLabel: json['qualityLabel'] as String?,
  filePath: json['filePath'] as String?,
);

Map<String, dynamic> _$DownloadJobToJson(_DownloadJob instance) =>
    <String, dynamic>{
      'id': instance.id,
      'trackId': instance.trackId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'state': _$DownloadStateEnumMap[instance.state]!,
      'progress': instance.progress,
      'bytesReceived': instance.bytesReceived,
      'bytesTotal': instance.bytesTotal,
      'errorCode': instance.errorCode,
      'errorMessage': instance.errorMessage,
      'attempts': instance.attempts,
      'qualityLabel': instance.qualityLabel,
      'filePath': instance.filePath,
    };

const _$DownloadStateEnumMap = {
  DownloadState.queued: 'queued',
  DownloadState.fetchingMeta: 'fetchingMeta',
  DownloadState.downloading: 'downloading',
  DownloadState.verifying: 'verifying',
  DownloadState.completed: 'completed',
  DownloadState.paused: 'paused',
  DownloadState.failed: 'failed',
  DownloadState.canceled: 'canceled',
  DownloadState.fileMissing: 'fileMissing',
};

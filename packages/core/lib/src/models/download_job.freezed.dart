// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'download_job.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DownloadJob {

/// Job id (uuid v7).
 String get id;/// Track being persisted.
 String get trackId;/// Creation time (UTC).
 DateTime get createdAt;/// Last update time (UTC).
 DateTime get updatedAt;/// Lifecycle state.
 DownloadState get state;/// 0..1 progress of the active phase.
 double get progress;/// Bytes received so far.
 int get bytesReceived;/// Expected total bytes, when the provider reported it.
 int? get bytesTotal;/// Machine-readable failure code of the last attempt.
 String? get errorCode;/// Human-readable failure message of the last attempt.
 String? get errorMessage;/// Attempts made so far (drives backoff, caps at 5).
 int get attempts;/// Quality label used for this job (low/medium/high/original).
 String? get qualityLabel;/// Persisted file path once completed.
 String? get filePath;
/// Create a copy of DownloadJob
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DownloadJobCopyWith<DownloadJob> get copyWith => _$DownloadJobCopyWithImpl<DownloadJob>(this as DownloadJob, _$identity);

  /// Serializes this DownloadJob to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadJob&&(identical(other.id, id) || other.id == id)&&(identical(other.trackId, trackId) || other.trackId == trackId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.state, state) || other.state == state)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.bytesReceived, bytesReceived) || other.bytesReceived == bytesReceived)&&(identical(other.bytesTotal, bytesTotal) || other.bytesTotal == bytesTotal)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.attempts, attempts) || other.attempts == attempts)&&(identical(other.qualityLabel, qualityLabel) || other.qualityLabel == qualityLabel)&&(identical(other.filePath, filePath) || other.filePath == filePath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,trackId,createdAt,updatedAt,state,progress,bytesReceived,bytesTotal,errorCode,errorMessage,attempts,qualityLabel,filePath);

@override
String toString() {
  return 'DownloadJob(id: $id, trackId: $trackId, createdAt: $createdAt, updatedAt: $updatedAt, state: $state, progress: $progress, bytesReceived: $bytesReceived, bytesTotal: $bytesTotal, errorCode: $errorCode, errorMessage: $errorMessage, attempts: $attempts, qualityLabel: $qualityLabel, filePath: $filePath)';
}


}

/// @nodoc
abstract mixin class $DownloadJobCopyWith<$Res>  {
  factory $DownloadJobCopyWith(DownloadJob value, $Res Function(DownloadJob) _then) = _$DownloadJobCopyWithImpl;
@useResult
$Res call({
 String id, String trackId, DateTime createdAt, DateTime updatedAt, DownloadState state, double progress, int bytesReceived, int? bytesTotal, String? errorCode, String? errorMessage, int attempts, String? qualityLabel, String? filePath
});




}
/// @nodoc
class _$DownloadJobCopyWithImpl<$Res>
    implements $DownloadJobCopyWith<$Res> {
  _$DownloadJobCopyWithImpl(this._self, this._then);

  final DownloadJob _self;
  final $Res Function(DownloadJob) _then;

/// Create a copy of DownloadJob
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? trackId = null,Object? createdAt = null,Object? updatedAt = null,Object? state = null,Object? progress = null,Object? bytesReceived = null,Object? bytesTotal = freezed,Object? errorCode = freezed,Object? errorMessage = freezed,Object? attempts = null,Object? qualityLabel = freezed,Object? filePath = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,trackId: null == trackId ? _self.trackId : trackId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as DownloadState,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,bytesReceived: null == bytesReceived ? _self.bytesReceived : bytesReceived // ignore: cast_nullable_to_non_nullable
as int,bytesTotal: freezed == bytesTotal ? _self.bytesTotal : bytesTotal // ignore: cast_nullable_to_non_nullable
as int?,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,qualityLabel: freezed == qualityLabel ? _self.qualityLabel : qualityLabel // ignore: cast_nullable_to_non_nullable
as String?,filePath: freezed == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DownloadJob].
extension DownloadJobPatterns on DownloadJob {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DownloadJob value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DownloadJob() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DownloadJob value)  $default,){
final _that = this;
switch (_that) {
case _DownloadJob():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DownloadJob value)?  $default,){
final _that = this;
switch (_that) {
case _DownloadJob() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String trackId,  DateTime createdAt,  DateTime updatedAt,  DownloadState state,  double progress,  int bytesReceived,  int? bytesTotal,  String? errorCode,  String? errorMessage,  int attempts,  String? qualityLabel,  String? filePath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DownloadJob() when $default != null:
return $default(_that.id,_that.trackId,_that.createdAt,_that.updatedAt,_that.state,_that.progress,_that.bytesReceived,_that.bytesTotal,_that.errorCode,_that.errorMessage,_that.attempts,_that.qualityLabel,_that.filePath);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String trackId,  DateTime createdAt,  DateTime updatedAt,  DownloadState state,  double progress,  int bytesReceived,  int? bytesTotal,  String? errorCode,  String? errorMessage,  int attempts,  String? qualityLabel,  String? filePath)  $default,) {final _that = this;
switch (_that) {
case _DownloadJob():
return $default(_that.id,_that.trackId,_that.createdAt,_that.updatedAt,_that.state,_that.progress,_that.bytesReceived,_that.bytesTotal,_that.errorCode,_that.errorMessage,_that.attempts,_that.qualityLabel,_that.filePath);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String trackId,  DateTime createdAt,  DateTime updatedAt,  DownloadState state,  double progress,  int bytesReceived,  int? bytesTotal,  String? errorCode,  String? errorMessage,  int attempts,  String? qualityLabel,  String? filePath)?  $default,) {final _that = this;
switch (_that) {
case _DownloadJob() when $default != null:
return $default(_that.id,_that.trackId,_that.createdAt,_that.updatedAt,_that.state,_that.progress,_that.bytesReceived,_that.bytesTotal,_that.errorCode,_that.errorMessage,_that.attempts,_that.qualityLabel,_that.filePath);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DownloadJob extends DownloadJob {
  const _DownloadJob({required this.id, required this.trackId, required this.createdAt, required this.updatedAt, this.state = DownloadState.queued, this.progress = 0, this.bytesReceived = 0, this.bytesTotal, this.errorCode, this.errorMessage, this.attempts = 0, this.qualityLabel, this.filePath}): super._();
  factory _DownloadJob.fromJson(Map<String, dynamic> json) => _$DownloadJobFromJson(json);

/// Job id (uuid v7).
@override final  String id;
/// Track being persisted.
@override final  String trackId;
/// Creation time (UTC).
@override final  DateTime createdAt;
/// Last update time (UTC).
@override final  DateTime updatedAt;
/// Lifecycle state.
@override@JsonKey() final  DownloadState state;
/// 0..1 progress of the active phase.
@override@JsonKey() final  double progress;
/// Bytes received so far.
@override@JsonKey() final  int bytesReceived;
/// Expected total bytes, when the provider reported it.
@override final  int? bytesTotal;
/// Machine-readable failure code of the last attempt.
@override final  String? errorCode;
/// Human-readable failure message of the last attempt.
@override final  String? errorMessage;
/// Attempts made so far (drives backoff, caps at 5).
@override@JsonKey() final  int attempts;
/// Quality label used for this job (low/medium/high/original).
@override final  String? qualityLabel;
/// Persisted file path once completed.
@override final  String? filePath;

/// Create a copy of DownloadJob
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DownloadJobCopyWith<_DownloadJob> get copyWith => __$DownloadJobCopyWithImpl<_DownloadJob>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DownloadJobToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DownloadJob&&(identical(other.id, id) || other.id == id)&&(identical(other.trackId, trackId) || other.trackId == trackId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.state, state) || other.state == state)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.bytesReceived, bytesReceived) || other.bytesReceived == bytesReceived)&&(identical(other.bytesTotal, bytesTotal) || other.bytesTotal == bytesTotal)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.attempts, attempts) || other.attempts == attempts)&&(identical(other.qualityLabel, qualityLabel) || other.qualityLabel == qualityLabel)&&(identical(other.filePath, filePath) || other.filePath == filePath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,trackId,createdAt,updatedAt,state,progress,bytesReceived,bytesTotal,errorCode,errorMessage,attempts,qualityLabel,filePath);

@override
String toString() {
  return 'DownloadJob(id: $id, trackId: $trackId, createdAt: $createdAt, updatedAt: $updatedAt, state: $state, progress: $progress, bytesReceived: $bytesReceived, bytesTotal: $bytesTotal, errorCode: $errorCode, errorMessage: $errorMessage, attempts: $attempts, qualityLabel: $qualityLabel, filePath: $filePath)';
}


}

/// @nodoc
abstract mixin class _$DownloadJobCopyWith<$Res> implements $DownloadJobCopyWith<$Res> {
  factory _$DownloadJobCopyWith(_DownloadJob value, $Res Function(_DownloadJob) _then) = __$DownloadJobCopyWithImpl;
@override @useResult
$Res call({
 String id, String trackId, DateTime createdAt, DateTime updatedAt, DownloadState state, double progress, int bytesReceived, int? bytesTotal, String? errorCode, String? errorMessage, int attempts, String? qualityLabel, String? filePath
});




}
/// @nodoc
class __$DownloadJobCopyWithImpl<$Res>
    implements _$DownloadJobCopyWith<$Res> {
  __$DownloadJobCopyWithImpl(this._self, this._then);

  final _DownloadJob _self;
  final $Res Function(_DownloadJob) _then;

/// Create a copy of DownloadJob
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? trackId = null,Object? createdAt = null,Object? updatedAt = null,Object? state = null,Object? progress = null,Object? bytesReceived = null,Object? bytesTotal = freezed,Object? errorCode = freezed,Object? errorMessage = freezed,Object? attempts = null,Object? qualityLabel = freezed,Object? filePath = freezed,}) {
  return _then(_DownloadJob(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,trackId: null == trackId ? _self.trackId : trackId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as DownloadState,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,bytesReceived: null == bytesReceived ? _self.bytesReceived : bytesReceived // ignore: cast_nullable_to_non_nullable
as int,bytesTotal: freezed == bytesTotal ? _self.bytesTotal : bytesTotal // ignore: cast_nullable_to_non_nullable
as int?,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,qualityLabel: freezed == qualityLabel ? _self.qualityLabel : qualityLabel // ignore: cast_nullable_to_non_nullable
as String?,filePath: freezed == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

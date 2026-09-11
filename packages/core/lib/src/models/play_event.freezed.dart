// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'play_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlayEvent {

/// Event id (uuid v7).
 String get id;/// Played track id.
 String get trackId;/// Playback session id (rotated on cold start / 30 min idle).
 String get sessionId;/// Playback start (UTC).
 DateTime get startedAt;/// Track length at play time, in milliseconds.
 int get durationMs;/// Milliseconds actually heard (excluding seeks over content).
 int get listenedMs;/// `listenedMs / max(durationMs, 1)`, clamped 0..1.
 double get completionRatio;/// User moved on before `completionRatio` reached 0.85.
/// Auto-next after a genuine complete is NOT a skip.
 bool get skipped;/// Where playback originated.
 PlaySource get source;/// Local-time bucket derived from [startedAt].
 TimeOfDayBucket get timeOfDayBucket;/// `startedAt.weekday % 7` (Monday 1 .. Sunday 0).
 int get dayOfWeek;/// Playback end, if the observation window closed (UTC).
 DateTime? get endedAt;/// Position of the skip, if `skipped`.
 int? get skipAtMs;/// Playback speed multiplier (1.0 until Phase 5).
 double get playbackSpeed;/// Whether the device was offline during playback.
 bool get wasOffline;/// Seek gestures observed during this event.
 int get seekCount;
/// Create a copy of PlayEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayEventCopyWith<PlayEvent> get copyWith => _$PlayEventCopyWithImpl<PlayEvent>(this as PlayEvent, _$identity);

  /// Serializes this PlayEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.trackId, trackId) || other.trackId == trackId)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.listenedMs, listenedMs) || other.listenedMs == listenedMs)&&(identical(other.completionRatio, completionRatio) || other.completionRatio == completionRatio)&&(identical(other.skipped, skipped) || other.skipped == skipped)&&(identical(other.source, source) || other.source == source)&&(identical(other.timeOfDayBucket, timeOfDayBucket) || other.timeOfDayBucket == timeOfDayBucket)&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.skipAtMs, skipAtMs) || other.skipAtMs == skipAtMs)&&(identical(other.playbackSpeed, playbackSpeed) || other.playbackSpeed == playbackSpeed)&&(identical(other.wasOffline, wasOffline) || other.wasOffline == wasOffline)&&(identical(other.seekCount, seekCount) || other.seekCount == seekCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,trackId,sessionId,startedAt,durationMs,listenedMs,completionRatio,skipped,source,timeOfDayBucket,dayOfWeek,endedAt,skipAtMs,playbackSpeed,wasOffline,seekCount);

@override
String toString() {
  return 'PlayEvent(id: $id, trackId: $trackId, sessionId: $sessionId, startedAt: $startedAt, durationMs: $durationMs, listenedMs: $listenedMs, completionRatio: $completionRatio, skipped: $skipped, source: $source, timeOfDayBucket: $timeOfDayBucket, dayOfWeek: $dayOfWeek, endedAt: $endedAt, skipAtMs: $skipAtMs, playbackSpeed: $playbackSpeed, wasOffline: $wasOffline, seekCount: $seekCount)';
}


}

/// @nodoc
abstract mixin class $PlayEventCopyWith<$Res>  {
  factory $PlayEventCopyWith(PlayEvent value, $Res Function(PlayEvent) _then) = _$PlayEventCopyWithImpl;
@useResult
$Res call({
 String id, String trackId, String sessionId, DateTime startedAt, int durationMs, int listenedMs, double completionRatio, bool skipped, PlaySource source, TimeOfDayBucket timeOfDayBucket, int dayOfWeek, DateTime? endedAt, int? skipAtMs, double playbackSpeed, bool wasOffline, int seekCount
});




}
/// @nodoc
class _$PlayEventCopyWithImpl<$Res>
    implements $PlayEventCopyWith<$Res> {
  _$PlayEventCopyWithImpl(this._self, this._then);

  final PlayEvent _self;
  final $Res Function(PlayEvent) _then;

/// Create a copy of PlayEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? trackId = null,Object? sessionId = null,Object? startedAt = null,Object? durationMs = null,Object? listenedMs = null,Object? completionRatio = null,Object? skipped = null,Object? source = null,Object? timeOfDayBucket = null,Object? dayOfWeek = null,Object? endedAt = freezed,Object? skipAtMs = freezed,Object? playbackSpeed = null,Object? wasOffline = null,Object? seekCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,trackId: null == trackId ? _self.trackId : trackId // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,listenedMs: null == listenedMs ? _self.listenedMs : listenedMs // ignore: cast_nullable_to_non_nullable
as int,completionRatio: null == completionRatio ? _self.completionRatio : completionRatio // ignore: cast_nullable_to_non_nullable
as double,skipped: null == skipped ? _self.skipped : skipped // ignore: cast_nullable_to_non_nullable
as bool,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as PlaySource,timeOfDayBucket: null == timeOfDayBucket ? _self.timeOfDayBucket : timeOfDayBucket // ignore: cast_nullable_to_non_nullable
as TimeOfDayBucket,dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as int,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,skipAtMs: freezed == skipAtMs ? _self.skipAtMs : skipAtMs // ignore: cast_nullable_to_non_nullable
as int?,playbackSpeed: null == playbackSpeed ? _self.playbackSpeed : playbackSpeed // ignore: cast_nullable_to_non_nullable
as double,wasOffline: null == wasOffline ? _self.wasOffline : wasOffline // ignore: cast_nullable_to_non_nullable
as bool,seekCount: null == seekCount ? _self.seekCount : seekCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PlayEvent].
extension PlayEventPatterns on PlayEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayEvent value)  $default,){
final _that = this;
switch (_that) {
case _PlayEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayEvent value)?  $default,){
final _that = this;
switch (_that) {
case _PlayEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String trackId,  String sessionId,  DateTime startedAt,  int durationMs,  int listenedMs,  double completionRatio,  bool skipped,  PlaySource source,  TimeOfDayBucket timeOfDayBucket,  int dayOfWeek,  DateTime? endedAt,  int? skipAtMs,  double playbackSpeed,  bool wasOffline,  int seekCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayEvent() when $default != null:
return $default(_that.id,_that.trackId,_that.sessionId,_that.startedAt,_that.durationMs,_that.listenedMs,_that.completionRatio,_that.skipped,_that.source,_that.timeOfDayBucket,_that.dayOfWeek,_that.endedAt,_that.skipAtMs,_that.playbackSpeed,_that.wasOffline,_that.seekCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String trackId,  String sessionId,  DateTime startedAt,  int durationMs,  int listenedMs,  double completionRatio,  bool skipped,  PlaySource source,  TimeOfDayBucket timeOfDayBucket,  int dayOfWeek,  DateTime? endedAt,  int? skipAtMs,  double playbackSpeed,  bool wasOffline,  int seekCount)  $default,) {final _that = this;
switch (_that) {
case _PlayEvent():
return $default(_that.id,_that.trackId,_that.sessionId,_that.startedAt,_that.durationMs,_that.listenedMs,_that.completionRatio,_that.skipped,_that.source,_that.timeOfDayBucket,_that.dayOfWeek,_that.endedAt,_that.skipAtMs,_that.playbackSpeed,_that.wasOffline,_that.seekCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String trackId,  String sessionId,  DateTime startedAt,  int durationMs,  int listenedMs,  double completionRatio,  bool skipped,  PlaySource source,  TimeOfDayBucket timeOfDayBucket,  int dayOfWeek,  DateTime? endedAt,  int? skipAtMs,  double playbackSpeed,  bool wasOffline,  int seekCount)?  $default,) {final _that = this;
switch (_that) {
case _PlayEvent() when $default != null:
return $default(_that.id,_that.trackId,_that.sessionId,_that.startedAt,_that.durationMs,_that.listenedMs,_that.completionRatio,_that.skipped,_that.source,_that.timeOfDayBucket,_that.dayOfWeek,_that.endedAt,_that.skipAtMs,_that.playbackSpeed,_that.wasOffline,_that.seekCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlayEvent extends PlayEvent {
  const _PlayEvent({required this.id, required this.trackId, required this.sessionId, required this.startedAt, required this.durationMs, required this.listenedMs, required this.completionRatio, required this.skipped, required this.source, required this.timeOfDayBucket, required this.dayOfWeek, this.endedAt, this.skipAtMs, this.playbackSpeed = 1.0, this.wasOffline = false, this.seekCount = 0}): super._();
  factory _PlayEvent.fromJson(Map<String, dynamic> json) => _$PlayEventFromJson(json);

/// Event id (uuid v7).
@override final  String id;
/// Played track id.
@override final  String trackId;
/// Playback session id (rotated on cold start / 30 min idle).
@override final  String sessionId;
/// Playback start (UTC).
@override final  DateTime startedAt;
/// Track length at play time, in milliseconds.
@override final  int durationMs;
/// Milliseconds actually heard (excluding seeks over content).
@override final  int listenedMs;
/// `listenedMs / max(durationMs, 1)`, clamped 0..1.
@override final  double completionRatio;
/// User moved on before `completionRatio` reached 0.85.
/// Auto-next after a genuine complete is NOT a skip.
@override final  bool skipped;
/// Where playback originated.
@override final  PlaySource source;
/// Local-time bucket derived from [startedAt].
@override final  TimeOfDayBucket timeOfDayBucket;
/// `startedAt.weekday % 7` (Monday 1 .. Sunday 0).
@override final  int dayOfWeek;
/// Playback end, if the observation window closed (UTC).
@override final  DateTime? endedAt;
/// Position of the skip, if `skipped`.
@override final  int? skipAtMs;
/// Playback speed multiplier (1.0 until Phase 5).
@override@JsonKey() final  double playbackSpeed;
/// Whether the device was offline during playback.
@override@JsonKey() final  bool wasOffline;
/// Seek gestures observed during this event.
@override@JsonKey() final  int seekCount;

/// Create a copy of PlayEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayEventCopyWith<_PlayEvent> get copyWith => __$PlayEventCopyWithImpl<_PlayEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.trackId, trackId) || other.trackId == trackId)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.listenedMs, listenedMs) || other.listenedMs == listenedMs)&&(identical(other.completionRatio, completionRatio) || other.completionRatio == completionRatio)&&(identical(other.skipped, skipped) || other.skipped == skipped)&&(identical(other.source, source) || other.source == source)&&(identical(other.timeOfDayBucket, timeOfDayBucket) || other.timeOfDayBucket == timeOfDayBucket)&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.skipAtMs, skipAtMs) || other.skipAtMs == skipAtMs)&&(identical(other.playbackSpeed, playbackSpeed) || other.playbackSpeed == playbackSpeed)&&(identical(other.wasOffline, wasOffline) || other.wasOffline == wasOffline)&&(identical(other.seekCount, seekCount) || other.seekCount == seekCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,trackId,sessionId,startedAt,durationMs,listenedMs,completionRatio,skipped,source,timeOfDayBucket,dayOfWeek,endedAt,skipAtMs,playbackSpeed,wasOffline,seekCount);

@override
String toString() {
  return 'PlayEvent(id: $id, trackId: $trackId, sessionId: $sessionId, startedAt: $startedAt, durationMs: $durationMs, listenedMs: $listenedMs, completionRatio: $completionRatio, skipped: $skipped, source: $source, timeOfDayBucket: $timeOfDayBucket, dayOfWeek: $dayOfWeek, endedAt: $endedAt, skipAtMs: $skipAtMs, playbackSpeed: $playbackSpeed, wasOffline: $wasOffline, seekCount: $seekCount)';
}


}

/// @nodoc
abstract mixin class _$PlayEventCopyWith<$Res> implements $PlayEventCopyWith<$Res> {
  factory _$PlayEventCopyWith(_PlayEvent value, $Res Function(_PlayEvent) _then) = __$PlayEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String trackId, String sessionId, DateTime startedAt, int durationMs, int listenedMs, double completionRatio, bool skipped, PlaySource source, TimeOfDayBucket timeOfDayBucket, int dayOfWeek, DateTime? endedAt, int? skipAtMs, double playbackSpeed, bool wasOffline, int seekCount
});




}
/// @nodoc
class __$PlayEventCopyWithImpl<$Res>
    implements _$PlayEventCopyWith<$Res> {
  __$PlayEventCopyWithImpl(this._self, this._then);

  final _PlayEvent _self;
  final $Res Function(_PlayEvent) _then;

/// Create a copy of PlayEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? trackId = null,Object? sessionId = null,Object? startedAt = null,Object? durationMs = null,Object? listenedMs = null,Object? completionRatio = null,Object? skipped = null,Object? source = null,Object? timeOfDayBucket = null,Object? dayOfWeek = null,Object? endedAt = freezed,Object? skipAtMs = freezed,Object? playbackSpeed = null,Object? wasOffline = null,Object? seekCount = null,}) {
  return _then(_PlayEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,trackId: null == trackId ? _self.trackId : trackId // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,listenedMs: null == listenedMs ? _self.listenedMs : listenedMs // ignore: cast_nullable_to_non_nullable
as int,completionRatio: null == completionRatio ? _self.completionRatio : completionRatio // ignore: cast_nullable_to_non_nullable
as double,skipped: null == skipped ? _self.skipped : skipped // ignore: cast_nullable_to_non_nullable
as bool,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as PlaySource,timeOfDayBucket: null == timeOfDayBucket ? _self.timeOfDayBucket : timeOfDayBucket // ignore: cast_nullable_to_non_nullable
as TimeOfDayBucket,dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as int,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,skipAtMs: freezed == skipAtMs ? _self.skipAtMs : skipAtMs // ignore: cast_nullable_to_non_nullable
as int?,playbackSpeed: null == playbackSpeed ? _self.playbackSpeed : playbackSpeed // ignore: cast_nullable_to_non_nullable
as double,wasOffline: null == wasOffline ? _self.wasOffline : wasOffline // ignore: cast_nullable_to_non_nullable
as bool,seekCount: null == seekCount ? _self.seekCount : seekCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on

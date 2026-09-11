// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_track_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserTrackStats {

/// Observed track id.
 String get trackId;/// Last update time (UTC).
 DateTime get updatedAt;/// Started plays (noise-filtered, see section 9).
 int get playCount;/// Skipped plays.
 int get skipCount;/// Plays with `completionRatio` >= 0.85.
 int get completeCount;/// Restarts within 10s of a complete (or replays within 30s).
 int get replayCount;/// Total heard milliseconds across all plays.
 int get totalListenMs;/// Last play time (UTC), null when never played.
 DateTime? get lastPlayedAt;/// -1 dislike, 0 none, 1 like.
 int get likeState;/// Time-decayed aggregate score.
 double get decayedScore;
/// Create a copy of UserTrackStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserTrackStatsCopyWith<UserTrackStats> get copyWith => _$UserTrackStatsCopyWithImpl<UserTrackStats>(this as UserTrackStats, _$identity);

  /// Serializes this UserTrackStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserTrackStats&&(identical(other.trackId, trackId) || other.trackId == trackId)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.playCount, playCount) || other.playCount == playCount)&&(identical(other.skipCount, skipCount) || other.skipCount == skipCount)&&(identical(other.completeCount, completeCount) || other.completeCount == completeCount)&&(identical(other.replayCount, replayCount) || other.replayCount == replayCount)&&(identical(other.totalListenMs, totalListenMs) || other.totalListenMs == totalListenMs)&&(identical(other.lastPlayedAt, lastPlayedAt) || other.lastPlayedAt == lastPlayedAt)&&(identical(other.likeState, likeState) || other.likeState == likeState)&&(identical(other.decayedScore, decayedScore) || other.decayedScore == decayedScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,trackId,updatedAt,playCount,skipCount,completeCount,replayCount,totalListenMs,lastPlayedAt,likeState,decayedScore);

@override
String toString() {
  return 'UserTrackStats(trackId: $trackId, updatedAt: $updatedAt, playCount: $playCount, skipCount: $skipCount, completeCount: $completeCount, replayCount: $replayCount, totalListenMs: $totalListenMs, lastPlayedAt: $lastPlayedAt, likeState: $likeState, decayedScore: $decayedScore)';
}


}

/// @nodoc
abstract mixin class $UserTrackStatsCopyWith<$Res>  {
  factory $UserTrackStatsCopyWith(UserTrackStats value, $Res Function(UserTrackStats) _then) = _$UserTrackStatsCopyWithImpl;
@useResult
$Res call({
 String trackId, DateTime updatedAt, int playCount, int skipCount, int completeCount, int replayCount, int totalListenMs, DateTime? lastPlayedAt, int likeState, double decayedScore
});




}
/// @nodoc
class _$UserTrackStatsCopyWithImpl<$Res>
    implements $UserTrackStatsCopyWith<$Res> {
  _$UserTrackStatsCopyWithImpl(this._self, this._then);

  final UserTrackStats _self;
  final $Res Function(UserTrackStats) _then;

/// Create a copy of UserTrackStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? trackId = null,Object? updatedAt = null,Object? playCount = null,Object? skipCount = null,Object? completeCount = null,Object? replayCount = null,Object? totalListenMs = null,Object? lastPlayedAt = freezed,Object? likeState = null,Object? decayedScore = null,}) {
  return _then(_self.copyWith(
trackId: null == trackId ? _self.trackId : trackId // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,playCount: null == playCount ? _self.playCount : playCount // ignore: cast_nullable_to_non_nullable
as int,skipCount: null == skipCount ? _self.skipCount : skipCount // ignore: cast_nullable_to_non_nullable
as int,completeCount: null == completeCount ? _self.completeCount : completeCount // ignore: cast_nullable_to_non_nullable
as int,replayCount: null == replayCount ? _self.replayCount : replayCount // ignore: cast_nullable_to_non_nullable
as int,totalListenMs: null == totalListenMs ? _self.totalListenMs : totalListenMs // ignore: cast_nullable_to_non_nullable
as int,lastPlayedAt: freezed == lastPlayedAt ? _self.lastPlayedAt : lastPlayedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,likeState: null == likeState ? _self.likeState : likeState // ignore: cast_nullable_to_non_nullable
as int,decayedScore: null == decayedScore ? _self.decayedScore : decayedScore // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [UserTrackStats].
extension UserTrackStatsPatterns on UserTrackStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserTrackStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserTrackStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserTrackStats value)  $default,){
final _that = this;
switch (_that) {
case _UserTrackStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserTrackStats value)?  $default,){
final _that = this;
switch (_that) {
case _UserTrackStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String trackId,  DateTime updatedAt,  int playCount,  int skipCount,  int completeCount,  int replayCount,  int totalListenMs,  DateTime? lastPlayedAt,  int likeState,  double decayedScore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserTrackStats() when $default != null:
return $default(_that.trackId,_that.updatedAt,_that.playCount,_that.skipCount,_that.completeCount,_that.replayCount,_that.totalListenMs,_that.lastPlayedAt,_that.likeState,_that.decayedScore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String trackId,  DateTime updatedAt,  int playCount,  int skipCount,  int completeCount,  int replayCount,  int totalListenMs,  DateTime? lastPlayedAt,  int likeState,  double decayedScore)  $default,) {final _that = this;
switch (_that) {
case _UserTrackStats():
return $default(_that.trackId,_that.updatedAt,_that.playCount,_that.skipCount,_that.completeCount,_that.replayCount,_that.totalListenMs,_that.lastPlayedAt,_that.likeState,_that.decayedScore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String trackId,  DateTime updatedAt,  int playCount,  int skipCount,  int completeCount,  int replayCount,  int totalListenMs,  DateTime? lastPlayedAt,  int likeState,  double decayedScore)?  $default,) {final _that = this;
switch (_that) {
case _UserTrackStats() when $default != null:
return $default(_that.trackId,_that.updatedAt,_that.playCount,_that.skipCount,_that.completeCount,_that.replayCount,_that.totalListenMs,_that.lastPlayedAt,_that.likeState,_that.decayedScore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserTrackStats extends UserTrackStats {
  const _UserTrackStats({required this.trackId, required this.updatedAt, this.playCount = 0, this.skipCount = 0, this.completeCount = 0, this.replayCount = 0, this.totalListenMs = 0, this.lastPlayedAt, this.likeState = 0, this.decayedScore = 0}): super._();
  factory _UserTrackStats.fromJson(Map<String, dynamic> json) => _$UserTrackStatsFromJson(json);

/// Observed track id.
@override final  String trackId;
/// Last update time (UTC).
@override final  DateTime updatedAt;
/// Started plays (noise-filtered, see section 9).
@override@JsonKey() final  int playCount;
/// Skipped plays.
@override@JsonKey() final  int skipCount;
/// Plays with `completionRatio` >= 0.85.
@override@JsonKey() final  int completeCount;
/// Restarts within 10s of a complete (or replays within 30s).
@override@JsonKey() final  int replayCount;
/// Total heard milliseconds across all plays.
@override@JsonKey() final  int totalListenMs;
/// Last play time (UTC), null when never played.
@override final  DateTime? lastPlayedAt;
/// -1 dislike, 0 none, 1 like.
@override@JsonKey() final  int likeState;
/// Time-decayed aggregate score.
@override@JsonKey() final  double decayedScore;

/// Create a copy of UserTrackStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserTrackStatsCopyWith<_UserTrackStats> get copyWith => __$UserTrackStatsCopyWithImpl<_UserTrackStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserTrackStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserTrackStats&&(identical(other.trackId, trackId) || other.trackId == trackId)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.playCount, playCount) || other.playCount == playCount)&&(identical(other.skipCount, skipCount) || other.skipCount == skipCount)&&(identical(other.completeCount, completeCount) || other.completeCount == completeCount)&&(identical(other.replayCount, replayCount) || other.replayCount == replayCount)&&(identical(other.totalListenMs, totalListenMs) || other.totalListenMs == totalListenMs)&&(identical(other.lastPlayedAt, lastPlayedAt) || other.lastPlayedAt == lastPlayedAt)&&(identical(other.likeState, likeState) || other.likeState == likeState)&&(identical(other.decayedScore, decayedScore) || other.decayedScore == decayedScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,trackId,updatedAt,playCount,skipCount,completeCount,replayCount,totalListenMs,lastPlayedAt,likeState,decayedScore);

@override
String toString() {
  return 'UserTrackStats(trackId: $trackId, updatedAt: $updatedAt, playCount: $playCount, skipCount: $skipCount, completeCount: $completeCount, replayCount: $replayCount, totalListenMs: $totalListenMs, lastPlayedAt: $lastPlayedAt, likeState: $likeState, decayedScore: $decayedScore)';
}


}

/// @nodoc
abstract mixin class _$UserTrackStatsCopyWith<$Res> implements $UserTrackStatsCopyWith<$Res> {
  factory _$UserTrackStatsCopyWith(_UserTrackStats value, $Res Function(_UserTrackStats) _then) = __$UserTrackStatsCopyWithImpl;
@override @useResult
$Res call({
 String trackId, DateTime updatedAt, int playCount, int skipCount, int completeCount, int replayCount, int totalListenMs, DateTime? lastPlayedAt, int likeState, double decayedScore
});




}
/// @nodoc
class __$UserTrackStatsCopyWithImpl<$Res>
    implements _$UserTrackStatsCopyWith<$Res> {
  __$UserTrackStatsCopyWithImpl(this._self, this._then);

  final _UserTrackStats _self;
  final $Res Function(_UserTrackStats) _then;

/// Create a copy of UserTrackStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? trackId = null,Object? updatedAt = null,Object? playCount = null,Object? skipCount = null,Object? completeCount = null,Object? replayCount = null,Object? totalListenMs = null,Object? lastPlayedAt = freezed,Object? likeState = null,Object? decayedScore = null,}) {
  return _then(_UserTrackStats(
trackId: null == trackId ? _self.trackId : trackId // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,playCount: null == playCount ? _self.playCount : playCount // ignore: cast_nullable_to_non_nullable
as int,skipCount: null == skipCount ? _self.skipCount : skipCount // ignore: cast_nullable_to_non_nullable
as int,completeCount: null == completeCount ? _self.completeCount : completeCount // ignore: cast_nullable_to_non_nullable
as int,replayCount: null == replayCount ? _self.replayCount : replayCount // ignore: cast_nullable_to_non_nullable
as int,totalListenMs: null == totalListenMs ? _self.totalListenMs : totalListenMs // ignore: cast_nullable_to_non_nullable
as int,lastPlayedAt: freezed == lastPlayedAt ? _self.lastPlayedAt : lastPlayedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,likeState: null == likeState ? _self.likeState : likeState // ignore: cast_nullable_to_non_nullable
as int,decayedScore: null == decayedScore ? _self.decayedScore : decayedScore // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on

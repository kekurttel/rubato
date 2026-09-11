// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'queue_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$QueueItem {

/// Queue row id (uuid v7).
 String get id;/// Queued track id.
 String get trackId;/// Where the item was enqueued from.
 PlaySource get origin;/// Enqueue time (UTC).
 DateTime get addedAt;/// Ranker score frozen at enqueue time, if ranked.
 double? get frozenScore;
/// Create a copy of QueueItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QueueItemCopyWith<QueueItem> get copyWith => _$QueueItemCopyWithImpl<QueueItem>(this as QueueItem, _$identity);

  /// Serializes this QueueItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QueueItem&&(identical(other.id, id) || other.id == id)&&(identical(other.trackId, trackId) || other.trackId == trackId)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt)&&(identical(other.frozenScore, frozenScore) || other.frozenScore == frozenScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,trackId,origin,addedAt,frozenScore);

@override
String toString() {
  return 'QueueItem(id: $id, trackId: $trackId, origin: $origin, addedAt: $addedAt, frozenScore: $frozenScore)';
}


}

/// @nodoc
abstract mixin class $QueueItemCopyWith<$Res>  {
  factory $QueueItemCopyWith(QueueItem value, $Res Function(QueueItem) _then) = _$QueueItemCopyWithImpl;
@useResult
$Res call({
 String id, String trackId, PlaySource origin, DateTime addedAt, double? frozenScore
});




}
/// @nodoc
class _$QueueItemCopyWithImpl<$Res>
    implements $QueueItemCopyWith<$Res> {
  _$QueueItemCopyWithImpl(this._self, this._then);

  final QueueItem _self;
  final $Res Function(QueueItem) _then;

/// Create a copy of QueueItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? trackId = null,Object? origin = null,Object? addedAt = null,Object? frozenScore = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,trackId: null == trackId ? _self.trackId : trackId // ignore: cast_nullable_to_non_nullable
as String,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as PlaySource,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime,frozenScore: freezed == frozenScore ? _self.frozenScore : frozenScore // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [QueueItem].
extension QueueItemPatterns on QueueItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QueueItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QueueItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QueueItem value)  $default,){
final _that = this;
switch (_that) {
case _QueueItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QueueItem value)?  $default,){
final _that = this;
switch (_that) {
case _QueueItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String trackId,  PlaySource origin,  DateTime addedAt,  double? frozenScore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QueueItem() when $default != null:
return $default(_that.id,_that.trackId,_that.origin,_that.addedAt,_that.frozenScore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String trackId,  PlaySource origin,  DateTime addedAt,  double? frozenScore)  $default,) {final _that = this;
switch (_that) {
case _QueueItem():
return $default(_that.id,_that.trackId,_that.origin,_that.addedAt,_that.frozenScore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String trackId,  PlaySource origin,  DateTime addedAt,  double? frozenScore)?  $default,) {final _that = this;
switch (_that) {
case _QueueItem() when $default != null:
return $default(_that.id,_that.trackId,_that.origin,_that.addedAt,_that.frozenScore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QueueItem extends QueueItem {
  const _QueueItem({required this.id, required this.trackId, required this.origin, required this.addedAt, this.frozenScore}): super._();
  factory _QueueItem.fromJson(Map<String, dynamic> json) => _$QueueItemFromJson(json);

/// Queue row id (uuid v7).
@override final  String id;
/// Queued track id.
@override final  String trackId;
/// Where the item was enqueued from.
@override final  PlaySource origin;
/// Enqueue time (UTC).
@override final  DateTime addedAt;
/// Ranker score frozen at enqueue time, if ranked.
@override final  double? frozenScore;

/// Create a copy of QueueItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QueueItemCopyWith<_QueueItem> get copyWith => __$QueueItemCopyWithImpl<_QueueItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QueueItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QueueItem&&(identical(other.id, id) || other.id == id)&&(identical(other.trackId, trackId) || other.trackId == trackId)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt)&&(identical(other.frozenScore, frozenScore) || other.frozenScore == frozenScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,trackId,origin,addedAt,frozenScore);

@override
String toString() {
  return 'QueueItem(id: $id, trackId: $trackId, origin: $origin, addedAt: $addedAt, frozenScore: $frozenScore)';
}


}

/// @nodoc
abstract mixin class _$QueueItemCopyWith<$Res> implements $QueueItemCopyWith<$Res> {
  factory _$QueueItemCopyWith(_QueueItem value, $Res Function(_QueueItem) _then) = __$QueueItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String trackId, PlaySource origin, DateTime addedAt, double? frozenScore
});




}
/// @nodoc
class __$QueueItemCopyWithImpl<$Res>
    implements _$QueueItemCopyWith<$Res> {
  __$QueueItemCopyWithImpl(this._self, this._then);

  final _QueueItem _self;
  final $Res Function(_QueueItem) _then;

/// Create a copy of QueueItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? trackId = null,Object? origin = null,Object? addedAt = null,Object? frozenScore = freezed,}) {
  return _then(_QueueItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,trackId: null == trackId ? _self.trackId : trackId // ignore: cast_nullable_to_non_nullable
as String,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as PlaySource,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime,frozenScore: freezed == frozenScore ? _self.frozenScore : frozenScore // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on

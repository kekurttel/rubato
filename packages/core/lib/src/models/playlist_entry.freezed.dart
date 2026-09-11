// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playlist_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlaylistEntry {

/// Owning playlist id.
 String get playlistId;/// Member track id.
 String get trackId;/// Zero-based order inside the playlist.
 int get position;/// Time the track was added (UTC).
 DateTime get addedAt;
/// Create a copy of PlaylistEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaylistEntryCopyWith<PlaylistEntry> get copyWith => _$PlaylistEntryCopyWithImpl<PlaylistEntry>(this as PlaylistEntry, _$identity);

  /// Serializes this PlaylistEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaylistEntry&&(identical(other.playlistId, playlistId) || other.playlistId == playlistId)&&(identical(other.trackId, trackId) || other.trackId == trackId)&&(identical(other.position, position) || other.position == position)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,playlistId,trackId,position,addedAt);

@override
String toString() {
  return 'PlaylistEntry(playlistId: $playlistId, trackId: $trackId, position: $position, addedAt: $addedAt)';
}


}

/// @nodoc
abstract mixin class $PlaylistEntryCopyWith<$Res>  {
  factory $PlaylistEntryCopyWith(PlaylistEntry value, $Res Function(PlaylistEntry) _then) = _$PlaylistEntryCopyWithImpl;
@useResult
$Res call({
 String playlistId, String trackId, int position, DateTime addedAt
});




}
/// @nodoc
class _$PlaylistEntryCopyWithImpl<$Res>
    implements $PlaylistEntryCopyWith<$Res> {
  _$PlaylistEntryCopyWithImpl(this._self, this._then);

  final PlaylistEntry _self;
  final $Res Function(PlaylistEntry) _then;

/// Create a copy of PlaylistEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? playlistId = null,Object? trackId = null,Object? position = null,Object? addedAt = null,}) {
  return _then(_self.copyWith(
playlistId: null == playlistId ? _self.playlistId : playlistId // ignore: cast_nullable_to_non_nullable
as String,trackId: null == trackId ? _self.trackId : trackId // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PlaylistEntry].
extension PlaylistEntryPatterns on PlaylistEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaylistEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaylistEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaylistEntry value)  $default,){
final _that = this;
switch (_that) {
case _PlaylistEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaylistEntry value)?  $default,){
final _that = this;
switch (_that) {
case _PlaylistEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String playlistId,  String trackId,  int position,  DateTime addedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaylistEntry() when $default != null:
return $default(_that.playlistId,_that.trackId,_that.position,_that.addedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String playlistId,  String trackId,  int position,  DateTime addedAt)  $default,) {final _that = this;
switch (_that) {
case _PlaylistEntry():
return $default(_that.playlistId,_that.trackId,_that.position,_that.addedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String playlistId,  String trackId,  int position,  DateTime addedAt)?  $default,) {final _that = this;
switch (_that) {
case _PlaylistEntry() when $default != null:
return $default(_that.playlistId,_that.trackId,_that.position,_that.addedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlaylistEntry extends PlaylistEntry {
  const _PlaylistEntry({required this.playlistId, required this.trackId, required this.position, required this.addedAt}): super._();
  factory _PlaylistEntry.fromJson(Map<String, dynamic> json) => _$PlaylistEntryFromJson(json);

/// Owning playlist id.
@override final  String playlistId;
/// Member track id.
@override final  String trackId;
/// Zero-based order inside the playlist.
@override final  int position;
/// Time the track was added (UTC).
@override final  DateTime addedAt;

/// Create a copy of PlaylistEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaylistEntryCopyWith<_PlaylistEntry> get copyWith => __$PlaylistEntryCopyWithImpl<_PlaylistEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlaylistEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaylistEntry&&(identical(other.playlistId, playlistId) || other.playlistId == playlistId)&&(identical(other.trackId, trackId) || other.trackId == trackId)&&(identical(other.position, position) || other.position == position)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,playlistId,trackId,position,addedAt);

@override
String toString() {
  return 'PlaylistEntry(playlistId: $playlistId, trackId: $trackId, position: $position, addedAt: $addedAt)';
}


}

/// @nodoc
abstract mixin class _$PlaylistEntryCopyWith<$Res> implements $PlaylistEntryCopyWith<$Res> {
  factory _$PlaylistEntryCopyWith(_PlaylistEntry value, $Res Function(_PlaylistEntry) _then) = __$PlaylistEntryCopyWithImpl;
@override @useResult
$Res call({
 String playlistId, String trackId, int position, DateTime addedAt
});




}
/// @nodoc
class __$PlaylistEntryCopyWithImpl<$Res>
    implements _$PlaylistEntryCopyWith<$Res> {
  __$PlaylistEntryCopyWithImpl(this._self, this._then);

  final _PlaylistEntry _self;
  final $Res Function(_PlaylistEntry) _then;

/// Create a copy of PlaylistEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? playlistId = null,Object? trackId = null,Object? position = null,Object? addedAt = null,}) {
  return _then(_PlaylistEntry(
playlistId: null == playlistId ? _self.playlistId : playlistId // ignore: cast_nullable_to_non_nullable
as String,trackId: null == trackId ? _self.trackId : trackId // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on

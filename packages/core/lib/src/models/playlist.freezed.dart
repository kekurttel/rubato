// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playlist.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Playlist {

/// Playlist id (uuid v7; system ids are well-known strings).
 String get id;/// Display title.
 String get title;/// Creation time (UTC).
 DateTime get createdAt;/// Last modification time (UTC).
 DateTime get updatedAt;/// Optional user description.
 String? get description;/// Cover artwork id, if any.
 String? get artworkId;/// Whether this is a built-in system playlist.
 bool get isSystem;
/// Create a copy of Playlist
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaylistCopyWith<Playlist> get copyWith => _$PlaylistCopyWithImpl<Playlist>(this as Playlist, _$identity);

  /// Serializes this Playlist to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Playlist&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.description, description) || other.description == description)&&(identical(other.artworkId, artworkId) || other.artworkId == artworkId)&&(identical(other.isSystem, isSystem) || other.isSystem == isSystem));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,createdAt,updatedAt,description,artworkId,isSystem);

@override
String toString() {
  return 'Playlist(id: $id, title: $title, createdAt: $createdAt, updatedAt: $updatedAt, description: $description, artworkId: $artworkId, isSystem: $isSystem)';
}


}

/// @nodoc
abstract mixin class $PlaylistCopyWith<$Res>  {
  factory $PlaylistCopyWith(Playlist value, $Res Function(Playlist) _then) = _$PlaylistCopyWithImpl;
@useResult
$Res call({
 String id, String title, DateTime createdAt, DateTime updatedAt, String? description, String? artworkId, bool isSystem
});




}
/// @nodoc
class _$PlaylistCopyWithImpl<$Res>
    implements $PlaylistCopyWith<$Res> {
  _$PlaylistCopyWithImpl(this._self, this._then);

  final Playlist _self;
  final $Res Function(Playlist) _then;

/// Create a copy of Playlist
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? createdAt = null,Object? updatedAt = null,Object? description = freezed,Object? artworkId = freezed,Object? isSystem = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,artworkId: freezed == artworkId ? _self.artworkId : artworkId // ignore: cast_nullable_to_non_nullable
as String?,isSystem: null == isSystem ? _self.isSystem : isSystem // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Playlist].
extension PlaylistPatterns on Playlist {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Playlist value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Playlist() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Playlist value)  $default,){
final _that = this;
switch (_that) {
case _Playlist():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Playlist value)?  $default,){
final _that = this;
switch (_that) {
case _Playlist() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  DateTime createdAt,  DateTime updatedAt,  String? description,  String? artworkId,  bool isSystem)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Playlist() when $default != null:
return $default(_that.id,_that.title,_that.createdAt,_that.updatedAt,_that.description,_that.artworkId,_that.isSystem);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  DateTime createdAt,  DateTime updatedAt,  String? description,  String? artworkId,  bool isSystem)  $default,) {final _that = this;
switch (_that) {
case _Playlist():
return $default(_that.id,_that.title,_that.createdAt,_that.updatedAt,_that.description,_that.artworkId,_that.isSystem);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  DateTime createdAt,  DateTime updatedAt,  String? description,  String? artworkId,  bool isSystem)?  $default,) {final _that = this;
switch (_that) {
case _Playlist() when $default != null:
return $default(_that.id,_that.title,_that.createdAt,_that.updatedAt,_that.description,_that.artworkId,_that.isSystem);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Playlist extends Playlist {
  const _Playlist({required this.id, required this.title, required this.createdAt, required this.updatedAt, this.description, this.artworkId, this.isSystem = false}): super._();
  factory _Playlist.fromJson(Map<String, dynamic> json) => _$PlaylistFromJson(json);

/// Playlist id (uuid v7; system ids are well-known strings).
@override final  String id;
/// Display title.
@override final  String title;
/// Creation time (UTC).
@override final  DateTime createdAt;
/// Last modification time (UTC).
@override final  DateTime updatedAt;
/// Optional user description.
@override final  String? description;
/// Cover artwork id, if any.
@override final  String? artworkId;
/// Whether this is a built-in system playlist.
@override@JsonKey() final  bool isSystem;

/// Create a copy of Playlist
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaylistCopyWith<_Playlist> get copyWith => __$PlaylistCopyWithImpl<_Playlist>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlaylistToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Playlist&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.description, description) || other.description == description)&&(identical(other.artworkId, artworkId) || other.artworkId == artworkId)&&(identical(other.isSystem, isSystem) || other.isSystem == isSystem));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,createdAt,updatedAt,description,artworkId,isSystem);

@override
String toString() {
  return 'Playlist(id: $id, title: $title, createdAt: $createdAt, updatedAt: $updatedAt, description: $description, artworkId: $artworkId, isSystem: $isSystem)';
}


}

/// @nodoc
abstract mixin class _$PlaylistCopyWith<$Res> implements $PlaylistCopyWith<$Res> {
  factory _$PlaylistCopyWith(_Playlist value, $Res Function(_Playlist) _then) = __$PlaylistCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, DateTime createdAt, DateTime updatedAt, String? description, String? artworkId, bool isSystem
});




}
/// @nodoc
class __$PlaylistCopyWithImpl<$Res>
    implements _$PlaylistCopyWith<$Res> {
  __$PlaylistCopyWithImpl(this._self, this._then);

  final _Playlist _self;
  final $Res Function(_Playlist) _then;

/// Create a copy of Playlist
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? createdAt = null,Object? updatedAt = null,Object? description = freezed,Object? artworkId = freezed,Object? isSystem = null,}) {
  return _then(_Playlist(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,artworkId: freezed == artworkId ? _self.artworkId : artworkId // ignore: cast_nullable_to_non_nullable
as String?,isSystem: null == isSystem ? _self.isSystem : isSystem // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

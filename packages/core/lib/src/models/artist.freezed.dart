// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'artist.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Artist {

/// Composite `${providerId}:${sourceId}` id.
 String get id;/// Display name.
 String get name;/// Provider-scoped id.
 String get sourceId;/// Owning provider (`local`, `fake`, `ytdlp`).
 String get providerId;/// Genre ids.
 List<String> get genres;/// Artwork URL, if the provider supplied one.
 String? get imageUrl;
/// Create a copy of Artist
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ArtistCopyWith<Artist> get copyWith => _$ArtistCopyWithImpl<Artist>(this as Artist, _$identity);

  /// Serializes this Artist to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Artist&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.providerId, providerId) || other.providerId == providerId)&&const DeepCollectionEquality().equals(other.genres, genres)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,sourceId,providerId,const DeepCollectionEquality().hash(genres),imageUrl);

@override
String toString() {
  return 'Artist(id: $id, name: $name, sourceId: $sourceId, providerId: $providerId, genres: $genres, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class $ArtistCopyWith<$Res>  {
  factory $ArtistCopyWith(Artist value, $Res Function(Artist) _then) = _$ArtistCopyWithImpl;
@useResult
$Res call({
 String id, String name, String sourceId, String providerId, List<String> genres, String? imageUrl
});




}
/// @nodoc
class _$ArtistCopyWithImpl<$Res>
    implements $ArtistCopyWith<$Res> {
  _$ArtistCopyWithImpl(this._self, this._then);

  final Artist _self;
  final $Res Function(Artist) _then;

/// Create a copy of Artist
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? sourceId = null,Object? providerId = null,Object? genres = null,Object? imageUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sourceId: null == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String,providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,genres: null == genres ? _self.genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Artist].
extension ArtistPatterns on Artist {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Artist value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Artist() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Artist value)  $default,){
final _that = this;
switch (_that) {
case _Artist():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Artist value)?  $default,){
final _that = this;
switch (_that) {
case _Artist() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String sourceId,  String providerId,  List<String> genres,  String? imageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Artist() when $default != null:
return $default(_that.id,_that.name,_that.sourceId,_that.providerId,_that.genres,_that.imageUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String sourceId,  String providerId,  List<String> genres,  String? imageUrl)  $default,) {final _that = this;
switch (_that) {
case _Artist():
return $default(_that.id,_that.name,_that.sourceId,_that.providerId,_that.genres,_that.imageUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String sourceId,  String providerId,  List<String> genres,  String? imageUrl)?  $default,) {final _that = this;
switch (_that) {
case _Artist() when $default != null:
return $default(_that.id,_that.name,_that.sourceId,_that.providerId,_that.genres,_that.imageUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Artist extends Artist {
  const _Artist({required this.id, required this.name, required this.sourceId, required this.providerId, final  List<String> genres = const <String>[], this.imageUrl}): _genres = genres,super._();
  factory _Artist.fromJson(Map<String, dynamic> json) => _$ArtistFromJson(json);

/// Composite `${providerId}:${sourceId}` id.
@override final  String id;
/// Display name.
@override final  String name;
/// Provider-scoped id.
@override final  String sourceId;
/// Owning provider (`local`, `fake`, `ytdlp`).
@override final  String providerId;
/// Genre ids.
 final  List<String> _genres;
/// Genre ids.
@override@JsonKey() List<String> get genres {
  if (_genres is EqualUnmodifiableListView) return _genres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genres);
}

/// Artwork URL, if the provider supplied one.
@override final  String? imageUrl;

/// Create a copy of Artist
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ArtistCopyWith<_Artist> get copyWith => __$ArtistCopyWithImpl<_Artist>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ArtistToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Artist&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.providerId, providerId) || other.providerId == providerId)&&const DeepCollectionEquality().equals(other._genres, _genres)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,sourceId,providerId,const DeepCollectionEquality().hash(_genres),imageUrl);

@override
String toString() {
  return 'Artist(id: $id, name: $name, sourceId: $sourceId, providerId: $providerId, genres: $genres, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class _$ArtistCopyWith<$Res> implements $ArtistCopyWith<$Res> {
  factory _$ArtistCopyWith(_Artist value, $Res Function(_Artist) _then) = __$ArtistCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String sourceId, String providerId, List<String> genres, String? imageUrl
});




}
/// @nodoc
class __$ArtistCopyWithImpl<$Res>
    implements _$ArtistCopyWith<$Res> {
  __$ArtistCopyWithImpl(this._self, this._then);

  final _Artist _self;
  final $Res Function(_Artist) _then;

/// Create a copy of Artist
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? sourceId = null,Object? providerId = null,Object? genres = null,Object? imageUrl = freezed,}) {
  return _then(_Artist(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sourceId: null == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String,providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,genres: null == genres ? _self._genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

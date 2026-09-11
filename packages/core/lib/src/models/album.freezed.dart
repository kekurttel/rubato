// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'album.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Album {

/// Composite `${providerId}:${sourceId}` id.
 String get id;/// Display title.
 String get title;/// Owning provider (`local`, `fake`, `ytdlp`).
 String get providerId;/// Provider-scoped id.
 String get sourceId;/// Artist ids in credit order.
 List<String> get artistIds;/// Release year, if known.
 int? get year;/// Cover artwork id, if cached.
 String? get artworkId;/// Known track count (0 when unknown).
 int get trackCount;
/// Create a copy of Album
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AlbumCopyWith<Album> get copyWith => _$AlbumCopyWithImpl<Album>(this as Album, _$identity);

  /// Serializes this Album to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Album&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&const DeepCollectionEquality().equals(other.artistIds, artistIds)&&(identical(other.year, year) || other.year == year)&&(identical(other.artworkId, artworkId) || other.artworkId == artworkId)&&(identical(other.trackCount, trackCount) || other.trackCount == trackCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,providerId,sourceId,const DeepCollectionEquality().hash(artistIds),year,artworkId,trackCount);

@override
String toString() {
  return 'Album(id: $id, title: $title, providerId: $providerId, sourceId: $sourceId, artistIds: $artistIds, year: $year, artworkId: $artworkId, trackCount: $trackCount)';
}


}

/// @nodoc
abstract mixin class $AlbumCopyWith<$Res>  {
  factory $AlbumCopyWith(Album value, $Res Function(Album) _then) = _$AlbumCopyWithImpl;
@useResult
$Res call({
 String id, String title, String providerId, String sourceId, List<String> artistIds, int? year, String? artworkId, int trackCount
});




}
/// @nodoc
class _$AlbumCopyWithImpl<$Res>
    implements $AlbumCopyWith<$Res> {
  _$AlbumCopyWithImpl(this._self, this._then);

  final Album _self;
  final $Res Function(Album) _then;

/// Create a copy of Album
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? providerId = null,Object? sourceId = null,Object? artistIds = null,Object? year = freezed,Object? artworkId = freezed,Object? trackCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,sourceId: null == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String,artistIds: null == artistIds ? _self.artistIds : artistIds // ignore: cast_nullable_to_non_nullable
as List<String>,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,artworkId: freezed == artworkId ? _self.artworkId : artworkId // ignore: cast_nullable_to_non_nullable
as String?,trackCount: null == trackCount ? _self.trackCount : trackCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Album].
extension AlbumPatterns on Album {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Album value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Album() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Album value)  $default,){
final _that = this;
switch (_that) {
case _Album():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Album value)?  $default,){
final _that = this;
switch (_that) {
case _Album() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String providerId,  String sourceId,  List<String> artistIds,  int? year,  String? artworkId,  int trackCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Album() when $default != null:
return $default(_that.id,_that.title,_that.providerId,_that.sourceId,_that.artistIds,_that.year,_that.artworkId,_that.trackCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String providerId,  String sourceId,  List<String> artistIds,  int? year,  String? artworkId,  int trackCount)  $default,) {final _that = this;
switch (_that) {
case _Album():
return $default(_that.id,_that.title,_that.providerId,_that.sourceId,_that.artistIds,_that.year,_that.artworkId,_that.trackCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String providerId,  String sourceId,  List<String> artistIds,  int? year,  String? artworkId,  int trackCount)?  $default,) {final _that = this;
switch (_that) {
case _Album() when $default != null:
return $default(_that.id,_that.title,_that.providerId,_that.sourceId,_that.artistIds,_that.year,_that.artworkId,_that.trackCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Album extends Album {
  const _Album({required this.id, required this.title, required this.providerId, required this.sourceId, final  List<String> artistIds = const <String>[], this.year, this.artworkId, this.trackCount = 0}): _artistIds = artistIds,super._();
  factory _Album.fromJson(Map<String, dynamic> json) => _$AlbumFromJson(json);

/// Composite `${providerId}:${sourceId}` id.
@override final  String id;
/// Display title.
@override final  String title;
/// Owning provider (`local`, `fake`, `ytdlp`).
@override final  String providerId;
/// Provider-scoped id.
@override final  String sourceId;
/// Artist ids in credit order.
 final  List<String> _artistIds;
/// Artist ids in credit order.
@override@JsonKey() List<String> get artistIds {
  if (_artistIds is EqualUnmodifiableListView) return _artistIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_artistIds);
}

/// Release year, if known.
@override final  int? year;
/// Cover artwork id, if cached.
@override final  String? artworkId;
/// Known track count (0 when unknown).
@override@JsonKey() final  int trackCount;

/// Create a copy of Album
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AlbumCopyWith<_Album> get copyWith => __$AlbumCopyWithImpl<_Album>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AlbumToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Album&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&const DeepCollectionEquality().equals(other._artistIds, _artistIds)&&(identical(other.year, year) || other.year == year)&&(identical(other.artworkId, artworkId) || other.artworkId == artworkId)&&(identical(other.trackCount, trackCount) || other.trackCount == trackCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,providerId,sourceId,const DeepCollectionEquality().hash(_artistIds),year,artworkId,trackCount);

@override
String toString() {
  return 'Album(id: $id, title: $title, providerId: $providerId, sourceId: $sourceId, artistIds: $artistIds, year: $year, artworkId: $artworkId, trackCount: $trackCount)';
}


}

/// @nodoc
abstract mixin class _$AlbumCopyWith<$Res> implements $AlbumCopyWith<$Res> {
  factory _$AlbumCopyWith(_Album value, $Res Function(_Album) _then) = __$AlbumCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String providerId, String sourceId, List<String> artistIds, int? year, String? artworkId, int trackCount
});




}
/// @nodoc
class __$AlbumCopyWithImpl<$Res>
    implements _$AlbumCopyWith<$Res> {
  __$AlbumCopyWithImpl(this._self, this._then);

  final _Album _self;
  final $Res Function(_Album) _then;

/// Create a copy of Album
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? providerId = null,Object? sourceId = null,Object? artistIds = null,Object? year = freezed,Object? artworkId = freezed,Object? trackCount = null,}) {
  return _then(_Album(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,sourceId: null == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String,artistIds: null == artistIds ? _self._artistIds : artistIds // ignore: cast_nullable_to_non_nullable
as List<String>,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,artworkId: freezed == artworkId ? _self.artworkId : artworkId // ignore: cast_nullable_to_non_nullable
as String?,trackCount: null == trackCount ? _self.trackCount : trackCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on

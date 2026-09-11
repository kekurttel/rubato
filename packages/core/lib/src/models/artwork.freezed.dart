// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'artwork.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Artwork {

/// Artwork id (content-addressed where possible).
 String get id;/// Last fetch/update time (UTC).
 DateTime get updatedAt;/// Remote URL the bytes were fetched from, if any.
 String? get url;/// App-cache path of the persisted bytes, if any.
 String? get localPath;/// Dominant color as ARGB int (for Now Playing scrims).
 int? get dominantColorArgb;/// Pixel width, if known.
 int? get width;/// Pixel height, if known.
 int? get height;
/// Create a copy of Artwork
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ArtworkCopyWith<Artwork> get copyWith => _$ArtworkCopyWithImpl<Artwork>(this as Artwork, _$identity);

  /// Serializes this Artwork to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Artwork&&(identical(other.id, id) || other.id == id)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.url, url) || other.url == url)&&(identical(other.localPath, localPath) || other.localPath == localPath)&&(identical(other.dominantColorArgb, dominantColorArgb) || other.dominantColorArgb == dominantColorArgb)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,updatedAt,url,localPath,dominantColorArgb,width,height);

@override
String toString() {
  return 'Artwork(id: $id, updatedAt: $updatedAt, url: $url, localPath: $localPath, dominantColorArgb: $dominantColorArgb, width: $width, height: $height)';
}


}

/// @nodoc
abstract mixin class $ArtworkCopyWith<$Res>  {
  factory $ArtworkCopyWith(Artwork value, $Res Function(Artwork) _then) = _$ArtworkCopyWithImpl;
@useResult
$Res call({
 String id, DateTime updatedAt, String? url, String? localPath, int? dominantColorArgb, int? width, int? height
});




}
/// @nodoc
class _$ArtworkCopyWithImpl<$Res>
    implements $ArtworkCopyWith<$Res> {
  _$ArtworkCopyWithImpl(this._self, this._then);

  final Artwork _self;
  final $Res Function(Artwork) _then;

/// Create a copy of Artwork
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? updatedAt = null,Object? url = freezed,Object? localPath = freezed,Object? dominantColorArgb = freezed,Object? width = freezed,Object? height = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,localPath: freezed == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String?,dominantColorArgb: freezed == dominantColorArgb ? _self.dominantColorArgb : dominantColorArgb // ignore: cast_nullable_to_non_nullable
as int?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [Artwork].
extension ArtworkPatterns on Artwork {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Artwork value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Artwork() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Artwork value)  $default,){
final _that = this;
switch (_that) {
case _Artwork():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Artwork value)?  $default,){
final _that = this;
switch (_that) {
case _Artwork() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime updatedAt,  String? url,  String? localPath,  int? dominantColorArgb,  int? width,  int? height)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Artwork() when $default != null:
return $default(_that.id,_that.updatedAt,_that.url,_that.localPath,_that.dominantColorArgb,_that.width,_that.height);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime updatedAt,  String? url,  String? localPath,  int? dominantColorArgb,  int? width,  int? height)  $default,) {final _that = this;
switch (_that) {
case _Artwork():
return $default(_that.id,_that.updatedAt,_that.url,_that.localPath,_that.dominantColorArgb,_that.width,_that.height);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime updatedAt,  String? url,  String? localPath,  int? dominantColorArgb,  int? width,  int? height)?  $default,) {final _that = this;
switch (_that) {
case _Artwork() when $default != null:
return $default(_that.id,_that.updatedAt,_that.url,_that.localPath,_that.dominantColorArgb,_that.width,_that.height);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Artwork extends Artwork {
  const _Artwork({required this.id, required this.updatedAt, this.url, this.localPath, this.dominantColorArgb, this.width, this.height}): super._();
  factory _Artwork.fromJson(Map<String, dynamic> json) => _$ArtworkFromJson(json);

/// Artwork id (content-addressed where possible).
@override final  String id;
/// Last fetch/update time (UTC).
@override final  DateTime updatedAt;
/// Remote URL the bytes were fetched from, if any.
@override final  String? url;
/// App-cache path of the persisted bytes, if any.
@override final  String? localPath;
/// Dominant color as ARGB int (for Now Playing scrims).
@override final  int? dominantColorArgb;
/// Pixel width, if known.
@override final  int? width;
/// Pixel height, if known.
@override final  int? height;

/// Create a copy of Artwork
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ArtworkCopyWith<_Artwork> get copyWith => __$ArtworkCopyWithImpl<_Artwork>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ArtworkToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Artwork&&(identical(other.id, id) || other.id == id)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.url, url) || other.url == url)&&(identical(other.localPath, localPath) || other.localPath == localPath)&&(identical(other.dominantColorArgb, dominantColorArgb) || other.dominantColorArgb == dominantColorArgb)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,updatedAt,url,localPath,dominantColorArgb,width,height);

@override
String toString() {
  return 'Artwork(id: $id, updatedAt: $updatedAt, url: $url, localPath: $localPath, dominantColorArgb: $dominantColorArgb, width: $width, height: $height)';
}


}

/// @nodoc
abstract mixin class _$ArtworkCopyWith<$Res> implements $ArtworkCopyWith<$Res> {
  factory _$ArtworkCopyWith(_Artwork value, $Res Function(_Artwork) _then) = __$ArtworkCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime updatedAt, String? url, String? localPath, int? dominantColorArgb, int? width, int? height
});




}
/// @nodoc
class __$ArtworkCopyWithImpl<$Res>
    implements _$ArtworkCopyWith<$Res> {
  __$ArtworkCopyWithImpl(this._self, this._then);

  final _Artwork _self;
  final $Res Function(_Artwork) _then;

/// Create a copy of Artwork
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? updatedAt = null,Object? url = freezed,Object? localPath = freezed,Object? dominantColorArgb = freezed,Object? width = freezed,Object? height = freezed,}) {
  return _then(_Artwork(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,localPath: freezed == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String?,dominantColorArgb: freezed == dominantColorArgb ? _self.dominantColorArgb : dominantColorArgb // ignore: cast_nullable_to_non_nullable
as int?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on

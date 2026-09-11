// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'media_handle.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MediaHandle {

/// How [uri] must be interpreted by the player.
 MediaHandleKind get kind;/// File path (localFile) or provider-authorized HTTPS URL
/// (authorizedStream).
 String get uri;/// Stream URL expiry (null for local files).
 DateTime? get expiresAt;/// MIME type hint, when the provider reported one.
 String? get mimeType;/// Quality label this handle was resolved for.
 String? get qualityLabel;/// Provider auth headers, only when the provider requires them.
 Map<String, String> get headers;
/// Create a copy of MediaHandle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaHandleCopyWith<MediaHandle> get copyWith => _$MediaHandleCopyWithImpl<MediaHandle>(this as MediaHandle, _$identity);

  /// Serializes this MediaHandle to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaHandle&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.qualityLabel, qualityLabel) || other.qualityLabel == qualityLabel)&&const DeepCollectionEquality().equals(other.headers, headers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,uri,expiresAt,mimeType,qualityLabel,const DeepCollectionEquality().hash(headers));

@override
String toString() {
  return 'MediaHandle(kind: $kind, uri: $uri, expiresAt: $expiresAt, mimeType: $mimeType, qualityLabel: $qualityLabel, headers: $headers)';
}


}

/// @nodoc
abstract mixin class $MediaHandleCopyWith<$Res>  {
  factory $MediaHandleCopyWith(MediaHandle value, $Res Function(MediaHandle) _then) = _$MediaHandleCopyWithImpl;
@useResult
$Res call({
 MediaHandleKind kind, String uri, DateTime? expiresAt, String? mimeType, String? qualityLabel, Map<String, String> headers
});




}
/// @nodoc
class _$MediaHandleCopyWithImpl<$Res>
    implements $MediaHandleCopyWith<$Res> {
  _$MediaHandleCopyWithImpl(this._self, this._then);

  final MediaHandle _self;
  final $Res Function(MediaHandle) _then;

/// Create a copy of MediaHandle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? uri = null,Object? expiresAt = freezed,Object? mimeType = freezed,Object? qualityLabel = freezed,Object? headers = null,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as MediaHandleKind,uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,qualityLabel: freezed == qualityLabel ? _self.qualityLabel : qualityLabel // ignore: cast_nullable_to_non_nullable
as String?,headers: null == headers ? _self.headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [MediaHandle].
extension MediaHandlePatterns on MediaHandle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MediaHandle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MediaHandle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MediaHandle value)  $default,){
final _that = this;
switch (_that) {
case _MediaHandle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MediaHandle value)?  $default,){
final _that = this;
switch (_that) {
case _MediaHandle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MediaHandleKind kind,  String uri,  DateTime? expiresAt,  String? mimeType,  String? qualityLabel,  Map<String, String> headers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MediaHandle() when $default != null:
return $default(_that.kind,_that.uri,_that.expiresAt,_that.mimeType,_that.qualityLabel,_that.headers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MediaHandleKind kind,  String uri,  DateTime? expiresAt,  String? mimeType,  String? qualityLabel,  Map<String, String> headers)  $default,) {final _that = this;
switch (_that) {
case _MediaHandle():
return $default(_that.kind,_that.uri,_that.expiresAt,_that.mimeType,_that.qualityLabel,_that.headers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MediaHandleKind kind,  String uri,  DateTime? expiresAt,  String? mimeType,  String? qualityLabel,  Map<String, String> headers)?  $default,) {final _that = this;
switch (_that) {
case _MediaHandle() when $default != null:
return $default(_that.kind,_that.uri,_that.expiresAt,_that.mimeType,_that.qualityLabel,_that.headers);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MediaHandle extends MediaHandle {
  const _MediaHandle({required this.kind, required this.uri, this.expiresAt, this.mimeType, this.qualityLabel, final  Map<String, String> headers = const <String, String>{}}): _headers = headers,super._();
  factory _MediaHandle.fromJson(Map<String, dynamic> json) => _$MediaHandleFromJson(json);

/// How [uri] must be interpreted by the player.
@override final  MediaHandleKind kind;
/// File path (localFile) or provider-authorized HTTPS URL
/// (authorizedStream).
@override final  String uri;
/// Stream URL expiry (null for local files).
@override final  DateTime? expiresAt;
/// MIME type hint, when the provider reported one.
@override final  String? mimeType;
/// Quality label this handle was resolved for.
@override final  String? qualityLabel;
/// Provider auth headers, only when the provider requires them.
 final  Map<String, String> _headers;
/// Provider auth headers, only when the provider requires them.
@override@JsonKey() Map<String, String> get headers {
  if (_headers is EqualUnmodifiableMapView) return _headers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_headers);
}


/// Create a copy of MediaHandle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaHandleCopyWith<_MediaHandle> get copyWith => __$MediaHandleCopyWithImpl<_MediaHandle>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MediaHandleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaHandle&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.qualityLabel, qualityLabel) || other.qualityLabel == qualityLabel)&&const DeepCollectionEquality().equals(other._headers, _headers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,uri,expiresAt,mimeType,qualityLabel,const DeepCollectionEquality().hash(_headers));

@override
String toString() {
  return 'MediaHandle(kind: $kind, uri: $uri, expiresAt: $expiresAt, mimeType: $mimeType, qualityLabel: $qualityLabel, headers: $headers)';
}


}

/// @nodoc
abstract mixin class _$MediaHandleCopyWith<$Res> implements $MediaHandleCopyWith<$Res> {
  factory _$MediaHandleCopyWith(_MediaHandle value, $Res Function(_MediaHandle) _then) = __$MediaHandleCopyWithImpl;
@override @useResult
$Res call({
 MediaHandleKind kind, String uri, DateTime? expiresAt, String? mimeType, String? qualityLabel, Map<String, String> headers
});




}
/// @nodoc
class __$MediaHandleCopyWithImpl<$Res>
    implements _$MediaHandleCopyWith<$Res> {
  __$MediaHandleCopyWithImpl(this._self, this._then);

  final _MediaHandle _self;
  final $Res Function(_MediaHandle) _then;

/// Create a copy of MediaHandle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? uri = null,Object? expiresAt = freezed,Object? mimeType = freezed,Object? qualityLabel = freezed,Object? headers = null,}) {
  return _then(_MediaHandle(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as MediaHandleKind,uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,qualityLabel: freezed == qualityLabel ? _self.qualityLabel : qualityLabel // ignore: cast_nullable_to_non_nullable
as String?,headers: null == headers ? _self._headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

// dart format on

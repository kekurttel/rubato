// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'errors.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppError {

/// Machine-readable category.
 AppErrorCode get code;/// Human-readable, log-safe message (no PII, no raw file paths).
 String get message;/// Optional extra context (provider id, operation name, ...).
 String? get details;/// Original exception. Never serialized, never sent anywhere.
@JsonKey(includeFromJson: false, includeToJson: false) Object? get cause;
/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppErrorCopyWith<AppError> get copyWith => _$AppErrorCopyWithImpl<AppError>(this as AppError, _$identity);

  /// Serializes this AppError to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppError&&(identical(other.code, code) || other.code == code)&&(identical(other.message, message) || other.message == message)&&(identical(other.details, details) || other.details == details)&&const DeepCollectionEquality().equals(other.cause, cause));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,message,details,const DeepCollectionEquality().hash(cause));

@override
String toString() {
  return 'AppError(code: $code, message: $message, details: $details, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $AppErrorCopyWith<$Res>  {
  factory $AppErrorCopyWith(AppError value, $Res Function(AppError) _then) = _$AppErrorCopyWithImpl;
@useResult
$Res call({
 AppErrorCode code, String message, String? details,@JsonKey(includeFromJson: false, includeToJson: false) Object? cause
});




}
/// @nodoc
class _$AppErrorCopyWithImpl<$Res>
    implements $AppErrorCopyWith<$Res> {
  _$AppErrorCopyWithImpl(this._self, this._then);

  final AppError _self;
  final $Res Function(AppError) _then;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? message = null,Object? details = freezed,Object? cause = freezed,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as AppErrorCode,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,details: freezed == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String?,cause: freezed == cause ? _self.cause : cause ,
  ));
}

}


/// Adds pattern-matching-related methods to [AppError].
extension AppErrorPatterns on AppError {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppError value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppError() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppError value)  $default,){
final _that = this;
switch (_that) {
case _AppError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppError value)?  $default,){
final _that = this;
switch (_that) {
case _AppError() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AppErrorCode code,  String message,  String? details, @JsonKey(includeFromJson: false, includeToJson: false)  Object? cause)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppError() when $default != null:
return $default(_that.code,_that.message,_that.details,_that.cause);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AppErrorCode code,  String message,  String? details, @JsonKey(includeFromJson: false, includeToJson: false)  Object? cause)  $default,) {final _that = this;
switch (_that) {
case _AppError():
return $default(_that.code,_that.message,_that.details,_that.cause);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AppErrorCode code,  String message,  String? details, @JsonKey(includeFromJson: false, includeToJson: false)  Object? cause)?  $default,) {final _that = this;
switch (_that) {
case _AppError() when $default != null:
return $default(_that.code,_that.message,_that.details,_that.cause);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppError extends AppError {
  const _AppError({required this.code, required this.message, this.details, @JsonKey(includeFromJson: false, includeToJson: false) this.cause}): super._();
  factory _AppError.fromJson(Map<String, dynamic> json) => _$AppErrorFromJson(json);

/// Machine-readable category.
@override final  AppErrorCode code;
/// Human-readable, log-safe message (no PII, no raw file paths).
@override final  String message;
/// Optional extra context (provider id, operation name, ...).
@override final  String? details;
/// Original exception. Never serialized, never sent anywhere.
@override@JsonKey(includeFromJson: false, includeToJson: false) final  Object? cause;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppErrorCopyWith<_AppError> get copyWith => __$AppErrorCopyWithImpl<_AppError>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppErrorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppError&&(identical(other.code, code) || other.code == code)&&(identical(other.message, message) || other.message == message)&&(identical(other.details, details) || other.details == details)&&const DeepCollectionEquality().equals(other.cause, cause));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,message,details,const DeepCollectionEquality().hash(cause));

@override
String toString() {
  return 'AppError(code: $code, message: $message, details: $details, cause: $cause)';
}


}

/// @nodoc
abstract mixin class _$AppErrorCopyWith<$Res> implements $AppErrorCopyWith<$Res> {
  factory _$AppErrorCopyWith(_AppError value, $Res Function(_AppError) _then) = __$AppErrorCopyWithImpl;
@override @useResult
$Res call({
 AppErrorCode code, String message, String? details,@JsonKey(includeFromJson: false, includeToJson: false) Object? cause
});




}
/// @nodoc
class __$AppErrorCopyWithImpl<$Res>
    implements _$AppErrorCopyWith<$Res> {
  __$AppErrorCopyWithImpl(this._self, this._then);

  final _AppError _self;
  final $Res Function(_AppError) _then;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? message = null,Object? details = freezed,Object? cause = freezed,}) {
  return _then(_AppError(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as AppErrorCode,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,details: freezed == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String?,cause: freezed == cause ? _self.cause : cause ,
  ));
}


}

// dart format on

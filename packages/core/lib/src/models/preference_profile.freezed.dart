// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'preference_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PreferenceProfile {

/// Last update time (UTC).
 DateTime get updatedAt;/// Schema version (starts at 1).
 int get version;/// Decayed artist affinity (artist id -> weight).
 Map<String, double> get artistWeights;/// Decayed genre affinity (genre id -> weight).
 Map<String, double> get genreWeights;/// Decayed per-time-bucket artist affinity
/// (bucket name -> artist id -> weight).
 Map<String, Map<String, double>> get timeContext;/// Short-window (7d) genre/artist intent (key -> heard ms).
 Map<String, double> get recentIntent;/// Exploration share of mixes (default 0.10).
 double get explorationRate;/// Adjacent share of mixes (default 0.20).
 double get adjacentRate;/// Exploitation share of mixes (default 0.70).
 double get exploitationRate;/// Half-life in days for long-term decay (default 45).
 double get decayHalfLifeDays;/// MMR penalty for consecutive same-artist picks (default 0.05).
 double get consecutiveArtistPenalty;
/// Create a copy of PreferenceProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PreferenceProfileCopyWith<PreferenceProfile> get copyWith => _$PreferenceProfileCopyWithImpl<PreferenceProfile>(this as PreferenceProfile, _$identity);

  /// Serializes this PreferenceProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PreferenceProfile&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.version, version) || other.version == version)&&const DeepCollectionEquality().equals(other.artistWeights, artistWeights)&&const DeepCollectionEquality().equals(other.genreWeights, genreWeights)&&const DeepCollectionEquality().equals(other.timeContext, timeContext)&&const DeepCollectionEquality().equals(other.recentIntent, recentIntent)&&(identical(other.explorationRate, explorationRate) || other.explorationRate == explorationRate)&&(identical(other.adjacentRate, adjacentRate) || other.adjacentRate == adjacentRate)&&(identical(other.exploitationRate, exploitationRate) || other.exploitationRate == exploitationRate)&&(identical(other.decayHalfLifeDays, decayHalfLifeDays) || other.decayHalfLifeDays == decayHalfLifeDays)&&(identical(other.consecutiveArtistPenalty, consecutiveArtistPenalty) || other.consecutiveArtistPenalty == consecutiveArtistPenalty));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,updatedAt,version,const DeepCollectionEquality().hash(artistWeights),const DeepCollectionEquality().hash(genreWeights),const DeepCollectionEquality().hash(timeContext),const DeepCollectionEquality().hash(recentIntent),explorationRate,adjacentRate,exploitationRate,decayHalfLifeDays,consecutiveArtistPenalty);

@override
String toString() {
  return 'PreferenceProfile(updatedAt: $updatedAt, version: $version, artistWeights: $artistWeights, genreWeights: $genreWeights, timeContext: $timeContext, recentIntent: $recentIntent, explorationRate: $explorationRate, adjacentRate: $adjacentRate, exploitationRate: $exploitationRate, decayHalfLifeDays: $decayHalfLifeDays, consecutiveArtistPenalty: $consecutiveArtistPenalty)';
}


}

/// @nodoc
abstract mixin class $PreferenceProfileCopyWith<$Res>  {
  factory $PreferenceProfileCopyWith(PreferenceProfile value, $Res Function(PreferenceProfile) _then) = _$PreferenceProfileCopyWithImpl;
@useResult
$Res call({
 DateTime updatedAt, int version, Map<String, double> artistWeights, Map<String, double> genreWeights, Map<String, Map<String, double>> timeContext, Map<String, double> recentIntent, double explorationRate, double adjacentRate, double exploitationRate, double decayHalfLifeDays, double consecutiveArtistPenalty
});




}
/// @nodoc
class _$PreferenceProfileCopyWithImpl<$Res>
    implements $PreferenceProfileCopyWith<$Res> {
  _$PreferenceProfileCopyWithImpl(this._self, this._then);

  final PreferenceProfile _self;
  final $Res Function(PreferenceProfile) _then;

/// Create a copy of PreferenceProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? updatedAt = null,Object? version = null,Object? artistWeights = null,Object? genreWeights = null,Object? timeContext = null,Object? recentIntent = null,Object? explorationRate = null,Object? adjacentRate = null,Object? exploitationRate = null,Object? decayHalfLifeDays = null,Object? consecutiveArtistPenalty = null,}) {
  return _then(_self.copyWith(
updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,artistWeights: null == artistWeights ? _self.artistWeights : artistWeights // ignore: cast_nullable_to_non_nullable
as Map<String, double>,genreWeights: null == genreWeights ? _self.genreWeights : genreWeights // ignore: cast_nullable_to_non_nullable
as Map<String, double>,timeContext: null == timeContext ? _self.timeContext : timeContext // ignore: cast_nullable_to_non_nullable
as Map<String, Map<String, double>>,recentIntent: null == recentIntent ? _self.recentIntent : recentIntent // ignore: cast_nullable_to_non_nullable
as Map<String, double>,explorationRate: null == explorationRate ? _self.explorationRate : explorationRate // ignore: cast_nullable_to_non_nullable
as double,adjacentRate: null == adjacentRate ? _self.adjacentRate : adjacentRate // ignore: cast_nullable_to_non_nullable
as double,exploitationRate: null == exploitationRate ? _self.exploitationRate : exploitationRate // ignore: cast_nullable_to_non_nullable
as double,decayHalfLifeDays: null == decayHalfLifeDays ? _self.decayHalfLifeDays : decayHalfLifeDays // ignore: cast_nullable_to_non_nullable
as double,consecutiveArtistPenalty: null == consecutiveArtistPenalty ? _self.consecutiveArtistPenalty : consecutiveArtistPenalty // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [PreferenceProfile].
extension PreferenceProfilePatterns on PreferenceProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PreferenceProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PreferenceProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PreferenceProfile value)  $default,){
final _that = this;
switch (_that) {
case _PreferenceProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PreferenceProfile value)?  $default,){
final _that = this;
switch (_that) {
case _PreferenceProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime updatedAt,  int version,  Map<String, double> artistWeights,  Map<String, double> genreWeights,  Map<String, Map<String, double>> timeContext,  Map<String, double> recentIntent,  double explorationRate,  double adjacentRate,  double exploitationRate,  double decayHalfLifeDays,  double consecutiveArtistPenalty)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PreferenceProfile() when $default != null:
return $default(_that.updatedAt,_that.version,_that.artistWeights,_that.genreWeights,_that.timeContext,_that.recentIntent,_that.explorationRate,_that.adjacentRate,_that.exploitationRate,_that.decayHalfLifeDays,_that.consecutiveArtistPenalty);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime updatedAt,  int version,  Map<String, double> artistWeights,  Map<String, double> genreWeights,  Map<String, Map<String, double>> timeContext,  Map<String, double> recentIntent,  double explorationRate,  double adjacentRate,  double exploitationRate,  double decayHalfLifeDays,  double consecutiveArtistPenalty)  $default,) {final _that = this;
switch (_that) {
case _PreferenceProfile():
return $default(_that.updatedAt,_that.version,_that.artistWeights,_that.genreWeights,_that.timeContext,_that.recentIntent,_that.explorationRate,_that.adjacentRate,_that.exploitationRate,_that.decayHalfLifeDays,_that.consecutiveArtistPenalty);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime updatedAt,  int version,  Map<String, double> artistWeights,  Map<String, double> genreWeights,  Map<String, Map<String, double>> timeContext,  Map<String, double> recentIntent,  double explorationRate,  double adjacentRate,  double exploitationRate,  double decayHalfLifeDays,  double consecutiveArtistPenalty)?  $default,) {final _that = this;
switch (_that) {
case _PreferenceProfile() when $default != null:
return $default(_that.updatedAt,_that.version,_that.artistWeights,_that.genreWeights,_that.timeContext,_that.recentIntent,_that.explorationRate,_that.adjacentRate,_that.exploitationRate,_that.decayHalfLifeDays,_that.consecutiveArtistPenalty);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PreferenceProfile extends PreferenceProfile {
  const _PreferenceProfile({required this.updatedAt, this.version = 1, final  Map<String, double> artistWeights = const <String, double>{}, final  Map<String, double> genreWeights = const <String, double>{}, final  Map<String, Map<String, double>> timeContext = const <String, Map<String, double>>{}, final  Map<String, double> recentIntent = const <String, double>{}, this.explorationRate = 0.10, this.adjacentRate = 0.20, this.exploitationRate = 0.70, this.decayHalfLifeDays = 45, this.consecutiveArtistPenalty = 0.05}): _artistWeights = artistWeights,_genreWeights = genreWeights,_timeContext = timeContext,_recentIntent = recentIntent,super._();
  factory _PreferenceProfile.fromJson(Map<String, dynamic> json) => _$PreferenceProfileFromJson(json);

/// Last update time (UTC).
@override final  DateTime updatedAt;
/// Schema version (starts at 1).
@override@JsonKey() final  int version;
/// Decayed artist affinity (artist id -> weight).
 final  Map<String, double> _artistWeights;
/// Decayed artist affinity (artist id -> weight).
@override@JsonKey() Map<String, double> get artistWeights {
  if (_artistWeights is EqualUnmodifiableMapView) return _artistWeights;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_artistWeights);
}

/// Decayed genre affinity (genre id -> weight).
 final  Map<String, double> _genreWeights;
/// Decayed genre affinity (genre id -> weight).
@override@JsonKey() Map<String, double> get genreWeights {
  if (_genreWeights is EqualUnmodifiableMapView) return _genreWeights;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_genreWeights);
}

/// Decayed per-time-bucket artist affinity
/// (bucket name -> artist id -> weight).
 final  Map<String, Map<String, double>> _timeContext;
/// Decayed per-time-bucket artist affinity
/// (bucket name -> artist id -> weight).
@override@JsonKey() Map<String, Map<String, double>> get timeContext {
  if (_timeContext is EqualUnmodifiableMapView) return _timeContext;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_timeContext);
}

/// Short-window (7d) genre/artist intent (key -> heard ms).
 final  Map<String, double> _recentIntent;
/// Short-window (7d) genre/artist intent (key -> heard ms).
@override@JsonKey() Map<String, double> get recentIntent {
  if (_recentIntent is EqualUnmodifiableMapView) return _recentIntent;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_recentIntent);
}

/// Exploration share of mixes (default 0.10).
@override@JsonKey() final  double explorationRate;
/// Adjacent share of mixes (default 0.20).
@override@JsonKey() final  double adjacentRate;
/// Exploitation share of mixes (default 0.70).
@override@JsonKey() final  double exploitationRate;
/// Half-life in days for long-term decay (default 45).
@override@JsonKey() final  double decayHalfLifeDays;
/// MMR penalty for consecutive same-artist picks (default 0.05).
@override@JsonKey() final  double consecutiveArtistPenalty;

/// Create a copy of PreferenceProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PreferenceProfileCopyWith<_PreferenceProfile> get copyWith => __$PreferenceProfileCopyWithImpl<_PreferenceProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PreferenceProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PreferenceProfile&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.version, version) || other.version == version)&&const DeepCollectionEquality().equals(other._artistWeights, _artistWeights)&&const DeepCollectionEquality().equals(other._genreWeights, _genreWeights)&&const DeepCollectionEquality().equals(other._timeContext, _timeContext)&&const DeepCollectionEquality().equals(other._recentIntent, _recentIntent)&&(identical(other.explorationRate, explorationRate) || other.explorationRate == explorationRate)&&(identical(other.adjacentRate, adjacentRate) || other.adjacentRate == adjacentRate)&&(identical(other.exploitationRate, exploitationRate) || other.exploitationRate == exploitationRate)&&(identical(other.decayHalfLifeDays, decayHalfLifeDays) || other.decayHalfLifeDays == decayHalfLifeDays)&&(identical(other.consecutiveArtistPenalty, consecutiveArtistPenalty) || other.consecutiveArtistPenalty == consecutiveArtistPenalty));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,updatedAt,version,const DeepCollectionEquality().hash(_artistWeights),const DeepCollectionEquality().hash(_genreWeights),const DeepCollectionEquality().hash(_timeContext),const DeepCollectionEquality().hash(_recentIntent),explorationRate,adjacentRate,exploitationRate,decayHalfLifeDays,consecutiveArtistPenalty);

@override
String toString() {
  return 'PreferenceProfile(updatedAt: $updatedAt, version: $version, artistWeights: $artistWeights, genreWeights: $genreWeights, timeContext: $timeContext, recentIntent: $recentIntent, explorationRate: $explorationRate, adjacentRate: $adjacentRate, exploitationRate: $exploitationRate, decayHalfLifeDays: $decayHalfLifeDays, consecutiveArtistPenalty: $consecutiveArtistPenalty)';
}


}

/// @nodoc
abstract mixin class _$PreferenceProfileCopyWith<$Res> implements $PreferenceProfileCopyWith<$Res> {
  factory _$PreferenceProfileCopyWith(_PreferenceProfile value, $Res Function(_PreferenceProfile) _then) = __$PreferenceProfileCopyWithImpl;
@override @useResult
$Res call({
 DateTime updatedAt, int version, Map<String, double> artistWeights, Map<String, double> genreWeights, Map<String, Map<String, double>> timeContext, Map<String, double> recentIntent, double explorationRate, double adjacentRate, double exploitationRate, double decayHalfLifeDays, double consecutiveArtistPenalty
});




}
/// @nodoc
class __$PreferenceProfileCopyWithImpl<$Res>
    implements _$PreferenceProfileCopyWith<$Res> {
  __$PreferenceProfileCopyWithImpl(this._self, this._then);

  final _PreferenceProfile _self;
  final $Res Function(_PreferenceProfile) _then;

/// Create a copy of PreferenceProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? updatedAt = null,Object? version = null,Object? artistWeights = null,Object? genreWeights = null,Object? timeContext = null,Object? recentIntent = null,Object? explorationRate = null,Object? adjacentRate = null,Object? exploitationRate = null,Object? decayHalfLifeDays = null,Object? consecutiveArtistPenalty = null,}) {
  return _then(_PreferenceProfile(
updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,artistWeights: null == artistWeights ? _self._artistWeights : artistWeights // ignore: cast_nullable_to_non_nullable
as Map<String, double>,genreWeights: null == genreWeights ? _self._genreWeights : genreWeights // ignore: cast_nullable_to_non_nullable
as Map<String, double>,timeContext: null == timeContext ? _self._timeContext : timeContext // ignore: cast_nullable_to_non_nullable
as Map<String, Map<String, double>>,recentIntent: null == recentIntent ? _self._recentIntent : recentIntent // ignore: cast_nullable_to_non_nullable
as Map<String, double>,explorationRate: null == explorationRate ? _self.explorationRate : explorationRate // ignore: cast_nullable_to_non_nullable
as double,adjacentRate: null == adjacentRate ? _self.adjacentRate : adjacentRate // ignore: cast_nullable_to_non_nullable
as double,exploitationRate: null == exploitationRate ? _self.exploitationRate : exploitationRate // ignore: cast_nullable_to_non_nullable
as double,decayHalfLifeDays: null == decayHalfLifeDays ? _self.decayHalfLifeDays : decayHalfLifeDays // ignore: cast_nullable_to_non_nullable
as double,consecutiveArtistPenalty: null == consecutiveArtistPenalty ? _self.consecutiveArtistPenalty : consecutiveArtistPenalty // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on

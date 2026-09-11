// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'track.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Track {

/// Composite `${providerId}:${sourceTrackId}` id.
 String get id;/// Owning provider (`local`, `fake`, `ytdlp`).
 String get providerId;/// Provider-scoped id (MYT `(_ID_)` suffix, video id, ...).
 String get sourceTrackId;/// Clean display title (never the raw `(_ID_)` filename).
 String get title;/// Row creation time (UTC).
 DateTime get createdAt;/// Row update time (UTC).
 DateTime get updatedAt;/// Duration in milliseconds (0 when unknown).
 int get durationMs;/// Explicit-content flag.
 bool get explicit;/// Artist ids in credit order.
 List<String> get artistIds;/// Parent album id, if known.
 String? get albumId;/// Genre ids.
 List<String> get genreIds;/// Release year, if known.
 int? get year;/// Content hash (first+last 64KB + length) for dedupe.
 String? get audioHash;/// On-disk path when a usable local file exists.
 String? get localPath;/// Whether a verified download is persisted.
 bool get isDownloaded;/// Stream URL expiry for [providerId] != local tracks.
 DateTime? get streamExpiresAt;
/// Create a copy of Track
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrackCopyWith<Track> get copyWith => _$TrackCopyWithImpl<Track>(this as Track, _$identity);

  /// Serializes this Track to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Track&&(identical(other.id, id) || other.id == id)&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.sourceTrackId, sourceTrackId) || other.sourceTrackId == sourceTrackId)&&(identical(other.title, title) || other.title == title)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.explicit, explicit) || other.explicit == explicit)&&const DeepCollectionEquality().equals(other.artistIds, artistIds)&&(identical(other.albumId, albumId) || other.albumId == albumId)&&const DeepCollectionEquality().equals(other.genreIds, genreIds)&&(identical(other.year, year) || other.year == year)&&(identical(other.audioHash, audioHash) || other.audioHash == audioHash)&&(identical(other.localPath, localPath) || other.localPath == localPath)&&(identical(other.isDownloaded, isDownloaded) || other.isDownloaded == isDownloaded)&&(identical(other.streamExpiresAt, streamExpiresAt) || other.streamExpiresAt == streamExpiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,providerId,sourceTrackId,title,createdAt,updatedAt,durationMs,explicit,const DeepCollectionEquality().hash(artistIds),albumId,const DeepCollectionEquality().hash(genreIds),year,audioHash,localPath,isDownloaded,streamExpiresAt);

@override
String toString() {
  return 'Track(id: $id, providerId: $providerId, sourceTrackId: $sourceTrackId, title: $title, createdAt: $createdAt, updatedAt: $updatedAt, durationMs: $durationMs, explicit: $explicit, artistIds: $artistIds, albumId: $albumId, genreIds: $genreIds, year: $year, audioHash: $audioHash, localPath: $localPath, isDownloaded: $isDownloaded, streamExpiresAt: $streamExpiresAt)';
}


}

/// @nodoc
abstract mixin class $TrackCopyWith<$Res>  {
  factory $TrackCopyWith(Track value, $Res Function(Track) _then) = _$TrackCopyWithImpl;
@useResult
$Res call({
 String id, String providerId, String sourceTrackId, String title, DateTime createdAt, DateTime updatedAt, int durationMs, bool explicit, List<String> artistIds, String? albumId, List<String> genreIds, int? year, String? audioHash, String? localPath, bool isDownloaded, DateTime? streamExpiresAt
});




}
/// @nodoc
class _$TrackCopyWithImpl<$Res>
    implements $TrackCopyWith<$Res> {
  _$TrackCopyWithImpl(this._self, this._then);

  final Track _self;
  final $Res Function(Track) _then;

/// Create a copy of Track
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? providerId = null,Object? sourceTrackId = null,Object? title = null,Object? createdAt = null,Object? updatedAt = null,Object? durationMs = null,Object? explicit = null,Object? artistIds = null,Object? albumId = freezed,Object? genreIds = null,Object? year = freezed,Object? audioHash = freezed,Object? localPath = freezed,Object? isDownloaded = null,Object? streamExpiresAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,sourceTrackId: null == sourceTrackId ? _self.sourceTrackId : sourceTrackId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,explicit: null == explicit ? _self.explicit : explicit // ignore: cast_nullable_to_non_nullable
as bool,artistIds: null == artistIds ? _self.artistIds : artistIds // ignore: cast_nullable_to_non_nullable
as List<String>,albumId: freezed == albumId ? _self.albumId : albumId // ignore: cast_nullable_to_non_nullable
as String?,genreIds: null == genreIds ? _self.genreIds : genreIds // ignore: cast_nullable_to_non_nullable
as List<String>,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,audioHash: freezed == audioHash ? _self.audioHash : audioHash // ignore: cast_nullable_to_non_nullable
as String?,localPath: freezed == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String?,isDownloaded: null == isDownloaded ? _self.isDownloaded : isDownloaded // ignore: cast_nullable_to_non_nullable
as bool,streamExpiresAt: freezed == streamExpiresAt ? _self.streamExpiresAt : streamExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Track].
extension TrackPatterns on Track {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Track value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Track() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Track value)  $default,){
final _that = this;
switch (_that) {
case _Track():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Track value)?  $default,){
final _that = this;
switch (_that) {
case _Track() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String providerId,  String sourceTrackId,  String title,  DateTime createdAt,  DateTime updatedAt,  int durationMs,  bool explicit,  List<String> artistIds,  String? albumId,  List<String> genreIds,  int? year,  String? audioHash,  String? localPath,  bool isDownloaded,  DateTime? streamExpiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Track() when $default != null:
return $default(_that.id,_that.providerId,_that.sourceTrackId,_that.title,_that.createdAt,_that.updatedAt,_that.durationMs,_that.explicit,_that.artistIds,_that.albumId,_that.genreIds,_that.year,_that.audioHash,_that.localPath,_that.isDownloaded,_that.streamExpiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String providerId,  String sourceTrackId,  String title,  DateTime createdAt,  DateTime updatedAt,  int durationMs,  bool explicit,  List<String> artistIds,  String? albumId,  List<String> genreIds,  int? year,  String? audioHash,  String? localPath,  bool isDownloaded,  DateTime? streamExpiresAt)  $default,) {final _that = this;
switch (_that) {
case _Track():
return $default(_that.id,_that.providerId,_that.sourceTrackId,_that.title,_that.createdAt,_that.updatedAt,_that.durationMs,_that.explicit,_that.artistIds,_that.albumId,_that.genreIds,_that.year,_that.audioHash,_that.localPath,_that.isDownloaded,_that.streamExpiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String providerId,  String sourceTrackId,  String title,  DateTime createdAt,  DateTime updatedAt,  int durationMs,  bool explicit,  List<String> artistIds,  String? albumId,  List<String> genreIds,  int? year,  String? audioHash,  String? localPath,  bool isDownloaded,  DateTime? streamExpiresAt)?  $default,) {final _that = this;
switch (_that) {
case _Track() when $default != null:
return $default(_that.id,_that.providerId,_that.sourceTrackId,_that.title,_that.createdAt,_that.updatedAt,_that.durationMs,_that.explicit,_that.artistIds,_that.albumId,_that.genreIds,_that.year,_that.audioHash,_that.localPath,_that.isDownloaded,_that.streamExpiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Track extends Track {
  const _Track({required this.id, required this.providerId, required this.sourceTrackId, required this.title, required this.createdAt, required this.updatedAt, this.durationMs = 0, this.explicit = false, final  List<String> artistIds = const <String>[], this.albumId, final  List<String> genreIds = const <String>[], this.year, this.audioHash, this.localPath, this.isDownloaded = false, this.streamExpiresAt}): _artistIds = artistIds,_genreIds = genreIds,super._();
  factory _Track.fromJson(Map<String, dynamic> json) => _$TrackFromJson(json);

/// Composite `${providerId}:${sourceTrackId}` id.
@override final  String id;
/// Owning provider (`local`, `fake`, `ytdlp`).
@override final  String providerId;
/// Provider-scoped id (MYT `(_ID_)` suffix, video id, ...).
@override final  String sourceTrackId;
/// Clean display title (never the raw `(_ID_)` filename).
@override final  String title;
/// Row creation time (UTC).
@override final  DateTime createdAt;
/// Row update time (UTC).
@override final  DateTime updatedAt;
/// Duration in milliseconds (0 when unknown).
@override@JsonKey() final  int durationMs;
/// Explicit-content flag.
@override@JsonKey() final  bool explicit;
/// Artist ids in credit order.
 final  List<String> _artistIds;
/// Artist ids in credit order.
@override@JsonKey() List<String> get artistIds {
  if (_artistIds is EqualUnmodifiableListView) return _artistIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_artistIds);
}

/// Parent album id, if known.
@override final  String? albumId;
/// Genre ids.
 final  List<String> _genreIds;
/// Genre ids.
@override@JsonKey() List<String> get genreIds {
  if (_genreIds is EqualUnmodifiableListView) return _genreIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genreIds);
}

/// Release year, if known.
@override final  int? year;
/// Content hash (first+last 64KB + length) for dedupe.
@override final  String? audioHash;
/// On-disk path when a usable local file exists.
@override final  String? localPath;
/// Whether a verified download is persisted.
@override@JsonKey() final  bool isDownloaded;
/// Stream URL expiry for [providerId] != local tracks.
@override final  DateTime? streamExpiresAt;

/// Create a copy of Track
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrackCopyWith<_Track> get copyWith => __$TrackCopyWithImpl<_Track>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrackToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Track&&(identical(other.id, id) || other.id == id)&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.sourceTrackId, sourceTrackId) || other.sourceTrackId == sourceTrackId)&&(identical(other.title, title) || other.title == title)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.explicit, explicit) || other.explicit == explicit)&&const DeepCollectionEquality().equals(other._artistIds, _artistIds)&&(identical(other.albumId, albumId) || other.albumId == albumId)&&const DeepCollectionEquality().equals(other._genreIds, _genreIds)&&(identical(other.year, year) || other.year == year)&&(identical(other.audioHash, audioHash) || other.audioHash == audioHash)&&(identical(other.localPath, localPath) || other.localPath == localPath)&&(identical(other.isDownloaded, isDownloaded) || other.isDownloaded == isDownloaded)&&(identical(other.streamExpiresAt, streamExpiresAt) || other.streamExpiresAt == streamExpiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,providerId,sourceTrackId,title,createdAt,updatedAt,durationMs,explicit,const DeepCollectionEquality().hash(_artistIds),albumId,const DeepCollectionEquality().hash(_genreIds),year,audioHash,localPath,isDownloaded,streamExpiresAt);

@override
String toString() {
  return 'Track(id: $id, providerId: $providerId, sourceTrackId: $sourceTrackId, title: $title, createdAt: $createdAt, updatedAt: $updatedAt, durationMs: $durationMs, explicit: $explicit, artistIds: $artistIds, albumId: $albumId, genreIds: $genreIds, year: $year, audioHash: $audioHash, localPath: $localPath, isDownloaded: $isDownloaded, streamExpiresAt: $streamExpiresAt)';
}


}

/// @nodoc
abstract mixin class _$TrackCopyWith<$Res> implements $TrackCopyWith<$Res> {
  factory _$TrackCopyWith(_Track value, $Res Function(_Track) _then) = __$TrackCopyWithImpl;
@override @useResult
$Res call({
 String id, String providerId, String sourceTrackId, String title, DateTime createdAt, DateTime updatedAt, int durationMs, bool explicit, List<String> artistIds, String? albumId, List<String> genreIds, int? year, String? audioHash, String? localPath, bool isDownloaded, DateTime? streamExpiresAt
});




}
/// @nodoc
class __$TrackCopyWithImpl<$Res>
    implements _$TrackCopyWith<$Res> {
  __$TrackCopyWithImpl(this._self, this._then);

  final _Track _self;
  final $Res Function(_Track) _then;

/// Create a copy of Track
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? providerId = null,Object? sourceTrackId = null,Object? title = null,Object? createdAt = null,Object? updatedAt = null,Object? durationMs = null,Object? explicit = null,Object? artistIds = null,Object? albumId = freezed,Object? genreIds = null,Object? year = freezed,Object? audioHash = freezed,Object? localPath = freezed,Object? isDownloaded = null,Object? streamExpiresAt = freezed,}) {
  return _then(_Track(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,sourceTrackId: null == sourceTrackId ? _self.sourceTrackId : sourceTrackId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,explicit: null == explicit ? _self.explicit : explicit // ignore: cast_nullable_to_non_nullable
as bool,artistIds: null == artistIds ? _self._artistIds : artistIds // ignore: cast_nullable_to_non_nullable
as List<String>,albumId: freezed == albumId ? _self.albumId : albumId // ignore: cast_nullable_to_non_nullable
as String?,genreIds: null == genreIds ? _self._genreIds : genreIds // ignore: cast_nullable_to_non_nullable
as List<String>,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,audioHash: freezed == audioHash ? _self.audioHash : audioHash // ignore: cast_nullable_to_non_nullable
as String?,localPath: freezed == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String?,isDownloaded: null == isDownloaded ? _self.isDownloaded : isDownloaded // ignore: cast_nullable_to_non_nullable
as bool,streamExpiresAt: freezed == streamExpiresAt ? _self.streamExpiresAt : streamExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on

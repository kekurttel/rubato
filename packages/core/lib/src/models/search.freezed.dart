// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SearchQuery {

/// Raw user text (min 2 chars enforced by the UI).
 String get text;/// Entity kinds to include.
 List<SearchType> get types;/// Per-kind page size.
 int get limit;/// Opaque provider cursor for pagination, if any.
 String? get cursor;
/// Create a copy of SearchQuery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchQueryCopyWith<SearchQuery> get copyWith => _$SearchQueryCopyWithImpl<SearchQuery>(this as SearchQuery, _$identity);

  /// Serializes this SearchQuery to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchQuery&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other.types, types)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.cursor, cursor) || other.cursor == cursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,const DeepCollectionEquality().hash(types),limit,cursor);

@override
String toString() {
  return 'SearchQuery(text: $text, types: $types, limit: $limit, cursor: $cursor)';
}


}

/// @nodoc
abstract mixin class $SearchQueryCopyWith<$Res>  {
  factory $SearchQueryCopyWith(SearchQuery value, $Res Function(SearchQuery) _then) = _$SearchQueryCopyWithImpl;
@useResult
$Res call({
 String text, List<SearchType> types, int limit, String? cursor
});




}
/// @nodoc
class _$SearchQueryCopyWithImpl<$Res>
    implements $SearchQueryCopyWith<$Res> {
  _$SearchQueryCopyWithImpl(this._self, this._then);

  final SearchQuery _self;
  final $Res Function(SearchQuery) _then;

/// Create a copy of SearchQuery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? types = null,Object? limit = null,Object? cursor = freezed,}) {
  return _then(_self.copyWith(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,types: null == types ? _self.types : types // ignore: cast_nullable_to_non_nullable
as List<SearchType>,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchQuery].
extension SearchQueryPatterns on SearchQuery {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchQuery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchQuery() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchQuery value)  $default,){
final _that = this;
switch (_that) {
case _SearchQuery():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchQuery value)?  $default,){
final _that = this;
switch (_that) {
case _SearchQuery() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text,  List<SearchType> types,  int limit,  String? cursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchQuery() when $default != null:
return $default(_that.text,_that.types,_that.limit,_that.cursor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text,  List<SearchType> types,  int limit,  String? cursor)  $default,) {final _that = this;
switch (_that) {
case _SearchQuery():
return $default(_that.text,_that.types,_that.limit,_that.cursor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text,  List<SearchType> types,  int limit,  String? cursor)?  $default,) {final _that = this;
switch (_that) {
case _SearchQuery() when $default != null:
return $default(_that.text,_that.types,_that.limit,_that.cursor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SearchQuery extends SearchQuery {
  const _SearchQuery({required this.text, final  List<SearchType> types = SearchType.values, this.limit = 20, this.cursor}): _types = types,super._();
  factory _SearchQuery.fromJson(Map<String, dynamic> json) => _$SearchQueryFromJson(json);

/// Raw user text (min 2 chars enforced by the UI).
@override final  String text;
/// Entity kinds to include.
 final  List<SearchType> _types;
/// Entity kinds to include.
@override@JsonKey() List<SearchType> get types {
  if (_types is EqualUnmodifiableListView) return _types;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_types);
}

/// Per-kind page size.
@override@JsonKey() final  int limit;
/// Opaque provider cursor for pagination, if any.
@override final  String? cursor;

/// Create a copy of SearchQuery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchQueryCopyWith<_SearchQuery> get copyWith => __$SearchQueryCopyWithImpl<_SearchQuery>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SearchQueryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchQuery&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other._types, _types)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.cursor, cursor) || other.cursor == cursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,const DeepCollectionEquality().hash(_types),limit,cursor);

@override
String toString() {
  return 'SearchQuery(text: $text, types: $types, limit: $limit, cursor: $cursor)';
}


}

/// @nodoc
abstract mixin class _$SearchQueryCopyWith<$Res> implements $SearchQueryCopyWith<$Res> {
  factory _$SearchQueryCopyWith(_SearchQuery value, $Res Function(_SearchQuery) _then) = __$SearchQueryCopyWithImpl;
@override @useResult
$Res call({
 String text, List<SearchType> types, int limit, String? cursor
});




}
/// @nodoc
class __$SearchQueryCopyWithImpl<$Res>
    implements _$SearchQueryCopyWith<$Res> {
  __$SearchQueryCopyWithImpl(this._self, this._then);

  final _SearchQuery _self;
  final $Res Function(_SearchQuery) _then;

/// Create a copy of SearchQuery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? types = null,Object? limit = null,Object? cursor = freezed,}) {
  return _then(_SearchQuery(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,types: null == types ? _self._types : types // ignore: cast_nullable_to_non_nullable
as List<SearchType>,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SearchPage {

/// Provider that produced this page (`local`, `fake`, `ytdlp`).
 String get providerId;/// Fetch time (UTC) — drives the 12h search TTL.
 DateTime get fetchedAt;/// Matching tracks (Songs tab).
 List<Track> get tracks;/// Matching artists (Artists tab).
 List<Artist> get artists;/// Matching albums (Albums tab).
 List<Album> get albums;/// Opaque cursor for the next page, if any.
 String? get nextCursor;
/// Create a copy of SearchPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchPageCopyWith<SearchPage> get copyWith => _$SearchPageCopyWithImpl<SearchPage>(this as SearchPage, _$identity);

  /// Serializes this SearchPage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchPage&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.fetchedAt, fetchedAt) || other.fetchedAt == fetchedAt)&&const DeepCollectionEquality().equals(other.tracks, tracks)&&const DeepCollectionEquality().equals(other.artists, artists)&&const DeepCollectionEquality().equals(other.albums, albums)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,providerId,fetchedAt,const DeepCollectionEquality().hash(tracks),const DeepCollectionEquality().hash(artists),const DeepCollectionEquality().hash(albums),nextCursor);

@override
String toString() {
  return 'SearchPage(providerId: $providerId, fetchedAt: $fetchedAt, tracks: $tracks, artists: $artists, albums: $albums, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class $SearchPageCopyWith<$Res>  {
  factory $SearchPageCopyWith(SearchPage value, $Res Function(SearchPage) _then) = _$SearchPageCopyWithImpl;
@useResult
$Res call({
 String providerId, DateTime fetchedAt, List<Track> tracks, List<Artist> artists, List<Album> albums, String? nextCursor
});




}
/// @nodoc
class _$SearchPageCopyWithImpl<$Res>
    implements $SearchPageCopyWith<$Res> {
  _$SearchPageCopyWithImpl(this._self, this._then);

  final SearchPage _self;
  final $Res Function(SearchPage) _then;

/// Create a copy of SearchPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? providerId = null,Object? fetchedAt = null,Object? tracks = null,Object? artists = null,Object? albums = null,Object? nextCursor = freezed,}) {
  return _then(_self.copyWith(
providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,fetchedAt: null == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime,tracks: null == tracks ? _self.tracks : tracks // ignore: cast_nullable_to_non_nullable
as List<Track>,artists: null == artists ? _self.artists : artists // ignore: cast_nullable_to_non_nullable
as List<Artist>,albums: null == albums ? _self.albums : albums // ignore: cast_nullable_to_non_nullable
as List<Album>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchPage].
extension SearchPagePatterns on SearchPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchPage value)  $default,){
final _that = this;
switch (_that) {
case _SearchPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchPage value)?  $default,){
final _that = this;
switch (_that) {
case _SearchPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String providerId,  DateTime fetchedAt,  List<Track> tracks,  List<Artist> artists,  List<Album> albums,  String? nextCursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchPage() when $default != null:
return $default(_that.providerId,_that.fetchedAt,_that.tracks,_that.artists,_that.albums,_that.nextCursor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String providerId,  DateTime fetchedAt,  List<Track> tracks,  List<Artist> artists,  List<Album> albums,  String? nextCursor)  $default,) {final _that = this;
switch (_that) {
case _SearchPage():
return $default(_that.providerId,_that.fetchedAt,_that.tracks,_that.artists,_that.albums,_that.nextCursor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String providerId,  DateTime fetchedAt,  List<Track> tracks,  List<Artist> artists,  List<Album> albums,  String? nextCursor)?  $default,) {final _that = this;
switch (_that) {
case _SearchPage() when $default != null:
return $default(_that.providerId,_that.fetchedAt,_that.tracks,_that.artists,_that.albums,_that.nextCursor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SearchPage extends SearchPage {
  const _SearchPage({required this.providerId, required this.fetchedAt, final  List<Track> tracks = const <Track>[], final  List<Artist> artists = const <Artist>[], final  List<Album> albums = const <Album>[], this.nextCursor}): _tracks = tracks,_artists = artists,_albums = albums,super._();
  factory _SearchPage.fromJson(Map<String, dynamic> json) => _$SearchPageFromJson(json);

/// Provider that produced this page (`local`, `fake`, `ytdlp`).
@override final  String providerId;
/// Fetch time (UTC) — drives the 12h search TTL.
@override final  DateTime fetchedAt;
/// Matching tracks (Songs tab).
 final  List<Track> _tracks;
/// Matching tracks (Songs tab).
@override@JsonKey() List<Track> get tracks {
  if (_tracks is EqualUnmodifiableListView) return _tracks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tracks);
}

/// Matching artists (Artists tab).
 final  List<Artist> _artists;
/// Matching artists (Artists tab).
@override@JsonKey() List<Artist> get artists {
  if (_artists is EqualUnmodifiableListView) return _artists;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_artists);
}

/// Matching albums (Albums tab).
 final  List<Album> _albums;
/// Matching albums (Albums tab).
@override@JsonKey() List<Album> get albums {
  if (_albums is EqualUnmodifiableListView) return _albums;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_albums);
}

/// Opaque cursor for the next page, if any.
@override final  String? nextCursor;

/// Create a copy of SearchPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchPageCopyWith<_SearchPage> get copyWith => __$SearchPageCopyWithImpl<_SearchPage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SearchPageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchPage&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.fetchedAt, fetchedAt) || other.fetchedAt == fetchedAt)&&const DeepCollectionEquality().equals(other._tracks, _tracks)&&const DeepCollectionEquality().equals(other._artists, _artists)&&const DeepCollectionEquality().equals(other._albums, _albums)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,providerId,fetchedAt,const DeepCollectionEquality().hash(_tracks),const DeepCollectionEquality().hash(_artists),const DeepCollectionEquality().hash(_albums),nextCursor);

@override
String toString() {
  return 'SearchPage(providerId: $providerId, fetchedAt: $fetchedAt, tracks: $tracks, artists: $artists, albums: $albums, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class _$SearchPageCopyWith<$Res> implements $SearchPageCopyWith<$Res> {
  factory _$SearchPageCopyWith(_SearchPage value, $Res Function(_SearchPage) _then) = __$SearchPageCopyWithImpl;
@override @useResult
$Res call({
 String providerId, DateTime fetchedAt, List<Track> tracks, List<Artist> artists, List<Album> albums, String? nextCursor
});




}
/// @nodoc
class __$SearchPageCopyWithImpl<$Res>
    implements _$SearchPageCopyWith<$Res> {
  __$SearchPageCopyWithImpl(this._self, this._then);

  final _SearchPage _self;
  final $Res Function(_SearchPage) _then;

/// Create a copy of SearchPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? providerId = null,Object? fetchedAt = null,Object? tracks = null,Object? artists = null,Object? albums = null,Object? nextCursor = freezed,}) {
  return _then(_SearchPage(
providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,fetchedAt: null == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime,tracks: null == tracks ? _self._tracks : tracks // ignore: cast_nullable_to_non_nullable
as List<Track>,artists: null == artists ? _self._artists : artists // ignore: cast_nullable_to_non_nullable
as List<Artist>,albums: null == albums ? _self._albums : albums // ignore: cast_nullable_to_non_nullable
as List<Album>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

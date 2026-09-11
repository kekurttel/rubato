import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_reco/aurora_reco.dart';

/// Shared fixtures for the spec section 10.11 acceptance tests.
///
/// All time comes from a frozen [FakeClock]; helpers build minimal
/// but valid domain models so each test reads as arranged history.
int _eventSeq = 0;

/// Builds a local catalog track with the given credits.
Track mkTrack(
  String id, {
  List<String> artists = const <String>['artist-a'],
  List<String> genres = const <String>['rock'],
  String? albumId,
  bool downloaded = true,
  DateTime? createdAt,
  int? year,
  int durationMs = 200000,
}) {
  final created = createdAt ?? DateTime.utc(2025, 6);
  return Track(
    id: 'local:$id',
    providerId: 'local',
    sourceTrackId: id,
    title: 'Title $id',
    createdAt: created,
    updatedAt: created,
    durationMs: durationMs,
    artistIds: artists,
    albumId: albumId,
    genreIds: genres,
    year: year,
    localPath: '/music/$id.m4a',
    isDownloaded: downloaded,
  );
}

/// Builds one flushed listening observation for [trackId].
PlayEvent mkEvent(
  String trackId, {
  required DateTime startedAt,
  int listenedMs = 190000,
  int durationMs = 200000,
  bool skipped = false,
  PlaySource source = PlaySource.library,
  TimeOfDayBucket? bucket,
}) {
  final ratio = (listenedMs / durationMs).clamp(0, 1).toDouble();
  final start = startedAt.toUtc();
  return PlayEvent(
    id: 'evt-${_eventSeq++}',
    trackId: trackId,
    sessionId: 'sess-test',
    startedAt: start,
    durationMs: durationMs,
    listenedMs: listenedMs,
    completionRatio: ratio,
    skipped: skipped,
    source: source,
    timeOfDayBucket: bucket ?? start.toLocal().timeOfDayBucket,
    dayOfWeek: start.toLocal().auroraDayOfWeek,
  );
}

/// Builds a skipped (low-listen) observation.
PlayEvent mkSkip(
  String trackId, {
  required DateTime startedAt,
  PlaySource source = PlaySource.library,
  TimeOfDayBucket? bucket,
}) => mkEvent(
  trackId,
  startedAt: startedAt,
  listenedMs: 8000,
  skipped: true,
  source: source,
  bucket: bucket,
);

/// Empty taste profile pinned at [now].
PreferenceProfile emptyProfile(DateTime now) =>
    PreferenceProfile(updatedAt: now);

/// Track lookup for engine calls.
Map<String, Track> trackIndex(List<Track> tracks) => <String, Track>{
  for (final track in tracks) track.id: track,
};

/// Full rebuild over [events] (nightly path, exact 7-day windows).
ProfileUpdate rebuildWith(
  List<PlayEvent> events,
  List<Track> tracks,
  DateTime now, {
  Map<String, int> likeStates = const <String, int>{},
}) => RecoEngine.rebuildProfileFromEvents(
  profile: emptyProfile(now),
  events: events,
  tracksById: trackIndex(tracks),
  now: now,
  likeStates: likeStates,
);

/// Genre share of a snapshot (0..1 of entries carrying [genre]).
double genreShare(RecoSnapshot snapshot, String genre, List<Track> catalog) {
  if (snapshot.entries.isEmpty) {
    return 0;
  }
  final byId = trackIndex(catalog);
  var hits = 0;
  for (final entry in snapshot.entries) {
    if (byId[entry.trackId]?.genreIds.contains(genre) ?? false) {
      hits++;
    }
  }
  return hits / snapshot.entries.length;
}

/// Builds home snapshots for tests (cold-start gate explicit).
Map<String, RecoSnapshot> homeSnapshots({
  required List<Track> tracks,
  required List<PlayEvent> events,
  required PreferenceProfile profile,
  required DateTime now,
  required int storedEventCount,
  List<UserTrackStats> stats = const [],
}) => RecoEngine.buildHomeSnapshots(
  tracks: tracks,
  events: events,
  stats: stats,
  profile: profile,
  now: now,
  storedEventCount: storedEventCount,
);

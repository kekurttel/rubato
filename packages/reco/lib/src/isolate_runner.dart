import 'dart:isolate';

import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_reco/src/engine.dart';
import 'package:aurora_reco/src/score.dart';
import 'package:aurora_reco/src/surfaces.dart';

/// Background-isolate entry points (spec section 10, 15).
///
/// Reco recompute must stay under 250 ms for 5k tracks and never run
/// on the UI isolate. The app layer invokes [computeSnapshots] from
/// Flutter's `compute()` (or a Drift-background isolate); this file
/// uses only `dart:isolate` so `packages/reco` keeps zero Flutter
/// imports (see the forbidden-imports test).
abstract final class RecoIsolate {
  /// Runs [request] on a fresh isolate via [Isolate.run].
  ///
  /// All payloads cross as JSON-compatible maps (freezed `toJson`),
  /// so no model instance ever crosses the isolate boundary.
  static Future<Map<String, RecoSnapshot>> computeSnapshots(
    SnapshotRequest request,
  ) => Isolate.run(() => buildSnapshots(request.toJson()));
}

/// JSON-serializable snapshot build request (isolate-safe).
final class SnapshotRequest {
  /// Creates a request.
  const SnapshotRequest({
    required this.tracks,
    required this.events,
    required this.stats,
    required this.profile,
    required this.now,
    required this.storedEventCount,
    this.similarIds = const <String>[],
    this.albumTrackCounts = const <String, int>{},
  });

  /// Deserializes inside the isolate.
  factory SnapshotRequest.fromJson(Map<String, Object?> json) {
    List<Map<String, Object?>> asMaps(Object? value) => <Map<String, Object?>>[
      if (value is List)
        for (final entry in value)
          if (entry is Map<String, Object?>)
            entry
          else if (entry is Map)
            entry.map((key, val) => MapEntry('$key', val)),
    ];
    return SnapshotRequest(
      tracks: asMaps(json['tracks']),
      events: asMaps(json['events']),
      stats: asMaps(json['stats']),
      profile:
          (json['profile'] as Map?)?.map(
            (key, value) => MapEntry('$key', value),
          ) ??
          const <String, Object?>{},
      now: (json['now'] as num?)?.toInt() ?? 0,
      storedEventCount: (json['storedEventCount'] as num?)?.toInt() ?? 0,
      similarIds: <String>[
        if (json['similarIds'] is List)
          for (final id in (json['similarIds']! as List)) '$id',
      ],
      albumTrackCounts: <String, int>{
        if (json['albumTrackCounts'] is Map)
          for (final entry in (json['albumTrackCounts']! as Map).entries)
            '${entry.key}': (entry.value as num).toInt(),
      },
    );
  }

  /// Catalog tracks as JSON.
  final List<Map<String, Object?>> tracks;

  /// Play events as JSON (any order; engine sorts).
  final List<Map<String, Object?>> events;

  /// Per-track stats as JSON.
  final List<Map<String, Object?>> stats;

  /// Taste profile as JSON.
  final Map<String, Object?> profile;

  /// Build instant as epoch milliseconds (UTC).
  final int now;

  /// Total stored events (cold-start gate).
  final int storedEventCount;

  /// Cached similar ids (source F).
  final List<String> similarIds;

  /// Known album track totals (continue-listening progress).
  final Map<String, int> albumTrackCounts;

  /// Serializes for the isolate boundary.
  Map<String, Object?> toJson() => <String, Object?>{
    'tracks': tracks,
    'events': events,
    'stats': stats,
    'profile': profile,
    'now': now,
    'storedEventCount': storedEventCount,
    'similarIds': similarIds,
    'albumTrackCounts': albumTrackCounts,
  };
}

/// Builds every home snapshot from [json] (isolate entry, top-level).
///
/// Pure function of its argument: decodes models, runs candidates →
/// rank → mix → surfaces, stamps TTLs. Heavy enough to belong on a
/// background isolate, deterministic enough for golden tests.
Map<String, RecoSnapshot> buildSnapshots(Map<String, Object?> json) {
  final request = SnapshotRequest.fromJson(json);
  final now = DateTime.fromMillisecondsSinceEpoch(request.now, isUtc: true);
  final tracks = <Track>[
    for (final raw in request.tracks) Track.fromJson(raw),
  ];
  final events = <PlayEvent>[
    for (final raw in request.events) PlayEvent.fromJson(raw),
  ];
  final stats = <UserTrackStats>[
    for (final raw in request.stats) UserTrackStats.fromJson(raw),
  ];
  final profile = PreferenceProfile.fromJson(request.profile);
  return RecoEngine.buildHomeSnapshots(
    tracks: tracks,
    events: events,
    stats: stats,
    profile: profile,
    now: now,
    storedEventCount: request.storedEventCount,
    similarIds: request.similarIds,
    albumTrackCounts: request.albumTrackCounts,
  );
}

/// Encodes a snapshot map for `RecoSnapshotDao` rows.
Map<String, Map<String, Object?>> encodeSnapshots(
  Map<String, RecoSnapshot> snapshots,
) => <String, Map<String, Object?>>{
  for (final entry in snapshots.entries) entry.key: entry.value.toJson(),
};

/// Decodes snapshot rows back into scored entries (UI read path).
Map<String, List<ScoredTrack>> decodeSnapshotEntries(
  Map<String, Map<String, Object?>> stored,
) => <String, List<ScoredTrack>>{
  for (final entry in stored.entries)
    entry.key: RecoSnapshot.fromJson(entry.value).entries,
};

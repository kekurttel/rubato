/// Local listening stats + network-purpose log (spec 13.6 + 13.7).
///
/// Everything here is computed on-device. The network log records
/// only host + purpose (never payloads) so the privacy page can
/// prove nothing personal ever leaves the device.
enum NetPurpose {
  /// Catalog search call.
  search,

  /// Entity metadata fetch.
  metadata,

  /// Artwork fetch.
  artwork,

  /// Authorized stream URL resolution / playback.
  stream,
}

/// Display label for a [NetPurpose].
String netPurposeLabel(NetPurpose purpose) => switch (purpose) {
  NetPurpose.search => 'Search',
  NetPurpose.metadata => 'Metadata',
  NetPurpose.artwork => 'Artwork',
  NetPurpose.stream => 'Stream',
};

/// One provider call: host + purpose + time (spec 13.7).
final class NetworkCall {
  /// Creates a network log entry.
  const NetworkCall({
    required this.host,
    required this.purpose,
    required this.at,
  });

  /// URL host that was contacted (no path, no query, no body).
  final String host;

  /// Why the call happened.
  final NetPurpose purpose;

  /// Call time (local, for display).
  final DateTime at;
}

/// Aggregate listening stats (local only, spec 13.6).
final class YouStats {
  /// Creates stats.
  const YouStats({
    required this.tracksPlayed,
    required this.minutesListened,
    required this.likeCount,
    required this.playlistCount,
  });

  /// Distinct tracks with at least one flushed event.
  final int tracksPlayed;

  /// Whole minutes heard across all events.
  final int minutesListened;

  /// Tracks currently liked.
  final int likeCount;

  /// User playlists (system lists excluded).
  final int playlistCount;
}

/// Mix-rate triple; always sums to 1.0 (spec 10.6, 13.6).
typedef MixRates = ({
  double exploitation,
  double adjacent,
  double exploration,
});

/// Rebalances a 3-way slider edit so the triple still sums to 1.
///
/// [changed] is 0 (exploitation), 1 (adjacent), or 2 (exploration);
/// [value] is the new 0..1 position. The other two sliders share the
/// remainder proportionally (or evenly when both are zero).
MixRates rebalanceRates(MixRates current, int changed, double value) {
  final clamped = value.clamp(0, 1).toDouble();
  final others = <double>[
    current.exploitation,
    current.adjacent,
    current.exploration,
  ]..removeAt(changed);
  final remainder = 1 - clamped;
  final total = others[0] + others[1];
  double first;
  double second;
  if (total <= 0) {
    first = remainder / 2;
    second = remainder / 2;
  } else {
    first = remainder * (others[0] / total);
    second = remainder * (others[1] / total);
  }
  final out = <double>[first, second];
  final result = <double>[0, 0, 0];
  result[changed] = clamped;
  var cursor = 0;
  for (var i = 0; i < 3; i++) {
    if (i != changed) {
      result[i] = out[cursor++];
    }
  }
  return (
    exploitation: result[0],
    adjacent: result[1],
    exploration: result[2],
  );
}

/// You-tab boundary: stats, mix sliders, cache, privacy (13.6/13.7).
abstract class YouService {
  /// Aggregate listening stats.
  Future<YouStats> stats();

  /// Current mix-rate triple (sums to 1.0).
  Future<MixRates> mixRates();

  /// Persists a validated triple (implementations reject sums != 1).
  Future<void> setMixRates(MixRates rates);

  /// Preference decay half-life in days (default 45).
  Future<double> decayHalfLifeDays();

  /// Persists the half-life (clamped 7..180 by implementations).
  Future<void> setDecayHalfLifeDays(double days);

  /// Artwork disk-cache budget in megabytes.
  Future<int> cacheMb();

  /// Persists the cache budget.
  Future<void> setCacheMb(int megabytes);

  /// Exports history + playlists + profile as JSON (privacy page).
  Future<String> exportJson();

  /// Wipes profile + stats scores (keeps files and playlists).
  Future<void> resetRecommendations();

  /// Deletes listening + search history.
  Future<void> deleteHistory();

  /// Deletes everything: history, profile, playlists, downloads.
  Future<void> deleteEverything();

  /// Last provider calls, newest-first, capped at 20.
  List<NetworkCall> networkLog();
}

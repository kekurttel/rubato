import 'package:aurora_core/aurora_core.dart';
import 'package:meta/meta.dart';

/// Persisted queue frame (cap 200 items, spec section 8).
@immutable
final class StoredQueue {
  /// Creates a frame.
  const StoredQueue({required this.items, required this.index});

  /// Empty frame.
  static const StoredQueue empty = StoredQueue(
    items: <QueueItem>[],
    index: -1,
  );

  /// Play-order items.
  final List<QueueItem> items;

  /// Playhead index into [items].
  final int index;
}

/// Persisted resume pointer (`playback_state` single row, spec section 6).
@immutable
final class StoredPlayback {
  /// Creates a frame.
  const StoredPlayback({
    required this.positionMs,
    required this.isPlaying,
    required this.shuffle,
    required this.repeatMode,
    required this.sessionId,
    required this.updatedAt,
    this.trackId,
  });

  /// Current track id, if any.
  final String? trackId;

  /// Resume position in milliseconds.
  final int positionMs;

  /// Whether audio was playing.
  final bool isPlaying;

  /// Whether shuffle was enabled.
  final bool shuffle;

  /// Repeat mode name (`off|one|all`).
  final String repeatMode;

  /// Playback session id.
  final String sessionId;

  /// Last update time (UTC).
  final DateTime updatedAt;
}

/// Persistence boundary for queue + resume state (spec section 8).
///
/// The app layer implements this over the database DAOs (`QueueDao` +
/// `playback_state` row); playback only schedules *when* to persist
/// (every 5s while playing, on pause/track change). Tests use
/// [InMemoryPlaybackStore].
abstract class PlaybackStore {
  /// Loads the persisted queue (empty frame when absent).
  Future<StoredQueue> loadQueue();

  /// Replaces the persisted queue (implementations cap at 200).
  Future<void> saveQueue(StoredQueue snapshot);

  /// Loads the resume pointer (null before the first play).
  Future<StoredPlayback?> loadState();

  /// Writes the resume pointer.
  Future<void> saveState(StoredPlayback state);
}

/// Like/dislike persistence (app wires `StatsDao.setLikeState`).
typedef LikeWriter =
    Future<void> Function({required String trackId, required int likeState});

/// In-memory store for tests and previews.
final class InMemoryPlaybackStore implements PlaybackStore {
  /// Creates an empty store.
  InMemoryPlaybackStore();

  /// Last saved queue.
  StoredQueue queue = StoredQueue.empty;

  /// Last saved resume pointer.
  StoredPlayback? state;

  /// Save calls observed (tests assert the 5s/persist schedule).
  int saveQueueCalls = 0;

  /// State-save calls observed.
  int saveStateCalls = 0;

  @override
  Future<StoredQueue> loadQueue() async => queue;

  @override
  Future<StoredPlayback?> loadState() async => state;

  @override
  Future<void> saveQueue(StoredQueue snapshot) async {
    queue = snapshot;
    saveQueueCalls++;
  }

  @override
  Future<void> saveState(StoredPlayback state) async {
    this.state = state;
    saveStateCalls++;
  }
}

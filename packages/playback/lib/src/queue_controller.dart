import 'dart:math';

import 'package:aurora_core/aurora_core.dart';

/// Playback queue with Fisher-Yates shuffle over a shadow order.
///
/// The insertion order is preserved so unshuffle restores it exactly.
/// Shuffle keeps the current item under the playhead (it is swapped
/// into place after the shuffle). Pure logic — no audio, no database.
final class QueueController {
  /// Creates an empty queue ([random] is injectable for tests).
  QueueController({Random? random}) : _random = random ?? Random();

  final Random _random;

  final List<QueueItem> _items = <QueueItem>[];
  final Map<String, Track> _tracks = <String, Track>{};

  /// Shadow play order (indices into [_items]); identity when unshuffled.
  List<int> _order = <int>[];

  /// Position of the playhead inside [_order] (-1 when empty).
  int _cursor = -1;

  /// Whether shuffle is enabled.
  bool _shuffle = false;

  /// Play-order items (unmodifiable).
  List<QueueItem> get items {
    final ordered = <QueueItem>[for (final i in _order) _items[i]];
    return List<QueueItem>.unmodifiable(ordered);
  }

  /// Playhead position in play order (-1 when empty).
  int get currentIndex => _cursor;

  /// Current item, if any.
  QueueItem? get current =>
      _cursor < 0 || _cursor >= _order.length ? null : items[_cursor];

  /// Current track, if any is loaded.
  Track? get currentTrack {
    final item = current;
    return item == null ? null : _tracks[item.trackId];
  }

  /// Whether shuffle is enabled.
  bool get shuffle => _shuffle;

  /// Whether the queue holds anything.
  bool get isEmpty => _items.isEmpty;

  /// Play-order length.
  int get length => _items.length;

  /// Track lookup by id (survives reorder).
  Track? trackById(String trackId) => _tracks[trackId];

  /// Replaces the queue (play APIs call this, then persist).
  void setQueue(
    List<Track> tracks, {
    required int startIndex,
    required PlaySource origin,
    required DateTime now,
  }) {
    _items
      ..clear()
      ..addAll(<QueueItem>[
        for (final track in tracks)
          QueueItem(
            id: AuroraIds.newId(),
            trackId: track.id,
            origin: origin,
            addedAt: now,
          ),
      ]);
    _tracks
      ..clear()
      ..addEntries(
        <MapEntry<String, Track>>[
          for (final track in tracks) MapEntry(track.id, track),
        ],
      );
    _order = <int>[for (var i = 0; i < _items.length; i++) i];
    _shuffle = false;
    _cursor = _items.isEmpty ? -1 : startIndex.clamp(0, _items.length - 1);
  }

  /// Restores persisted items (process-death path; tracks re-resolve).
  void restore({
    required List<QueueItem> items,
    required int index,
    required Map<String, Track> tracks,
  }) {
    _items
      ..clear()
      ..addAll(items);
    _tracks
      ..clear()
      ..addAll(tracks);
    _order = <int>[for (var i = 0; i < _items.length; i++) i];
    _shuffle = false;
    _cursor = _items.isEmpty ? -1 : index.clamp(0, _items.length - 1);
  }

  /// Enables/disables shuffle (Fisher-Yates; original kept for unshuffle).
  void setShuffle({required bool enabled}) {
    if (enabled == _shuffle || _items.isEmpty) {
      _shuffle = enabled;
      return;
    }
    _shuffle = enabled;
    if (enabled) {
      _applyShuffle();
    } else {
      final currentId = current?.id;
      _order = <int>[for (var i = 0; i < _items.length; i++) i];
      if (currentId != null) {
        _cursor = _order.indexWhere((i) => _items[i].id == currentId);
      }
    }
  }

  /// Fisher-Yates over the shadow order; current item stays put.
  void _applyShuffle() {
    final currentItem = _cursor >= 0 && _cursor < _order.length
        ? _items[_order[_cursor]]
        : null;
    final order = <int>[for (var i = 0; i < _items.length; i++) i];
    for (var i = order.length - 1; i > 0; i--) {
      final j = _random.nextInt(i + 1);
      final swap = order[i];
      order[i] = order[j];
      order[j] = swap;
    }
    _order = order;
    if (currentItem != null) {
      final at = _order.indexWhere((i) => _items[i].id == currentItem.id);
      if (at >= 0) {
        _order[at] = _order[_cursor];
        _order[_cursor] = _items.indexOf(currentItem);
      }
    }
  }

  /// Moves the playhead; returns the newly current item (null at edges).
  QueueItem? step(int delta) {
    if (_items.isEmpty) {
      return null;
    }
    final next = _cursor + delta;
    if (next < 0 || next >= _order.length) {
      return null;
    }
    _cursor = next;
    return current;
  }

  /// Jumps the playhead to a play-order [index].
  QueueItem? jumpTo(int index) {
    if (index < 0 || index >= _order.length) {
      return null;
    }
    _cursor = index;
    return current;
  }

  /// Items after the playhead (radio refill watches this count).
  int get remaining => _items.isEmpty ? 0 : _order.length - _cursor - 1;

  /// Inserts [track] directly after the playhead (play order).
  ///
  /// Explicit inserts flatten the shuffle shadow into the new play order;
  /// toggling shuffle afterwards reshuffles from there.
  void addNext(
    Track track, {
    required PlaySource origin,
    required DateTime now,
  }) {
    final item = QueueItem(
      id: AuroraIds.newId(),
      trackId: track.id,
      origin: origin,
      addedAt: now,
    );
    _tracks[track.id] = track;
    if (_items.isEmpty) {
      _items.add(item);
      _order = <int>[0];
      _cursor = 0;
      return;
    }
    final playOrder = items.toList()..insert(_cursor + 1, item);
    final byId = <String, QueueItem>{for (final i in _items) i.id: i}
      ..[item.id] = item;
    _items
      ..clear()
      ..addAll(<QueueItem>[for (final i in playOrder) byId[i.id]!]);
    _order = <int>[for (var i = 0; i < _items.length; i++) i];
  }

  /// Appends [track] at the end of the queue.
  void addLast(
    Track track, {
    required PlaySource origin,
    required DateTime now,
  }) {
    final item = QueueItem(
      id: AuroraIds.newId(),
      trackId: track.id,
      origin: origin,
      addedAt: now,
    );
    _tracks[track.id] = track;
    _items.add(item);
    _order.add(_items.length - 1);
    if (_cursor < 0) {
      _cursor = 0;
    }
  }

  /// Removes the play-order entry at [playIndex].
  void removeAt(int playIndex) {
    if (playIndex < 0 || playIndex >= _order.length) {
      return;
    }
    final raw = _order[playIndex];
    final removed = _items.removeAt(raw);
    if (!_items.any((i) => i.trackId == removed.trackId)) {
      _tracks.remove(removed.trackId);
    }
    _order = <int>[for (var i = 0; i < _items.length; i++) i];
    if (_items.isEmpty) {
      _cursor = -1;
      return;
    }
    if (_cursor > playIndex) {
      _cursor -= 1;
    } else if (_cursor >= _order.length) {
      _cursor = _order.length - 1;
    }
  }

  /// Moves a play-order entry (playlist/queue-sheet reorder).
  void move(int fromPlayIndex, int toPlayIndex) {
    if (fromPlayIndex < 0 ||
        fromPlayIndex >= _order.length ||
        toPlayIndex < 0 ||
        toPlayIndex >= _order.length) {
      return;
    }
    final currentId = current?.id;
    final playOrder = items.toList();
    final entry = playOrder.removeAt(fromPlayIndex);
    playOrder.insert(toPlayIndex, entry);
    final byId = <String, QueueItem>{for (final i in _items) i.id: i};
    _items
      ..clear()
      ..addAll(<QueueItem>[for (final i in playOrder) byId[i.id]!]);
    _order = <int>[for (var i = 0; i < _items.length; i++) i];
    if (currentId != null) {
      _cursor = _items.indexWhere((i) => i.id == currentId);
    }
  }

  /// Play-order snapshot for persistence (callers cap at 200).
  ({List<QueueItem> items, int index}) snapshot() => (
    items: items,
    index: _cursor,
  );
}

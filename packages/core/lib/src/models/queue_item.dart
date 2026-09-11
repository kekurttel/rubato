import 'package:aurora_core/src/models/enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'queue_item.freezed.dart';
part 'queue_item.g.dart';

/// One entry of the playback queue (spec section 5).
@freezed
abstract class QueueItem with _$QueueItem {
  /// Creates a queue item.
  const factory QueueItem({
    /// Queue row id (uuid v7).
    required String id,

    /// Queued track id.
    required String trackId,

    /// Where the item was enqueued from.
    required PlaySource origin,

    /// Enqueue time (UTC).
    required DateTime addedAt,

    /// Ranker score frozen at enqueue time, if ranked.
    double? frozenScore,
  }) = _QueueItem;

  const QueueItem._();

  /// Deserializes a queue item from JSON.
  factory QueueItem.fromJson(Map<String, dynamic> json) =>
      _$QueueItemFromJson(json);
}

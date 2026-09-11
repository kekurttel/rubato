import 'package:aurora_core/aurora_core.dart';

import 'package:aurora_database/src/aurora_db.dart';

/// Converts drift rows to freezed domain models (spec section 5).
///
/// All timestamps arrive as UTC epoch milliseconds; models expose UTC
/// `DateTime`s. Integer flags (`0/1`) become `bool`s here so the spec's
/// exact on-disk schema never leaks into app code.
abstract final class DbMappers {
  /// Maps a track row + its join ids to a [Track].
  static Track toTrack(
    DbTrack row, {
    List<String> artistIds = const <String>[],
    List<String> genreIds = const <String>[],
  }) => Track(
    id: row.id,
    providerId: row.providerId,
    sourceTrackId: row.sourceTrackId,
    title: row.title,
    createdAt: DateTime.fromMillisecondsSinceEpoch(
      row.createdAt,
      isUtc: true,
    ),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(
      row.updatedAt,
      isUtc: true,
    ),
    durationMs: row.durationMs,
    explicit: row.explicit == 1,
    artistIds: artistIds,
    albumId: row.albumId,
    genreIds: genreIds,
    year: row.year,
    audioHash: row.audioHash,
    localPath: row.localPath,
    isDownloaded: row.isDownloaded == 1,
    streamExpiresAt: row.streamExpiresAt == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(
            row.streamExpiresAt!,
            isUtc: true,
          ),
  );

  /// Maps an artist row to an [Artist].
  static Artist toArtist(DbArtist row) => Artist(
    id: row.id,
    name: row.name,
    sourceId: row.sourceId ?? row.id,
    providerId: row.providerId ?? 'local',
    imageUrl: row.imageUrl,
  );

  /// Maps an album row to an [Album].
  static Album toAlbum(DbAlbum row, {List<String> artistIds = const []}) =>
      Album(
        id: row.id,
        title: row.title,
        providerId: row.providerId ?? 'local',
        sourceId: row.sourceId ?? row.id,
        artistIds: artistIds,
        year: row.year,
        artworkId: row.artworkId,
        trackCount: row.trackCount ?? 0,
      );

  /// Maps an artwork row to an [Artwork].
  static Artwork toArtwork(DbArtwork row) => Artwork(
    id: row.id,
    updatedAt: DateTime.fromMillisecondsSinceEpoch(
      row.updatedAt ?? 0,
      isUtc: true,
    ),
    url: row.url,
    localPath: row.localPath,
    dominantColorArgb: row.dominantArgb,
    width: row.width,
    height: row.height,
  );

  /// Maps a playlist row to a [Playlist].
  static Playlist toPlaylist(DbPlaylist row) => Playlist(
    id: row.id,
    title: row.title,
    createdAt: DateTime.fromMillisecondsSinceEpoch(
      row.createdAt ?? 0,
      isUtc: true,
    ),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(
      row.updatedAt ?? row.createdAt ?? 0,
      isUtc: true,
    ),
    description: row.description,
    artworkId: row.artworkId,
    isSystem: row.isSystem == 1,
  );

  /// Maps a playlist-entry row to a [PlaylistEntry].
  static PlaylistEntry toPlaylistEntry(DbPlaylistEntry row) => PlaylistEntry(
    playlistId: row.playlistId,
    trackId: row.trackId,
    position: row.position,
    addedAt: DateTime.fromMillisecondsSinceEpoch(
      row.addedAt ?? 0,
      isUtc: true,
    ),
  );

  /// Maps a play-event row to a [PlayEvent].
  static PlayEvent toPlayEvent(DbPlayEvent row) => PlayEvent(
    id: row.id,
    trackId: row.trackId,
    sessionId: row.sessionId,
    startedAt: DateTime.fromMillisecondsSinceEpoch(
      row.startedAt,
      isUtc: true,
    ),
    durationMs: row.durationMs ?? 0,
    listenedMs: row.listenedMs ?? 0,
    completionRatio: (row.completionRatio ?? 0).clamp(0, 1).toDouble(),
    skipped: (row.skipped ?? 0) == 1,
    source: _playSourceFrom(row.source),
    timeOfDayBucket: _bucketFrom(row.timeOfDayBucket, row.startedAt),
    dayOfWeek: row.dayOfWeek ?? 0,
    endedAt: row.endedAt == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(row.endedAt!, isUtc: true),
    skipAtMs: row.skipAtMs,
    playbackSpeed: row.playbackSpeed ?? 1.0,
    wasOffline: (row.wasOffline ?? 0) == 1,
    seekCount: row.seekCount ?? 0,
  );

  /// Maps a stats row to a [UserTrackStats].
  static UserTrackStats toStats(DbUserTrackStat row) => UserTrackStats(
    trackId: row.trackId,
    updatedAt: DateTime.fromMillisecondsSinceEpoch(
      row.updatedAt ?? 0,
      isUtc: true,
    ),
    playCount: row.playCount ?? 0,
    skipCount: row.skipCount ?? 0,
    completeCount: row.completeCount ?? 0,
    replayCount: row.replayCount ?? 0,
    totalListenMs: row.totalListenMs ?? 0,
    lastPlayedAt: row.lastPlayedAt == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(
            row.lastPlayedAt!,
            isUtc: true,
          ),
    likeState: row.likeState ?? 0,
    decayedScore: row.decayedScore ?? 0,
  );

  /// Maps a queue row to a [QueueItem].
  static QueueItem toQueueItem(DbQueueItem row) => QueueItem(
    id: row.id,
    trackId: row.trackId ?? '',
    origin: _playSourceFrom(row.origin),
    addedAt: DateTime.fromMillisecondsSinceEpoch(
      row.addedAt ?? 0,
      isUtc: true,
    ),
    frozenScore: row.frozenScore,
  );

  /// Maps a download row to a [DownloadJob].
  static DownloadJob toDownloadJob(DbDownloadJob row) => DownloadJob(
    id: row.id,
    trackId: row.trackId ?? '',
    createdAt: DateTime.fromMillisecondsSinceEpoch(
      row.createdAt ?? 0,
      isUtc: true,
    ),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(
      row.updatedAt ?? row.createdAt ?? 0,
      isUtc: true,
    ),
    state: _downloadStateFrom(row.state),
    progress: (row.progress ?? 0).clamp(0, 1).toDouble(),
    bytesReceived: row.bytesReceived ?? 0,
    bytesTotal: row.bytesTotal,
    errorCode: row.errorCode,
    errorMessage: row.errorMessage,
    attempts: row.attempts ?? 0,
    qualityLabel: row.qualityLabel,
    filePath: row.filePath,
  );

  static PlaySource _playSourceFrom(String? raw) {
    if (raw == null || raw.isEmpty) {
      return PlaySource.library;
    }
    for (final value in PlaySource.values) {
      if (value.name == raw) {
        return value;
      }
    }
    return PlaySource.library;
  }

  static TimeOfDayBucket _bucketFrom(String? raw, int startedAtMs) {
    if (raw != null) {
      for (final value in TimeOfDayBucket.values) {
        if (value.name == raw) {
          return value;
        }
      }
    }
    return DateTime.fromMillisecondsSinceEpoch(
      startedAtMs,
      isUtc: true,
    ).toLocal().timeOfDayBucket;
  }

  static DownloadState _downloadStateFrom(String? raw) {
    if (raw == null || raw.isEmpty) {
      return DownloadState.queued;
    }
    for (final value in DownloadState.values) {
      if (value.name == raw) {
        return value;
      }
    }
    return DownloadState.queued;
  }
}

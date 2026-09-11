import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_mobile/features/library/library_providers.dart';
import 'package:aurora_mobile/features/library/library_widgets.dart';
import 'package:aurora_mobile/features/search/search_widgets.dart';
import 'package:aurora_mobile/wiring.dart';
import 'package:aurora_ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Header subtitle for detail pages: `12 tracks · 48 min`.
///
/// The length part is omitted when no duration is known, so the header
/// never renders a `0 min` artifact.
String detailTracksSubtitle(List<Track> tracks) {
  final count = tracks.length;
  final noun = count == 1 ? 'track' : 'tracks';
  final total = Duration(
    milliseconds: tracks.fold<int>(
      0,
      (sum, track) => sum + track.durationMs,
    ),
  );
  if (total.inMilliseconds <= 0) {
    return '$count $noun';
  }
  final hours = total.inHours;
  final minutes = total.inMinutes % 60;
  final length = hours > 0 ? '${hours}h ${minutes}m' : '${total.inMinutes} min';
  return '$count $noun · $length';
}

/// One detail row: optional track number, playing indicator, overflow.
///
/// Numbers render for album / popular lists; playlist rows pass
/// [dragIndex] instead to expose the reorder handle. The title and
/// indicator pick up the theme accent while the track is current.
class DetailTrackRow extends StatelessWidget {
  /// Creates a detail row.
  const DetailTrackRow({
    required this.track,
    required this.artistLine,
    required this.onTap,
    required this.onOverflowTap,
    super.key,
    this.isPlaying = false,
    this.trackNumber,
    this.dragIndex,
  });

  /// Track to render.
  final Track track;

  /// Pre-joined artist names.
  final String artistLine;

  /// Row tap (plays the surrounding list from this position).
  final VoidCallback onTap;

  /// Overflow menu tap.
  final VoidCallback onOverflowTap;

  /// Whether this track is the current player item.
  final bool isPlaying;

  /// 1-based position shown when not playing (null hides the number).
  final int? trackNumber;

  /// Reorder position: non-null shows the drag handle.
  final int? dragIndex;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final drag = dragIndex;
    final durationLabel = formatTrackDuration(track.duration);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: isPlaying
                  ? Icon(Icons.equalizer, size: 18, color: accent)
                  : trackNumber == null
                  ? const Icon(
                      Icons.music_note_outlined,
                      size: 18,
                      color: AuroraColors.textLow,
                    )
                  : Text(
                      '$trackNumber',
                      style: AuroraType.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    track.title,
                    style: AuroraType.titleSmall.copyWith(
                      color: isPlaying ? accent : AuroraColors.textHi,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          artistLine,
                          style: AuroraType.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (durationLabel.isNotEmpty)
                        Text(durationLabel, style: AuroraType.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
            if (drag != null)
              ReorderableDragStartListener(
                index: drag,
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.drag_handle_outlined),
                ),
              ),
            IconButton(
              onPressed: onOverflowTap,
              icon: const Icon(Icons.more_vert),
              tooltip: 'More actions',
            ),
          ],
        ),
      ),
    );
  }
}

/// Overflow sheet shared by playlist / album / artist detail rows.
///
/// Items: play next, add to queue (existing playback queue actions),
/// add to playlist (existing picker sheet), remove from playlist (only
/// when a playlist id is given, via the library service), go to
/// album/artist (existing routes, only when the track carries them).
/// Never throws for missing services: unavailable actions phone home
/// as a snackbar instead.
abstract final class DetailTrackOverflow {
  /// Shows the sheet for [track].
  static Future<void> show(
    /// Outer context (owns navigation + snackbars after the pop).
    BuildContext context, {

    /// Reader for the service boundaries.
    required WidgetRef ref,

    /// Track the actions apply to.
    required Track track,

    /// Playback origin recorded for queue inserts.
    PlaySource origin = PlaySource.library,

    /// Playlist to remove from (null hides the remove item).
    String? playlistId,
  }) => showAuroraBottomSheet<void>(
    context: context,
    builder: (sheet) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.playlist_play_outlined),
            title: const Text('Play next'),
            onTap: () {
              final wiring = ref.read(auroraWiringProvider);
              if (wiring == null) {
                Navigator.pop(sheet);
                return;
              }
              wiring.playback.addNext(track, origin: origin);
              Navigator.pop(sheet);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Will play next')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.queue_music_outlined),
            title: const Text('Add to queue'),
            onTap: () {
              final wiring = ref.read(auroraWiringProvider);
              if (wiring == null) {
                Navigator.pop(sheet);
                return;
              }
              wiring.playback.addLast(track, origin: origin);
              Navigator.pop(sheet);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to queue')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.playlist_add_outlined),
            title: const Text('Add to playlist'),
            onTap: () async {
              Navigator.pop(sheet);
              await AddToPlaylistSheet.show(context, track.id);
            },
          ),
          if (playlistId != null)
            ListTile(
              leading: const Icon(Icons.remove_circle_outline),
              title: const Text('Remove from playlist'),
              onTap: () async {
                Navigator.pop(sheet);
                await ref
                    .read(libraryServiceProvider)
                    ?.removeFromPlaylist(playlistId, track.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Removed from playlist'),
                    ),
                  );
                }
              },
            ),
          if (track.albumId != null)
            ListTile(
              leading: const Icon(Icons.album_outlined),
              title: const Text('Go to album'),
              onTap: () async {
                Navigator.pop(sheet);
                await context.push(
                  '/album/${Uri.encodeComponent(track.albumId!)}',
                );
              },
            ),
          if (track.artistIds.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Go to artist'),
              onTap: () async {
                Navigator.pop(sheet);
                await context.push(
                  '/artist/${Uri.encodeComponent(track.artistIds.first)}',
                );
              },
            ),
        ],
      ),
    ),
  );
}

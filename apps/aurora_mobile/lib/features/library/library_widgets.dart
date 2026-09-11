import 'dart:async';
import 'dart:io';

import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_mobile/features/library/library_providers.dart';
import 'package:aurora_mobile/features/library/library_service.dart';
import 'package:aurora_mobile/library_scan.dart';
import 'package:aurora_mobile/wiring.dart';
import 'package:aurora_ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Asks for a playlist title; returns null on dismiss.
Future<String?> showPlaylistTitleDialog(
  /// Build context for the dialog.
  BuildContext context, {

  /// Dialog headline.
  String title = 'New playlist',

  /// Prefilled title (rename flow).
  String initial = '',
}) async {
  final controller = TextEditingController(text: initial);
  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(hintText: 'Playlist title'),
        onSubmitted: (value) => Navigator.pop(context, value.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text.trim()),
          child: const Text('Save'),
        ),
      ],
    ),
  );
  controller.dispose();
  if (result == null || result.isEmpty) {
    return null;
  }
  return result;
}

/// Sort-order popup menu (recent / title / artist).
class LibrarySortMenu extends ConsumerWidget {
  /// Creates the sort menu.
  const LibrarySortMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sort = ref.watch(librarySortProvider);
    return PopupMenuButton<LibrarySort>(
      icon: const Icon(Icons.sort_outlined),
      tooltip: 'Sort',
      initialValue: sort,
      onSelected: (value) =>
          ref.read(librarySortProvider.notifier).state = value,
      itemBuilder: (context) => [
        for (final option in LibrarySort.values)
          PopupMenuItem(
            value: option,
            child: Text(librarySortLabel(option)),
          ),
      ],
    );
  }
}

/// Track rows with the active sort applied.
class SortedTrackList extends ConsumerWidget {
  /// Creates a sorted track list.
  const SortedTrackList({
    required this.tracks,
    super.key,
    this.preserveOrder = false,
  });

  /// Unsorted input rows.
  final List<Track> tracks;

  /// When true, [tracks] render in the given order (e.g. the Downloads
  /// tab's newest-first job order) instead of the shared sort.
  final bool preserveOrder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sort = ref.watch(librarySortProvider);
    final service = ref.watch(libraryServiceProvider);
    final recentIds = ref.watch(libraryRecentlyProvider).valueOrNull;
    final sorted = preserveOrder
        ? [...tracks]
        : sortLibraryTracks(
            tracks,
            sort,
            recentIds: [
              for (final track in recentIds ?? const <Track>[]) track.id,
            ],
            artistLine: service?.artistLine,
          );
    if (sorted.isEmpty) {
      return const EmptyState(
        title: 'Nothing here yet',
        message: 'Tracks you save and download appear here.',
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < sorted.length; i++)
          LocalTrackTile(
            track: sorted[i],
            artistLine: service?.artistLine(sorted[i]) ?? 'Unknown artist',
            onTap: () => service?.playTracks(sorted, startIndex: i),
            onOverflowTap: () => _TrackOverflow.show(
              context,
              ref,
              sorted[i],
            ),
          ),
      ],
    );
  }
}

/// Track row with the scan-cached local cover (null = monogram).
///
/// Watches [localTrackArtProvider] so rescans repaint rows without a
/// manual refresh; online tracks resolve to null and keep the online
/// art path of their own row widgets.
class LocalTrackTile extends ConsumerWidget {
  /// Creates a local-aware track row.
  const LocalTrackTile({
    required this.track,
    required this.artistLine,
    super.key,
    this.isPlaying = false,
    this.onTap,
    this.onOverflowTap,
  });

  /// Track to render.
  final Track track;

  /// Pre-joined artist names.
  final String artistLine;

  /// Whether this track is the current player item.
  final bool isPlaying;

  /// Row tap (default: play).
  final VoidCallback? onTap;

  /// Overflow menu tap. Null hides the menu button.
  final VoidCallback? onOverflowTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final art = ref.watch(localTrackArtProvider(track.id)).valueOrNull;
    final wiring = ref.watch(auroraWiringProvider);
    final customArt = wiring?.customArtworkFor(track);
    final displayTrack = customArt == null && wiring == null
        ? track
        : track.copyWith(title: wiring?.displayTitleFor(track) ?? track.title);
    return TrackTile(
      track: displayTrack,
      artistLine: artistLine,
      isPlaying: isPlaying,
      coverLocalPath: customArt ?? art,
      coverImageUrl: customArt == null && art == null
          ? trackFallbackThumbnailUrl(track)
          : null,
      onTap: onTap,
      onOverflowTap: onOverflowTap,
    );
  }
}

Future<void> _editTrackMetadata(
  BuildContext context,
  WidgetRef ref,
  Track track,
) async {
  final wiring = ref.read(auroraWiringProvider);
  if (wiring == null) return;
  final title = TextEditingController(text: wiring.displayTitleFor(track));
  final description = TextEditingController(
    text: wiring.descriptionFor(track) ?? '',
  );
  var artwork = wiring.customArtworkFor(track);
  final result = await showDialog<bool>(
    context: context,
    builder: (dialog) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Edit music'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: description,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final path = await const MethodChannel(
                    'aurora.player/downloads',
                  ).invokeMethod<String>('downloads/pickImage');
                  if (path != null && context.mounted) {
                    setState(() => artwork = path);
                  }
                },
                icon: const Icon(Icons.image_outlined),
                label: Text(artwork == null ? 'Choose cover' : 'Change cover'),
              ),
              if (artwork != null) ...[
                const SizedBox(height: 8),
                Image.file(
                  File(artwork!),
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
  final newTitle = title.text;
  final newDescription = description.text;
  title.dispose();
  description.dispose();
  if (result == true) {
    await wiring.saveTrackMetadata(
      track,
      title: newTitle,
      description: newDescription,
      artworkPath: artwork,
    );
  }
}

/// Overflow menu: play next, queue, add to playlist, go to
/// album/artist.
abstract final class _TrackOverflow {
  static Future<void> show(
    BuildContext context,
    WidgetRef ref,
    Track track,
  ) => showAuroraBottomSheet<void>(
    context: context,
    builder: (sheet) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.playlist_play_outlined),
            title: const Text('Play next'),
            onTap: () {
              ref
                  .read(auroraWiringProvider)
                  ?.playback
                  .addNext(track, origin: PlaySource.library);
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
              ref
                  .read(auroraWiringProvider)
                  ?.playback
                  .addLast(track, origin: PlaySource.library);
              Navigator.pop(sheet);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to queue')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Edit music'),
            onTap: () async {
              Navigator.pop(sheet);
              await _editTrackMetadata(context, ref, track);
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite_border),
            title: const Text('Add to a playlist'),
            onTap: () async {
              Navigator.pop(sheet);
              await AddToPlaylistSheet.show(context, track.id);
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

/// Playlist picker for "add to playlist".
abstract final class AddToPlaylistSheet {
  /// Shows the picker for [trackId].
  static Future<void> show(BuildContext context, String trackId) =>
      showAuroraBottomSheet<void>(
        context: context,
        builder: (context) => _PlaylistPicker(trackId: trackId),
      );
}

/// Playlist picker body (watches the playlist stream).
class _PlaylistPicker extends ConsumerWidget {
  /// Creates the picker.
  const _PlaylistPicker({required this.trackId});

  /// Track to add.
  final String trackId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists =
        ref.watch(libraryPlaylistsProvider).valueOrNull ?? const <Playlist>[];
    final service = ref.watch(libraryServiceProvider);
    final userLists = [
      for (final playlist in playlists)
        if (!playlist.isSystem) playlist,
    ];
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Text(
              'Add to playlist',
              style: AuroraType.titleSmall,
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final playlist in userLists)
                  ListTile(
                    leading: const Icon(Icons.queue_music_outlined),
                    title: Text(playlist.title),
                    onTap: () async {
                      await service?.addToPlaylist(
                        playlist.id,
                        trackId,
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                if (userLists.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No playlists yet — create one first.',
                      style: AuroraType.bodyMedium,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// M3U import button with result feedback (never crashes on bad
/// files: the service tolerates empty/missing entries).
class M3uImportButton extends ConsumerWidget {
  /// Creates the import button.
  const M3uImportButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(libraryServiceProvider);
    return OutlinedButton.icon(
      onPressed: service == null
          ? null
          : () async {
              final result = await service.importM3u();
              if (!context.mounted) {
                return;
              }
              final detail = result.missing > 0
                  ? ' (${result.missing} skipped)'
                  : '';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Imported ${result.imported} tracks$detail.',
                  ),
                ),
              );
            },
      icon: const Icon(Icons.upload_file_outlined),
      label: const Text('Import M3U'),
    );
  }
}

/// Asks for a YouTube playlist link or ID; returns null on cancel or empty.
Future<String?> showYouTubePlaylistInputDialog(BuildContext context) async {
  final controller = TextEditingController();
  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Import YouTube Playlist'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'YouTube playlist link or ID',
        ),
        onSubmitted: (value) => Navigator.pop(context, value.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text.trim()),
          child: const Text('Import'),
        ),
      ],
    ),
  );
  controller.dispose();
  if (result == null || result.isEmpty) {
    return null;
  }
  return result;
}

/// YouTube playlist import button with dialog, progress feedback,
/// and navigation to the newly imported playlist.
class YouTubePlaylistImportButton extends ConsumerStatefulWidget {
  /// Creates the YouTube playlist import button.
  const YouTubePlaylistImportButton({super.key});

  @override
  ConsumerState<YouTubePlaylistImportButton> createState() =>
      _YouTubePlaylistImportButtonState();
}

class _YouTubePlaylistImportButtonState
    extends ConsumerState<YouTubePlaylistImportButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(libraryServiceProvider);
    return OutlinedButton.icon(
      onPressed: (service == null || _isLoading)
          ? null
          : () async {
              final input = await showYouTubePlaylistInputDialog(context);
              if (input == null || !context.mounted) {
                return;
              }
              setState(() => _isLoading = true);
              try {
                final playlist = await service.importYouTubePlaylist(input);
                if (!context.mounted) {
                  return;
                }
                if (playlist != null) {
                  final trackIds = await service.playlistTrackIds(playlist.id);
                  ref.invalidate(libraryPlaylistsProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Imported '${playlist.title}' "
                          '(${trackIds.length} tracks)',
                        ),
                      ),
                    );
                    unawaited(
                      context.push(
                        '/playlist/${Uri.encodeComponent(playlist.id)}',
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Could not import playlist.'),
                    ),
                  );
                }
              } on Object {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Could not import playlist.'),
                    ),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() => _isLoading = false);
                }
              }
            },
      icon: _isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.playlist_add_outlined),
      label: Text(
        _isLoading ? 'Importing...' : 'Import YouTube Playlist',
      ),
    );
  }
}

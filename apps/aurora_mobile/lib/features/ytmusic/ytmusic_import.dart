import 'dart:async';

import 'package:aurora_mobile/features/library/library_providers.dart';
import 'package:aurora_music_source_ytdlp/aurora_music_source_ytdlp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Imports one account-library playlist as a streamable local playlist
/// (private lists resolve through the account session) and opens it.
///
/// Shared by the YouTube Music screen and the Playlists tab. Never
/// throws: failures surface as a snackbar.
Future<void> importYtMusicPlaylist(
  BuildContext context,
  WidgetRef ref,
  YtMusicPlaylist playlist,
) async {
  final service = ref.read(libraryServiceProvider);
  if (service == null) {
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Importing ${playlist.title}…')),
  );
  final imported = await service.importYouTubePlaylist(
    'https://music.youtube.com/playlist?list=${playlist.playlistId}',
  );
  if (!context.mounted) {
    return;
  }
  if (imported == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not import — check the account session.'),
      ),
    );
    return;
  }
  ref.invalidate(libraryPlaylistsProvider);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Imported ${imported.title}.')),
  );
  unawaited(
    context.push('/playlist/${Uri.encodeComponent(imported.id)}'),
  );
}

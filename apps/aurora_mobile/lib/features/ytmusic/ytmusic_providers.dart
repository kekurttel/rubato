import 'package:aurora_mobile/features/you/youtube_account.dart';
import 'package:aurora_mobile/wiring.dart';
import 'package:aurora_music_source_ytdlp/aurora_music_source_ytdlp.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The account's own YouTube Music home shelves (personalized feed).
///
/// Empty while signed out, offline, or expired — the screen then shows
/// the generic chart rails only. Never throws.
final FutureProvider<List<YtMusicShelf>> ytAccountShelvesProvider =
    FutureProvider<List<YtMusicShelf>>((ref) async {
      final signedIn = await ref.watch(ytAccountStatusProvider.future);
      if (!signedIn) {
        return const <YtMusicShelf>[];
      }
      final wiring = ref.watch(auroraWiringProvider);
      if (wiring == null) {
        return const <YtMusicShelf>[];
      }
      try {
        return await wiring.ytdlp.account.homeShelves();
      } on Object {
        return const <YtMusicShelf>[];
      }
    });

/// Playlists in the account's YouTube Music library.
///
/// Empty while signed out/offline. Never throws.
final FutureProvider<List<YtMusicPlaylist>> ytAccountPlaylistsProvider =
    FutureProvider<List<YtMusicPlaylist>>((ref) async {
      final signedIn = await ref.watch(ytAccountStatusProvider.future);
      if (!signedIn) {
        return const <YtMusicPlaylist>[];
      }
      final wiring = ref.watch(auroraWiringProvider);
      if (wiring == null) {
        return const <YtMusicPlaylist>[];
      }
      try {
        return await wiring.ytdlp.account.libraryPlaylists();
      } on Object {
        return const <YtMusicPlaylist>[];
      }
    });

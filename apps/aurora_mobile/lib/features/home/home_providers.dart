import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_mobile/features/home/home_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Injectable clock for the greeting + bucket math (tests override).
final Provider<Clock> homeClockProvider = Provider<Clock>(
  (ref) => const SystemClock(),
);

/// Snapshot boundary (null until the app lane injects repositories).
final Provider<HomeRecoService?> homeRecoServiceProvider =
    Provider<HomeRecoService?>((ref) => null);

/// Row/card action boundary (null until the app lane injects it).
final Provider<HomeActions?> homeActionsProvider = Provider<HomeActions?>(
  (ref) => null,
);

/// Resolved entries for one surface (empty while unwired/loading).
final FutureProviderFamily<List<HomeRecoEntry>, String> homeEntriesProvider =
    FutureProvider.family<List<HomeRecoEntry>, String>((ref, surface) async {
      final service = ref.watch(homeRecoServiceProvider);
      if (service == null) {
        return const <HomeRecoEntry>[];
      }
      return service.entriesFor(surface);
    });

/// Resumable albums/playlists (empty hides the Continue section).
final FutureProvider<List<ContinueItem>> continueListeningProvider =
    FutureProvider<List<ContinueItem>>((ref) async {
      final service = ref.watch(homeRecoServiceProvider);
      if (service == null) {
        return const <ContinueItem>[];
      }
      return service.continueListening();
    });

/// Selected mood chip (null = unfiltered shelves; tap again to clear).
final StateProvider<HomeMood?> homeMoodProvider = StateProvider<HomeMood?>(
  (ref) => null,
);

/// "Yeniden dinleyin" shelf: recent plays first, replay-heavy fill
/// ([HomeSurfaces.replayMix]), deduped (empty hides the section).
final Provider<List<HomeRecoEntry>> listenAgainProvider =
    Provider<List<HomeRecoEntry>>((ref) {
      final recent =
          ref
              .watch(homeEntriesProvider(HomeSurfaces.recentlyPlayed))
              .valueOrNull ??
          const <HomeRecoEntry>[];
      final replay =
          ref.watch(homeEntriesProvider(HomeSurfaces.replayMix)).valueOrNull ??
          const <HomeRecoEntry>[];
      return listenAgainEntries(recent: recent, replayHeavy: replay);
    });

/// Mood shelf for the selected chip (empty hides the section).
///
/// Prefers the existing engine mix ([homeMoodSurface]) when present;
/// otherwise re-seeds the already-loaded snapshot pool in memory via
/// [applyHomeMood] — no new snapshot rows are written.
final Provider<List<HomeRecoEntry>> homeMoodShelfProvider =
    Provider<List<HomeRecoEntry>>((ref) {
      final mood = ref.watch(homeMoodProvider);
      if (mood == null) {
        return const <HomeRecoEntry>[];
      }
      final engine =
          ref.watch(homeEntriesProvider(homeMoodSurface(mood))).valueOrNull ??
          const <HomeRecoEntry>[];
      if (engine.isNotEmpty) {
        return engine.take(homeMoodShelfCount).toList();
      }
      const poolSurfaces = <String>[
        HomeSurfaces.madeForYou,
        HomeSurfaces.dailyMix1,
        HomeSurfaces.dailyMix2,
        HomeSurfaces.dailyMix3,
        HomeSurfaces.discover,
        HomeSurfaces.newReleaseMix,
        HomeSurfaces.basedOnListening,
        HomeSurfaces.recentlyPlayed,
      ];
      final seen = <String>{};
      final pool = <HomeRecoEntry>[];
      for (final surface in poolSurfaces) {
        final entries =
            ref.watch(homeEntriesProvider(surface)).valueOrNull ??
            const <HomeRecoEntry>[];
        for (final entry in entries) {
          if (seen.add(entry.track.id)) {
            pool.add(entry);
          }
        }
      }
      return applyHomeMood(pool, mood);
    });

/// Online reachability (offline until the service is wired, so the
/// Library-mode banner shows instead of a spinner).
final StreamProvider<ProviderHealth> homeHealthProvider =
    StreamProvider<ProviderHealth>((ref) {
      final service = ref.watch(homeRecoServiceProvider);
      if (service == null) {
        return Stream<ProviderHealth>.value(ProviderHealth.offline);
      }
      return service.onlineHealth();
    });

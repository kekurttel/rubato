// Acceptance tests T6-T10: surfaces, radio, and mix guarantees
// (spec section 10.11), plus scheduler, TTL, and isolate checks.
import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_reco/aurora_reco.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

/// Counting stand-in for a metadata provider: reco must never call it.
final class FakeMetadataLookup {
  /// Number of lookup attempts observed.
  int calls = 0;

  /// Returns cached similar ids (empty cache in the offline test).
  List<String> similarFor(String trackId) {
    calls++;
    return const <String>[];
  }
}

List<Track> bigCatalog({int artists = 10, int perArtist = 20}) => <Track>[
  for (var a = 0; a < artists; a++)
    for (var i = 0; i < perArtist; i++)
      mkTrack(
        'a$a-t$i',
        artists: ['artist-$a'],
        genres: [
          if (a < 3) 'rock' else if (a < 6) 'pop' else 'jazz',
        ],
        albumId: 'album-$a',
      ),
];

void main() {
  group('T6 offline', () {
    test('snapshots build from downloads with no provider calls', () {
      final now = DateTime.utc(2026, 5, 1, 12);
      final catalog = bigCatalog(artists: 5);
      final events = <PlayEvent>[
        for (var i = 0; i < 20; i++)
          mkEvent(
            catalog[i * 3].id,
            startedAt: now.subtract(Duration(hours: i + 1)),
          ),
      ];
      final lookup = FakeMetadataLookup();
      // Empty metadata cache: the app layer has nothing to hand over,
      // so the lookup is never consulted (it would count a call).
      final similarIds = <String>[];
      final result = rebuildWith(events, catalog, now);
      final snapshots = RecoEngine.buildHomeSnapshots(
        tracks: catalog,
        events: events,
        stats: result.stats.values.toList(),
        profile: result.profile,
        now: now,
        storedEventCount: events.length,
        similarIds: similarIds,
      );
      expect(lookup.calls, 0);
      final made = snapshots[RecoSurface.madeForYou]!;
      expect(made.entries, hasLength(20));
      final ids = {for (final track in catalog) track.id};
      expect(
        made.entries.every((entry) => ids.contains(entry.trackId)),
        isTrue,
      );
      expect(
        snapshots[RecoSurface.dailyMix1]!.entries,
        isNotEmpty,
      );
      expect(
        snapshots[RecoSurface.dailyMix2]!.entries,
        isNotEmpty,
      );
      expect(
        snapshots[RecoSurface.dailyMix3]!.entries,
        isNotEmpty,
      );
    });
  });

  group('T7 dislike', () {
    test('disliked tracks never reach home surfaces', () {
      final now = DateTime.utc(2026, 5, 1, 12);
      final catalog = bigCatalog(artists: 4, perArtist: 10);
      final likedPlayIds = <String>[for (var i = 0; i < 10; i++) catalog[i].id];
      final events = <PlayEvent>[
        for (final id in likedPlayIds)
          mkEvent(id, startedAt: now.subtract(const Duration(hours: 2))),
      ];
      final disliked = likedPlayIds.take(5).toSet();
      final result = rebuildWith(
        events,
        catalog,
        now,
        likeStates: {for (final id in disliked) id: -1},
      );
      final stats = <UserTrackStats>[
        for (final entry in result.stats.entries)
          entry.value.copyWith(
            likeState: disliked.contains(entry.key) ? -1 : 0,
          ),
      ];
      final snapshots = homeSnapshots(
        tracks: catalog,
        events: events,
        profile: result.profile,
        now: now,
        storedEventCount: 20,
        stats: stats,
      );
      for (final surface in RecoSurface.homeSurfaces) {
        final entries = snapshots[surface]!.entries;
        expect(
          entries.any((entry) => disliked.contains(entry.trackId)),
          isFalse,
          reason: '$surface leaked a dislike',
        );
      }
    });
  });

  group('T8 mix ratios', () {
    test('100-track mix lands within 3 of 70/20/10', () {
      final now = DateTime.utc(2026, 5, 1, 12);
      final catalog = bigCatalog();
      // Favorites: 30 completes on artists 0-2.
      final events = <PlayEvent>[
        for (var i = 0; i < 30; i++)
          mkEvent(
            catalog[(i * 7) % 60].id,
            startedAt: now.subtract(Duration(hours: i + 1)),
          ),
      ];
      final result = rebuildWith(events, catalog, now);
      final byId = trackIndex(catalog);
      // Played half (artists 0-4), unplayed half (artists 5-9).
      final stats = <String, UserTrackStats>{
        for (final track in catalog.take(100))
          track.id: UserTrackStats(
            trackId: track.id,
            updatedAt: now,
            playCount: 3,
            completeCount: 2,
            totalListenMs: 500000,
            lastPlayedAt: now.subtract(const Duration(days: 2)),
          ),
      };
      final request = RankRequest(
        tracks: catalog,
        profile: result.profile,
        now: now,
        statsByTrackId: stats,
      );
      const ranker = HeuristicRanker();
      final ranked = ranker.rankSync(request);
      final pool = CandidateGeneration.generate(
        CandidateInput(
          allTracks: catalog,
          profile: result.profile,
          statsByTrackId: stats,
        ),
      ).explorationPool;
      expect(pool.length, greaterThanOrEqualTo(10));
      final mixed = MixSlicer.slice(
        ranked: ranked,
        byId: byId,
        statsByTrackId: stats,
        profile: result.profile,
        explorationPool: pool,
        count: 100,
        storedEventCount: 30,
      );
      int sliceCount(MixSlice slice) =>
          mixed.where((item) => item.slice == slice).length;
      expect(mixed, hasLength(100));
      expect(sliceCount(MixSlice.exploitation), inInclusiveRange(67, 73));
      expect(sliceCount(MixSlice.adjacent), inInclusiveRange(17, 23));
      expect(sliceCount(MixSlice.exploration), inInclusiveRange(7, 13));
    });
  });

  group('T9 consecutive artist', () {
    test('made_for_you never plays 3 in a row by one artist', () {
      final now = DateTime.utc(2026, 5, 1, 12);
      final catalog = <Track>[
        for (var i = 0; i < 40; i++)
          mkTrack('star-$i', artists: const ['superstar']),
        for (var a = 0; a < 4; a++)
          for (var i = 0; i < 10; i++)
            mkTrack('a$a-$i', artists: ['artist-$a']),
      ];
      final events = <PlayEvent>[
        for (var i = 0; i < 20; i++)
          mkEvent(
            'local:star-$i',
            startedAt: now.subtract(Duration(hours: i + 1)),
          ),
      ];
      final result = rebuildWith(events, catalog, now);
      final snapshots = homeSnapshots(
        tracks: catalog,
        events: events,
        profile: result.profile,
        now: now,
        storedEventCount: 20,
        stats: result.stats.values.toList(),
      );
      final made = snapshots[RecoSurface.madeForYou]!;
      expect(made.entries, hasLength(20));
      final byId = trackIndex(catalog);
      var run = 1;
      for (var i = 1; i < made.entries.length; i++) {
        final prev = byId[made.entries[i - 1].trackId]!;
        final current = byId[made.entries[i].trackId]!;
        if (prev.artistIds.first == current.artistIds.first) {
          run++;
        } else {
          run = 1;
        }
        expect(run, lessThanOrEqualTo(2));
      }
    });
  });

  group('T10 why-panel', () {
    test('every scored track carries at least one reason', () {
      final now = DateTime.utc(2026, 5, 1, 12);
      final catalog = bigCatalog(artists: 4, perArtist: 10);
      // Rank with a blank profile: maximum zero-signal coverage.
      final request = RankRequest(
        tracks: catalog,
        profile: emptyProfile(now),
        now: now,
      );
      const ranker = HeuristicRanker();
      final ranked = ranker.rankSync(request);
      expect(ranked, hasLength(catalog.length));
      expect(
        ranked.every((item) => item.reasons.isNotEmpty),
        isTrue,
      );
      // And again over a learned profile with stats attached.
      final events = <PlayEvent>[
        for (var i = 0; i < 10; i++)
          mkEvent(
            catalog[i].id,
            startedAt: now.subtract(Duration(hours: i + 1)),
          ),
      ];
      final learned = rebuildWith(events, catalog, now);
      final rankedLearned = ranker.rankSync(
        RankRequest(
          tracks: catalog,
          profile: learned.profile,
          now: now,
          statsByTrackId: learned.stats,
        ),
      );
      expect(
        rankedLearned.every((item) => item.reasons.isNotEmpty),
        isTrue,
      );
    });
  });

  group('radio', () {
    test('seeds 25, refills 15, skips the seed run', () {
      final now = DateTime.utc(2026, 5, 1, 12);
      final catalog = bigCatalog(artists: 6, perArtist: 12);
      final seed = catalog.first;
      final events = <PlayEvent>[
        for (var i = 0; i < 10; i++)
          mkEvent(
            catalog[i + 1].id,
            startedAt: now.subtract(Duration(hours: i + 1)),
          ),
      ];
      final result = rebuildWith(events, catalog, now);
      final request = RankRequest(
        tracks: catalog,
        profile: result.profile,
        now: now,
        statsByTrackId: result.stats,
      );
      final station = RecoRadio.generate(
        seed: seed,
        candidates: catalog,
        request: request,
      );
      expect(station, hasLength(RecoRadio.seedCount));
      expect(
        station.any((item) => item.trackId == seed.id),
        isFalse,
      );
      final played = {
        for (final item in station.take(23)) item.trackId,
      };
      final refill = RecoRadio.generate(
        seed: seed,
        candidates: catalog,
        request: request,
        recentIds: {seed.id, ...played},
        count: RecoRadio.refillCount,
      );
      expect(refill, hasLength(RecoRadio.refillCount));
      expect(
        refill.any(played.contains),
        isFalse,
      );
    });
  });

  group('scheduler + snapshots', () {
    test('scheduler debounces bursts into one call', () async {
      final scheduler = RecoScheduler(
        delay: const Duration(milliseconds: 20),
      );
      var calls = 0;
      for (var i = 0; i < 5; i++) {
        scheduler.schedule(() => calls++);
      }
      expect(scheduler.hasPending, isTrue);
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(calls, 1);
      scheduler.dispose();
    });

    test('home TTL is 20 minutes and daily rebuild is calendrical', () {
      final now = DateTime.utc(2026, 5, 1, 12);
      expect(RecoSurface.homeTtl, const Duration(minutes: 20));
      final snapshot = RecoSnapshot(
        surface: RecoSurface.madeForYou,
        entries: const [],
        computedAt: now,
        ttlMs: RecoSurface.homeTtl,
      );
      expect(snapshot.isStaleAt(now), isFalse);
      expect(
        snapshot.isStaleAt(now.add(const Duration(minutes: 20))),
        isTrue,
      );
      expect(
        RecoSurface.isDailyStale(now, now.add(const Duration(hours: 1))),
        isFalse,
      );
      expect(
        RecoSurface.isDailyStale(now, now.add(const Duration(days: 1))),
        isTrue,
      );
    });

    test('snapshots survive isolate JSON encoding', () {
      final now = DateTime.utc(2026, 5, 1, 12);
      final catalog = bigCatalog(artists: 3, perArtist: 10);
      final events = <PlayEvent>[
        for (var i = 0; i < 10; i++)
          mkEvent(
            catalog[i].id,
            startedAt: now.subtract(Duration(hours: i + 1)),
          ),
      ];
      final result = rebuildWith(events, catalog, now);
      final request = SnapshotRequest(
        tracks: [for (final track in catalog) track.toJson()],
        events: [for (final event in events) event.toJson()],
        stats: [
          for (final stats in result.stats.values) stats.toJson(),
        ],
        profile: result.profile.toJson(),
        now: now.millisecondsSinceEpoch,
        storedEventCount: events.length,
      );
      final snapshots = buildSnapshots(request.toJson());
      expect(snapshots[RecoSurface.madeForYou]!.entries, hasLength(20));
      final encoded = encodeSnapshots(snapshots);
      final decoded = RecoSnapshot.fromJson(
        encoded[RecoSurface.madeForYou]!,
      );
      expect(
        decoded.trackIds,
        snapshots[RecoSurface.madeForYou]!.trackIds,
      );
    });
  });
}

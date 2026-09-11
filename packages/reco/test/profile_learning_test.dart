// Acceptance tests T1-T5: profile learning (spec section 10.11).
//
// Frozen `FakeClock` throughout; each test rebuilds a profile from
// arranged events and asserts the learning behavior end to end.
import 'dart:math' as math;

import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_reco/aurora_reco.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  group('T1 skip metal', () {
    late List<Track> catalog;
    late DateTime now;

    setUp(() {
      now = DateTime.utc(2026, 5, 1, 12);
      catalog = <Track>[
        for (var i = 0; i < 30; i++)
          mkTrack(
            'metal-$i',
            artists: ['metal-${i % 3}'],
            genres: const ['metal'],
          ),
        for (var i = 0; i < 30; i++)
          mkTrack(
            'pop-$i',
            artists: ['pop-${i % 3}'],
            genres: const ['pop'],
          ),
      ];
    });

    List<PlayEvent> popBaseline() => <PlayEvent>[
      for (var i = 0; i < 4; i++)
        mkEvent(
          'local:pop-$i',
          startedAt: now.subtract(Duration(hours: i + 1)),
        ),
    ];

    test('skips weigh far less than completes', () {
      final base = rebuildWith(popBaseline(), catalog, now);
      final skipEvents = <PlayEvent>[
        ...popBaseline(),
        for (var i = 0; i < 8; i++)
          mkSkip(
            'local:metal-$i',
            startedAt: now.subtract(Duration(hours: i + 5)),
          ),
      ];
      final completeEvents = <PlayEvent>[
        ...popBaseline(),
        for (var i = 0; i < 8; i++)
          mkEvent(
            'local:metal-$i',
            startedAt: now.subtract(Duration(hours: i + 5)),
          ),
      ];
      final skipped = rebuildWith(skipEvents, catalog, now).profile;
      final completed = rebuildWith(completeEvents, catalog, now).profile;
      expect(base.profile.genreWeights['metal'] ?? 0, 0);
      final skipMetal = skipped.genreWeights['metal'] ?? 0;
      final completeMetal = completed.genreWeights['metal'] ?? 0;
      expect(skipMetal, lessThan(completeMetal));
    });

    test('daily mix metal share falls by half or more', () {
      final completeEvents = <PlayEvent>[
        ...popBaseline(),
        for (var i = 0; i < 8; i++)
          mkEvent(
            'local:metal-$i',
            startedAt: now.subtract(Duration(hours: i + 5)),
          ),
      ];
      final skipEvents = <PlayEvent>[
        ...popBaseline(),
        for (var i = 0; i < 8; i++)
          mkSkip(
            'local:metal-$i',
            startedAt: now.subtract(Duration(hours: i + 5)),
          ),
      ];
      final baseline = rebuildWith(completeEvents, catalog, now);
      final skipped = rebuildWith(skipEvents, catalog, now);
      final baseMix = homeSnapshots(
        tracks: catalog,
        events: completeEvents,
        profile: baseline.profile,
        now: now,
        storedEventCount: completeEvents.length,
      )[RecoSurface.dailyMix2]!;
      final skipMix = homeSnapshots(
        tracks: catalog,
        events: skipEvents,
        profile: skipped.profile,
        now: now,
        storedEventCount: skipEvents.length,
      )[RecoSurface.dailyMix2]!;
      final baseShare = genreShare(baseMix, 'metal', catalog);
      final skipShare = genreShare(skipMix, 'metal', catalog);
      expect(baseShare, greaterThan(0.5));
      expect(skipShare, lessThanOrEqualTo(baseShare * 0.5));
    });
  });

  group('T2 ambient complete', () {
    test('ambient tops and adjacent electronic rises', () {
      final now = DateTime.utc(2026, 5, 1, 12);
      final catalog = <Track>[
        for (var i = 0; i < 10; i++)
          mkTrack(
            'amb-$i',
            artists: ['ambient-artist'],
            genres: i < 6 ? const ['ambient', 'electronic'] : const ['ambient'],
          ),
        for (var i = 0; i < 10; i++)
          mkTrack('rock-$i', artists: ['rock-artist']),
      ];
      final events = <PlayEvent>[
        for (var i = 0; i < 10; i++)
          mkEvent(
            'local:amb-$i',
            startedAt: now.subtract(Duration(hours: i + 1)),
          ),
      ];
      final result = rebuildWith(events, catalog, now);
      expect(result.profile.genreWeights['ambient'], 1.0);
      final electronic = result.profile.genreWeights['electronic'] ?? 0;
      expect(electronic, greaterThan(0.3));
      final topGenres = result.profile.genreWeights.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      expect(
        topGenres.take(3).map((entry) => entry.key),
        contains('electronic'),
      );
    });
  });

  group('T3 jazz shock', () {
    test('recent intent flips while long-term artists hold', () {
      final now = DateTime.utc(2026, 5, 1, 12);
      final catalog = <Track>[
        for (var i = 0; i < 30; i++)
          mkTrack(
            'metal-$i',
            artists: ['metal-${i % 3}'],
            genres: const ['metal'],
          ),
        for (var i = 0; i < 5; i++)
          mkTrack(
            'jazz-$i',
            artists: ['jazz-new'],
            genres: const ['jazz'],
          ),
      ];
      final history = <PlayEvent>[
        // Long metal history, all outside the 7-day window.
        for (var i = 0; i < 60; i++)
          mkEvent(
            'local:metal-${i % 30}',
            startedAt: now.subtract(Duration(days: 8 + (i % 50))),
          ),
        // Sudden jazz week.
        for (var i = 0; i < 5; i++)
          mkEvent(
            'local:jazz-$i',
            startedAt: now.subtract(Duration(days: 2 - (i % 2))),
          ),
      ];
      final result = rebuildWith(history, catalog, now);
      expect(result.profile.recentIntent['jazz'], 1.0);
      final topArtists = result.profile.artistWeights.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final top3 = topArtists.take(3).map((entry) => entry.key);
      expect(top3.every((artist) => artist.startsWith('metal-')), isTrue);
    });
  });

  group('T4 night context', () {
    test('night artist wins at night, loses in the morning', () {
      final now = DateTime.utc(2026, 5, 1, 12);
      final trackX = mkTrack('x', artists: const ['artist-x']);
      final trackY = mkTrack('y', artists: const ['artist-y']);
      final catalog = [trackX, trackY];
      final events = <PlayEvent>[
        for (var i = 0; i < 5; i++)
          mkEvent(
            'local:x',
            startedAt: now.subtract(Duration(days: 1, hours: i)),
            bucket: TimeOfDayBucket.night,
          ),
        for (var i = 0; i < 5; i++)
          mkEvent(
            'local:y',
            startedAt: now.subtract(Duration(days: 1, hours: i)),
            bucket: TimeOfDayBucket.morning,
          ),
      ];
      final result = rebuildWith(events, catalog, now);
      const ranker = HeuristicRanker();
      RankRequest requestFor(TimeOfDayBucket bucket) => RankRequest(
        tracks: catalog,
        profile: result.profile,
        now: now,
        bucket: bucket,
      );
      final night = ranker.rankSync(
        requestFor(TimeOfDayBucket.night),
      );
      final morning = ranker.rankSync(
        requestFor(TimeOfDayBucket.morning),
      );
      String top(List<ScoredTrack> ranked) => ranked.first.trackId;
      expect(top(night), 'local:x');
      expect(top(morning), 'local:y');
    });
  });

  group('T5 decay', () {
    test('50-day-old event keeps about half of a 1-day-old one', () {
      final now = DateTime.utc(2026, 5, 1, 12);
      expect(
        RecoDecay.decay(const Duration(days: 50), 45),
        closeTo(math.pow(0.5, 50 / 45).toDouble(), 1e-9),
      );
      final profile = emptyProfile(now);
      PlayEvent eventAt(Duration age) => mkEvent(
        'local:t',
        startedAt: now.subtract(age),
      );
      final oldWeight = FeatureExtraction.eventWeight(
        EventFeatures(
          event: eventAt(const Duration(days: 50)),
          artistIds: const ['a'],
          genreIds: const ['g'],
        ),
        now,
        profile,
      );
      final freshWeight = FeatureExtraction.eventWeight(
        EventFeatures(
          event: eventAt(const Duration(days: 1)),
          artistIds: const ['a'],
          genreIds: const ['g'],
        ),
        now,
        profile,
      );
      expect(
        oldWeight / freshWeight,
        closeTo(math.pow(0.5, 50 / 45).toDouble(), 0.02),
      );
    });
  });

  group('profile store', () {
    test('preference profile survives a JSON round trip', () {
      final now = DateTime.utc(2026, 5, 1, 12);
      final catalog = <Track>[mkTrack('a'), mkTrack('b')];
      final events = <PlayEvent>[
        mkEvent('local:a', startedAt: now.subtract(const Duration(hours: 2))),
        mkSkip('local:b', startedAt: now.subtract(const Duration(hours: 1))),
      ];
      final result = rebuildWith(events, catalog, now);
      final restored = PreferenceProfile.fromJson(result.profile.toJson());
      expect(restored.artistWeights, result.profile.artistWeights);
      expect(restored.genreWeights, result.profile.genreWeights);
      expect(restored.timeContext, result.profile.timeContext);
      expect(restored.recentIntent, result.profile.recentIntent);
      expect(restored.ratesValid, isTrue);
    });
  });
}

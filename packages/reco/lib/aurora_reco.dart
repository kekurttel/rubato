/// Aurora on-device recommendation engine (spec section 10).
///
/// Pure Dart: reads only in-memory domain models (never the network).
/// The app layer pages `PlayEvent`s from Drift, calls `RecoEngine`,
/// and persists snapshots back through `RecoSnapshotDao`. All time
/// reads flow through a `Clock` so tests freeze time with `FakeClock`.
library;

export 'src/candidates.dart';
export 'src/decay.dart';
export 'src/diversity.dart';
export 'src/engine.dart';
export 'src/feature_extraction.dart';
export 'src/heuristic_ranker.dart';
export 'src/isolate_runner.dart';
export 'src/mix.dart';
export 'src/radio.dart';
export 'src/ranker.dart';
export 'src/scheduler.dart';
export 'src/score.dart';
export 'src/surfaces.dart';
export 'src/vector.dart';

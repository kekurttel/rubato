/// Aurora core: pure-Dart foundation for every package.
///
/// Exports the `Result` type, typed errors, the injectable `Clock`,
/// uuid-v7 id helpers, the local-only logger, privacy guards, settings
/// defaults, and all freezed domain models (spec section 5).
library;

export 'src/clock.dart';
export 'src/constants.dart';
export 'src/errors.dart';
export 'src/ids.dart';
export 'src/logger.dart';
export 'src/models/album.dart';
export 'src/models/artist.dart';
export 'src/models/artwork.dart';
export 'src/models/download_job.dart';
export 'src/models/enums.dart';
export 'src/models/media_handle.dart';
export 'src/models/play_event.dart';
export 'src/models/playlist.dart';
export 'src/models/playlist_entry.dart';
export 'src/models/preference_profile.dart';
export 'src/models/queue_item.dart';
export 'src/models/search.dart';
export 'src/models/track.dart';
export 'src/models/user_track_stats.dart';
export 'src/privacy.dart';
export 'src/result.dart';

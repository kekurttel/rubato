/// yt-dlp online music provider (spec section 7, lawful-use only).
///
/// All online access goes through the yt-dlp CLI with audio-only flags
/// (`--extract-audio`, `--no-playlist` by default). No video downloads,
/// no DRM bypass, no private API clients, no bundled copyrighted URLs.
/// On Android without a CLI binary, search/stream/download prefer the
/// NewPipe Extractor bridge with the pure-Dart explode client as
/// fallback.
library;

export 'src/explode_client.dart';
export 'src/invidious_search.dart';
export 'src/newpipe_bridge.dart';
export 'src/piped_search.dart';
export 'src/piped_streams.dart';
export 'src/process_runner.dart';
export 'src/stream_resolver.dart';
export 'src/ytdlp_binary.dart';
export 'src/ytdlp_downloader.dart';
export 'src/ytdlp_provider.dart';
export 'src/ytdlp_quality.dart';
export 'src/ytdlp_search.dart';
export 'src/ytdlp_version.dart';
export 'src/ytmusic_account_client.dart';

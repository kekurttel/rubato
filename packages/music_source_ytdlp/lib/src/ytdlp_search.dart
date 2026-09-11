import 'dart:async';
import 'dart:convert';

import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_music_source_ytdlp/src/process_runner.dart';
import 'package:aurora_music_source_ytdlp/src/ytdlp_binary.dart';

/// Provider id used for every ytdlp-backed entity id.
const String ytdlpProviderId = 'ytdlp';

/// Parsed outcome of one `--dump-json` search dump (pure data).
final class YtdlpSearchResult {
  /// Creates a parsed result.
  const YtdlpSearchResult({
    required this.tracks,
    required this.artists,
    required this.artworkByVideoId,
    required this.skipped,
  });

  /// Mapped tracks in dump order.
  final List<Track> tracks;

  /// Distinct uploaders in first-seen order.
  final List<Artist> artists;

  /// Highest-resolution thumbnail per video id (for `artwork()`).
  final Map<String, String> artworkByVideoId;

  /// Dump lines skipped (missing id / malformed JSON).
  final int skipped;
}

/// Audio-only search over `ytsearchN` + `--flat-playlist --dump-json`.
///
/// Lawful-use: the query is always user-typed text (never a bundled
/// URL list); `--no-playlist` is forced so a bare watch URL cannot pull
/// a whole playlist. Each dump line maps to a [Track] with
/// `providerId=ytdlp` and `sourceTrackId=<videoId>`.
final class YtdlpSearch {
  /// Creates a search over [binary] + [runner].
  YtdlpSearch({
    YtdlpBinary? binary,
    YtdlpProcessRunner? runner,
    this.clock = const SystemClock(),
    this.maxResults = 20,
  }) : binary = binary ?? YtdlpBinary(),
       _runner = runner ?? const SystemProcessRunner();

  /// Binary locator.
  final YtdlpBinary binary;

  /// Injectable clock for `fetchedAt` / entity timestamps.
  final Clock clock;

  /// Hard cap for the `ytsearchN` count (1..50).
  final int maxResults;

  final YtdlpProcessRunner _runner;

  /// Highest-resolution thumbnail per video id seen so far.
  ///
  /// The provider consults this for `artwork()` without an extra fetch;
  /// unknown ids report `notFound` instead of scraping.
  final Map<String, String> artworkByVideoId = <String, String>{};

  /// Searches for [query] (min 2 chars, enforced like every provider).
  Future<Result<SearchPage, AppError>> search(SearchQuery query) async {
    final text = query.text.trim();
    if (text.length < 2) {
      return const Failure(
        AppError(
          code: AppErrorCode.provider,
          message: 'Online search needs at least 2 characters',
          details: 'ytdlp:query-too-short',
        ),
      );
    }
    final resolved = await binary.resolve();
    if (resolved == null) {
      return const Failure(
        AppError(
          code: AppErrorCode.provider,
          message: 'yt-dlp binary not found (install it or set a path)',
          details: 'ytdlp:missing-binary',
        ),
      );
    }
    final count = query.limit.clamp(1, maxResults);
    final args = <String>[
      'ytsearch$count:$text',
      '--flat-playlist',
      '--dump-json',
      '--no-playlist',
      '--no-warnings',
    ];
    late final YtdlpProcessResult dump;
    try {
      dump = await _runner.run(resolved, args);
    } on TimeoutException catch (error) {
      return Failure(
        AppError(
          code: AppErrorCode.network,
          message: 'Online search timed out',
          details: 'ytdlp:search-timeout',
          cause: error,
        ),
      );
    } on Object catch (error) {
      // `on Object` (not `on Exception`): process-launch Errors must
      // stay a typed Failure so the provider chain (Piped → NewPipe →
      // CLI) survives them instead of escaping as a raw throw.
      return Failure(
        AppError(
          code: AppErrorCode.io,
          message: 'Could not launch the yt-dlp binary',
          details: 'ytdlp:launch',
          cause: error,
        ),
      );
    }
    if (!dump.isSuccess) {
      return Failure(
        AppError(
          code: AppErrorCode.network,
          message: 'Online search failed (exit ${dump.exitCode})',
          details: 'ytdlp:search-exit',
        ),
      );
    }
    final parsed = parseLines(
      const LineSplitter().convert(dump.stdout),
      clock.nowUtc(),
      limit: query.limit,
      wantTracks: query.types.contains(SearchType.track),
      wantArtists: query.types.contains(SearchType.artist),
    );
    artworkByVideoId.addAll(parsed.artworkByVideoId);
    return Success(
      SearchPage(
        providerId: ytdlpProviderId,
        fetchedAt: clock.nowUtc(),
        tracks: parsed.tracks,
        artists: parsed.artists,
        // Flat search has no album grouping; the Albums tab stays
        // local-only in v1 (SearchPage.albums defaults to empty).
      ),
    );
  }

  /// Parses raw `--dump-json` lines (pure, no I/O — unit-test seam).
  static YtdlpSearchResult parseLines(
    Iterable<String> lines,
    DateTime now, {
    int limit = 20,
    bool wantTracks = true,
    bool wantArtists = true,
  }) {
    final tracks = <Track>[];
    final artists = <Artist>[];
    final seenArtists = <String>{};
    final artwork = <String, String>{};
    var skipped = 0;
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        continue;
      }
      late final Map<String, Object?> entry;
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is! Map<String, Object?>) {
          skipped++;
          continue;
        }
        entry = decoded;
      } on FormatException {
        skipped++;
        continue;
      }
      final track = trackFromEntry(entry, now);
      if (track == null) {
        skipped++;
        continue;
      }
      final thumb = bestThumbnail(entry['thumbnails']);
      if (thumb != null) {
        artwork[track.sourceTrackId] = thumb;
      }
      if (wantTracks && tracks.length < limit) {
        tracks.add(track);
      }
      if (wantArtists && artists.length < limit) {
        final artist = artistFromEntry(entry);
        if (artist != null && seenArtists.add(artist.sourceId)) {
          artists.add(artist);
        }
      }
      if (tracks.length >= limit && artists.length >= limit) {
        break;
      }
    }
    return YtdlpSearchResult(
      tracks: tracks,
      artists: artists,
      artworkByVideoId: artwork,
      skipped: skipped,
    );
  }

  /// Maps one dump entry to a [Track] (null when the id is missing).
  static Track? trackFromEntry(Map<String, Object?> entry, DateTime now) {
    final videoId = entry['id'];
    if (videoId is! String || videoId.isEmpty) {
      return null;
    }
    final rawTitle = entry['title'];
    final title = rawTitle is String && rawTitle.trim().isNotEmpty
        ? rawTitle.trim()
        : 'Untitled';
    final duration = entry['duration'];
    final durationMs = duration is num
        ? (duration.toDouble() * 1000).round()
        : 0;
    final artist = artistFromEntry(entry);
    return Track(
      id: AuroraIds.trackId(ytdlpProviderId, videoId),
      providerId: ytdlpProviderId,
      sourceTrackId: videoId,
      title: title,
      createdAt: now,
      updatedAt: now,
      durationMs: durationMs,
      artistIds: artist == null ? const <String>[] : <String>[artist.id],
    );
  }

  /// Derives the uploader as an [Artist] (null when unnamed).
  static Artist? artistFromEntry(Map<String, Object?> entry) {
    final channelId = entry['channel_id'];
    final channel = entry['channel'];
    final uploader = entry['uploader'];
    final name = channel is String && channel.trim().isNotEmpty
        ? channel.trim()
        : (uploader is String && uploader.trim().isNotEmpty
              ? uploader.trim()
              : null);
    if (name == null) {
      return null;
    }
    final key = channelId is String && channelId.isNotEmpty
        ? channelId
        : _slug(name);
    final sourceId = 'channel-$key';
    return Artist(
      id: AuroraIds.trackId(ytdlpProviderId, sourceId),
      name: name,
      sourceId: sourceId,
      providerId: ytdlpProviderId,
    );
  }

  /// Picks the highest-resolution thumbnail URL, if any.
  static String? bestThumbnail(Object? thumbnails) {
    if (thumbnails is! List<Object?>) {
      return null;
    }
    String? bestUrl;
    var bestPixels = -1;
    for (final item in thumbnails) {
      if (item is! Map<String, Object?>) {
        continue;
      }
      final url = item['url'];
      if (url is! String || url.isEmpty) {
        continue;
      }
      final width = item['width'];
      final height = item['height'];
      final pixels = width is num && height is num
          ? (width.toInt() * height.toInt())
          : 0;
      if (pixels >= bestPixels) {
        bestPixels = pixels;
        bestUrl = url;
      }
    }
    return bestUrl;
  }

  static String _slug(String raw) {
    final slug = raw
        .toLowerCase()
        .replaceAll(RegExp('[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return slug.isEmpty ? 'unknown' : slug;
  }
}

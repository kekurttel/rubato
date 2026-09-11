// NewPipeExtractor is GPL-3.0 licensed (https://github.com/TeamNewPipe/NewPipeExtractor).
package aurora.player

import android.app.Activity
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import org.schabi.newpipe.extractor.NewPipe
import org.schabi.newpipe.extractor.ServiceList
import org.schabi.newpipe.extractor.downloader.Downloader
import org.schabi.newpipe.extractor.downloader.Request
import org.schabi.newpipe.extractor.downloader.Response
import org.schabi.newpipe.extractor.stream.AudioStream
import org.schabi.newpipe.extractor.stream.StreamInfoItem
import org.schabi.newpipe.extractor.stream.StreamType
import java.net.HttpURLConnection
import java.net.URL

/// YouTube search + audio-only stream URLs over NewPipe Extractor.
///
/// Device-proven need: `youtube_explode_dart` manifests resolve
/// googlevideo URLs that return HTTP 403 on the phone (bot-gated
/// player responses), while search metadata works. The extractor runs
/// fully on-device (Java, no binary); every method runs off the main
/// thread and replies on the UI thread, and every call is wrapped in
/// try/catch so failures surface as `result.error`, never a crash.
object YoutubeBridge {
    /// Registers `aurora.player/youtube` on [messenger].
    fun setup(activity: Activity, messenger: BinaryMessenger) {
        MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                METHOD_SEARCH -> {
                    val query = call.argument<String>("query").orEmpty()
                    val limit = call.argument<Number>("limit")?.toInt() ?: 10
                    Thread {
                        try {
                            val hits = search(query, limit)
                            activity.runOnUiThread { result.success(hits) }
                        } catch (e: Exception) {
                            val message = e.message
                            activity.runOnUiThread {
                                result.error("YOUTUBE_BRIDGE_ERROR", message, null)
                            }
                        }
                    }.start()
                }
                METHOD_AUDIO_URL -> {
                    val videoId = call.argument<String>("videoId").orEmpty()
                    val cap = call.argument<Number>("maxBitrateKbps")?.toInt() ?: 0
                    val preferMp4 = call.argument<Boolean>("preferMp4") ?: false
                    Thread {
                        try {
                            val audio = audioUrl(videoId, cap, preferMp4)
                            activity.runOnUiThread { result.success(audio) }
                        } catch (e: Exception) {
                            val message = e.message
                            activity.runOnUiThread {
                                result.error("YOUTUBE_BRIDGE_ERROR", message, null)
                            }
                        }
                    }.start()
                }
                METHOD_PLAYLIST -> {
                    val url = call.argument<String>("url").orEmpty()
                    Thread {
                        try {
                            val data = playlist(url)
                            activity.runOnUiThread { result.success(data) }
                        } catch (e: Exception) {
                            val message = e.message
                            activity.runOnUiThread {
                                result.error("YOUTUBE_BRIDGE_ERROR", message, null)
                            }
                        }
                    }.start()
                }
                METHOD_SET_ACCOUNT_COOKIES -> {
                    val raw = call.argument<Map<String, Any>>("cookies")
                    accountCookies =
                        raw?.mapNotNull { (key, value) ->
                            if (value is String && value.isNotEmpty()) {
                                key to value
                            } else {
                                null
                            }
                        }?.toMap() ?: emptyMap()
                    Log.d("AURORA_DIAG", "bridge account cookies set count=${accountCookies.size}")
                    result.success(null)
                }
                METHOD_CLEAR_ACCOUNT_COOKIES -> {
                    accountCookies = emptyMap()
                    Log.d("AURORA_DIAG", "bridge account cookies cleared")
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    /// Searches YouTube for [query], returning at most [limit] hits as
    /// maps of `videoId/title/uploader/channelId/durationSec/thumbnailUrl`.
    ///
    /// Only [StreamInfoItem] entries are kept; live streams are skipped
    /// and unknown durations are reported as `0`. The thumbnail is the
    /// highest-resolution one available.
    private fun search(query: String, limit: Int): List<Map<String, Any?>> {
        if (query.isBlank() || limit <= 0) return emptyList()
        ensureInit()
        val service = ServiceList.YouTube
        val extractor = service.getSearchExtractor(query)
        extractor.fetchPage()
        val streamLH = service.streamLHFactory
        val channelLH = service.channelLHFactory
        val out = mutableListOf<Map<String, Any?>>()
        for (item in extractor.initialPage.items) {
            if (out.size >= limit) break
            if (item !is StreamInfoItem) continue
            if (item.streamType == StreamType.LIVE_STREAM) continue
            val videoId = try {
                streamLH.getId(item.url)
            } catch (e: Exception) {
                continue
            }
            if (videoId.isNullOrBlank()) continue
            val durationSec = item.duration
            val channelId = try {
                channelLH.getId(item.uploaderUrl)
            } catch (e: Exception) {
                ""
            }.orEmpty()
            out.add(
                mapOf(
                    "videoId" to videoId,
                    "title" to (item.name ?: ""),
                    "uploader" to (item.uploaderName ?: ""),
                    "channelId" to channelId,
                    "durationSec" to if (durationSec > 0) durationSec else 0,
                    "thumbnailUrl" to bestThumbnail(item),
                ),
            )
        }
        return out
    }

    /// Resolves the best audio-only stream URL for [videoId] as a map
    /// of `url/bitrateKbps/ext`, or null when none exists.
    ///
    /// Picks the highest average bitrate at or under [maxBitrateKbps]
    /// (`<= 0` means uncapped), falling back to the lowest stream when
    /// nothing fits. Unknown-bitrate (`-1`) streams are skipped unless
    /// nothing else exists. Only audio streams are ever considered —
    /// never video or muxed ones. With [preferMp4], m4a/mp4 streams
    /// win (downloads land as `.m4a`, which MediaStore files as audio
    /// instead of the gallery's video collection).
    private fun audioUrl(
        videoId: String,
        maxBitrateKbps: Int,
        preferMp4: Boolean = false,
    ): Map<String, Any?>? {
        if (videoId.isBlank()) return null
        Log.d("AURORA_DIAG", "bridge audioUrl req vid=$videoId cap=$maxBitrateKbps")
        ensureInit()
        val service = ServiceList.YouTube
        val extractor = service.getStreamExtractor(
            "https://www.youtube.com/watch?v=$videoId",
        )
        try {
            extractor.fetchPage()
        } catch (e: Exception) {
            Log.d("AURORA_DIAG", "bridge fetchPage fail vid=$videoId err=${e.message?.take(150)}")
            throw e
        }
        val streams = extractor.audioStreams
        Log.d("AURORA_DIAG", "bridge streams vid=$videoId count=${streams?.size ?: -1}")
        if (streams.isNullOrEmpty()) return null
        val mp4Pool =
            if (preferMp4) {
                streams.filter { extOf(it) == "m4a" || extOf(it) == "mp4" }
            } else {
                emptyList()
            }
        val ranked = if (mp4Pool.isNotEmpty()) mp4Pool else streams
        val known = ranked
            .filter { it.averageBitrate > 0 }
            .sortedBy { it.averageBitrate }
        val pick = if (known.isNotEmpty()) {
            if (maxBitrateKbps <= 0) {
                known.last()
            } else {
                known.lastOrNull { kbpsOf(it) <= maxBitrateKbps } ?: known.first()
            }
        } else {
            ranked.firstOrNull() ?: return null
        }
        val url = pick.content
        if (url.isNullOrEmpty()) return null
        try {
            val host = java.net.URL(url).host
            Log.d("AURORA_DIAG", "bridge pick vid=$videoId host=$host kbps=${kbpsOf(pick)} ext=${extOf(pick)} len=${url.length}")
        } catch (e: Exception) {
            Log.d("AURORA_DIAG", "bridge pick vid=$videoId len=${url.length}")
        }
        return mapOf(
            "url" to url,
            "bitrateKbps" to kbpsOf(pick),
            "ext" to extOf(pick),
        )
    }

    /// Extracts playlist metadata and items for [rawUrl] (or playlist ID).
    ///
    /// Returns `mapOf("title" to name, "items" to items)`.
    private fun playlist(rawUrl: String): Map<String, Any?>? {
        val trimmed = rawUrl.trim()
        if (trimmed.isBlank()) return null
        ensureInit()
        val fullUrl = if (trimmed.startsWith("http://") || trimmed.startsWith("https://")) {
            trimmed
        } else {
            "https://www.youtube.com/playlist?list=$trimmed"
        }
        val service = ServiceList.YouTube
        val extractor = service.getPlaylistExtractor(fullUrl)
        extractor.fetchPage()
        val streamLH = service.streamLHFactory
        val channelLH = service.channelLHFactory
        val name = try {
            extractor.name
        } catch (e: Exception) {
            null
        }?.takeIf { it.isNotBlank() } ?: "YouTube Playlist"
        val items = mutableListOf<Map<String, Any?>>()
        val page = try {
            extractor.initialPage
        } catch (e: Exception) {
            null
        }
        if (page != null) {
            for (item in page.items) {
                if (item !is StreamInfoItem) continue
                if (item.streamType == StreamType.LIVE_STREAM) continue
                val videoId = try {
                    streamLH.getId(item.url)
                } catch (e: Exception) {
                    continue
                }
                if (videoId.isNullOrBlank()) continue
                val durationSec = item.duration
                val channelId = try {
                    channelLH.getId(item.uploaderUrl)
                } catch (e: Exception) {
                    ""
                }.orEmpty()
                items.add(
                    mapOf(
                        "videoId" to videoId,
                        "title" to (item.name ?: ""),
                        "uploader" to (item.uploaderName ?: ""),
                        "channelId" to channelId,
                        "durationSec" to if (durationSec > 0) durationSec else 0,
                        "thumbnailUrl" to bestThumbnail(item),
                    ),
                )
            }
        }
        return mapOf(
            "title" to name,
            "items" to items,
        )
    }

    /// Highest-resolution thumbnail URL for [item] ("" when none).
    private fun bestThumbnail(item: StreamInfoItem): String {
        val thumbs = item.thumbnails
        if (thumbs.isNullOrEmpty()) return ""
        val best = thumbs.maxByOrNull { image ->
            val h = image.height
            val w = image.width
            if (h > 0 && w > 0) h.toLong() * w else -1L
        }
        return best?.url.orEmpty()
    }

    /// Average bitrate in kbps (YouTube reports bps, which dwarfs any
    /// real kbps value, so divide those down; 0 when unknown).
    private fun kbpsOf(stream: AudioStream): Int {
        val raw = stream.averageBitrate
        if (raw <= 0) return 0
        return if (raw >= 10000) raw / 1000 else raw
    }

    /// Container suffix for [stream] (`m4a`, `webm`, ...).
    private fun extOf(stream: AudioStream): String {
        val suffix = try {
            stream.format?.suffix
        } catch (e: Exception) {
            null
        }
        return if (suffix.isNullOrBlank()) "m4a" else suffix
    }

    @Volatile
    private var initialized = false

    /// Calls `NewPipe.init` once (thread-safe).
    private fun ensureInit() {
        if (initialized) return
        synchronized(this) {
            if (!initialized) {
                NewPipe.init(UrlConnectionDownloader())
                initialized = true
            }
        }
    }

    /// User session cookies for authenticated YouTube requests
    /// (pushed from Dart after WebView login; empty = signed out).
    @Volatile
    private var accountCookies: Map<String, String> = emptyMap()

    /// SHA-1 hex for the InnerTube `SAPISIDHASH` authorization scheme.
    private fun sha1Hex(input: String): String {
        val digest = java.security.MessageDigest.getInstance("SHA-1")
        val bytes = digest.digest(input.toByteArray(Charsets.UTF_8))
        return bytes.joinToString("") { "%02x".format(it) }
    }

    /// Minimal `Downloader` over `HttpURLConnection` (no OkHttp): sends
    /// a browser User-Agent and returns status, headers
    /// (status-line entry dropped), body, and final URL.
    ///
    /// When the user signed in, YouTube/GoogleVideo requests additionally
    /// carry the session `Cookie` header, and InnerTube API calls carry
    /// the `SAPISIDHASH` authorization + music origin — authenticated
    /// player responses are not bot-gated and private feeds resolve.
    private class UrlConnectionDownloader : Downloader() {
        override fun execute(request: Request): Response {
            val method = request.httpMethod() ?: "GET"
            val data = request.dataToSend()
            val connection = (
                URL(request.url()).openConnection() as HttpURLConnection
            ).apply {
                requestMethod = method
                connectTimeout = 15000
                readTimeout = 15000
                instanceFollowRedirects = true
                setRequestProperty("User-Agent", BROWSER_USER_AGENT)
                val headers = request.headers() ?: emptyMap()
                for ((name, values) in headers) {
                    if (name.isNullOrBlank()) continue
                    if (name.equals("User-Agent", ignoreCase = true)) continue
                    setRequestProperty(name, values?.joinToString("; "))
                }
                val sessionCookies = YoutubeBridge.accountCookies
                if (sessionCookies.isNotEmpty()) {
                    val host =
                        try {
                            URL(request.url()).host.lowercase()
                        } catch (e: Exception) {
                            ""
                        }
                    val ytHost =
                        host == "youtube.com" || host.endsWith(".youtube.com") ||
                            host == "googlevideo.com" ||
                            host.endsWith(".googlevideo.com") ||
                            host == "youtubei.googleapis.com"
                    if (ytHost) {
                        val cookieHeader =
                            sessionCookies.entries.joinToString("; ") {
                                "${it.key}=${it.value}"
                            }
                        setRequestProperty("Cookie", cookieHeader)
                        if (host == "youtubei.googleapis.com") {
                            val sapisid = sessionCookies["SAPISID"]
                            if (!sapisid.isNullOrEmpty()) {
                                val ts = System.currentTimeMillis() / 1000
                                val hash =
                                    YoutubeBridge.sha1Hex(
                                        "$ts $sapisid https://music.youtube.com",
                                    )
                                setRequestProperty(
                                    "Authorization",
                                    "SAPISIDHASH ${ts}_$hash",
                                )
                                setRequestProperty(
                                    "Origin",
                                    "https://music.youtube.com",
                                )
                            }
                        }
                    }
                }
                if (data != null && data.isNotEmpty()) {
                    doOutput = true
                }
            }
            if (data != null && data.isNotEmpty()) {
                connection.outputStream.use { it.write(data) }
            }
            val code = connection.responseCode
            val message = connection.responseMessage ?: ""
            val headers = connection.headerFields
                .filterKeys { it != null }
                .mapValues { it.value ?: emptyList() }
            val stream =
                if (code in 200..299) connection.inputStream else connection.errorStream
            val body = stream?.bufferedReader(Charsets.UTF_8)?.use { it.readText() } ?: ""
            val latestUrl = connection.url.toString()
            connection.disconnect()
            return Response(code, message, headers, body, latestUrl)
        }
    }

    private const val CHANNEL = "aurora.player/youtube"
    private const val METHOD_SEARCH = "search"
    private const val METHOD_AUDIO_URL = "audioUrl"
    private const val METHOD_PLAYLIST = "playlist"
    private const val METHOD_SET_ACCOUNT_COOKIES = "setAccountCookies"
    private const val METHOD_CLEAR_ACCOUNT_COOKIES = "clearAccountCookies"

    /// Browser User-Agent: YouTube 403s unknown UAs on some networks.
    private const val BROWSER_USER_AGENT =
        "Mozilla/5.0 (Linux; Android 14; Pixel 8 Build/AP2A.240905.003) " +
            "AppleWebKit/537.36 (KHTML, like Gecko) " +
            "Chrome/126.0.0.0 Mobile Safari/537.36"
}

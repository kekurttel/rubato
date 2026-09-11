package aurora.player

import android.Manifest
import android.app.Activity
import android.content.ContentUris
import android.content.Context
import android.content.Intent
import android.database.Cursor
import android.graphics.Bitmap
import android.net.Uri
import android.os.Build
import android.provider.DocumentsContract
import android.provider.MediaStore
import android.provider.OpenableColumns
import android.util.Size
import com.ryanheise.audioservice.AudioServicePlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream

class MainActivity : FlutterActivity() {
    // Single-engine fix: AudioServicePlugin.onAttachedToActivity calls
    // getFlutterEngine() to verify the engine, and that call CREATES a second
    // engine running main() again when the cache is empty. Two mains opened
    // the Drift DB and the image-cache DB concurrently -> SQLITE_BUSY
    // "database is locked" at every cold start. Providing (and caching) the
    // engine up-front makes the plugin reuse it, so main() runs once.
    // Plugin registration is automatic (FlutterEngine constructor).
    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        val id = AudioServicePlugin.getFlutterEngineId()
        FlutterEngineCache.getInstance().get(id)?.let { return it }
        val engine = FlutterEngine(context.applicationContext)
        FlutterEngineCache.getInstance().put(id, engine)
        return engine
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        FlutterEngineCache.getInstance().put(
            AudioServicePlugin.getFlutterEngineId(),
            flutterEngine,
        )
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            MEDIA_STORE_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                METHOD_REQUEST_NOTIFICATIONS -> requestNotificationPermission(result)
                METHOD_QUERY_AUDIO -> {
                    try {
                        result.success(queryAudioFiles())
                    } catch (e: Exception) {
                        result.error("MEDIA_STORE_ERROR", e.message, null)
                    }
                }
                METHOD_ARTWORK_FOR -> {
                    try {
                        val audioId = call.longArg("audioId")
                        val albumId = call.longArg("albumId")
                        if (audioId == null) {
                            result.success(null)
                        } else {
                            result.success(artworkFor(audioId, albumId))
                        }
                    } catch (e: Exception) {
                        result.error("MEDIA_STORE_ERROR", e.message, null)
                    }
                }
                METHOD_READ_AUDIO_BYTES -> {
                    try {
                        val audioId = call.longArg("audioId")
                        if (audioId == null) {
                            result.success(null)
                        } else {
                            val offset =
                                (call.argument<Number>("offset")?.toLong())
                                    ?: 0L
                            val length =
                                (call.argument<Number>("length")?.toInt())
                                    ?: 2097152
                            result.success(
                                readAudioBytes(audioId, offset, length),
                            )
                        }
                    } catch (e: Exception) {
                        result.error("MEDIA_STORE_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
        YoutubeBridge.setup(this, flutterEngine.dartExecutor.binaryMessenger)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            DOWNLOADS_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                METHOD_PICK_FOLDER -> pickFolder(result)
                METHOD_PICK_IMAGE -> pickImage(result)
                METHOD_COPY_TO_TREE -> {
                    val treeUri = call.argument<String>("treeUri").orEmpty()
                    val sourcePath =
                        call.argument<String>("sourcePath").orEmpty()
                    val filename =
                        call.argument<String>("filename").orEmpty()
                    copyToTree(treeUri, sourcePath, filename, result)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onActivityResult(
        requestCode: Int,
        resultCode: Int,
        data: Intent?,
    ) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_PICK_IMAGE) {
            val pending = pendingImageResult
            pendingImageResult = null
            if (pending == null) return
            if (resultCode != Activity.RESULT_OK || data?.data == null) {
                pending.success(null)
                return
            }
            try {
                val uri = data.data!!
                val dir = File(filesDir, "metadata_artwork")
                dir.mkdirs()
                val out = File(dir, "cover-${System.currentTimeMillis()}.jpg")
                contentResolver.openInputStream(uri)?.use { input ->
                    out.outputStream().use { output -> input.copyTo(output) }
                } ?: throw java.io.IOException("Could not read selected image")
                pending.success(out.absolutePath)
            } catch (e: Exception) {
                pending.error("IMAGE_ERROR", e.message, null)
            }
            return
        }
        if (requestCode != REQUEST_OPEN_TREE) {
            return
        }
        val pending = pendingPickResult
        pendingPickResult = null
        if (pending == null) {
            return
        }
        if (resultCode != Activity.RESULT_OK) {
            pending.success(null)
            return
        }
        val treeUri = data?.data
        if (treeUri == null) {
            pending.success(null)
            return
        }
        try {
            val flags =
                (data?.flags ?: 0) and
                    (
                        Intent.FLAG_GRANT_READ_URI_PERMISSION or
                            Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                        )
            val grantFlags =
                if (flags != 0) {
                    flags
                } else {
                    Intent.FLAG_GRANT_READ_URI_PERMISSION or
                        Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                }
            contentResolver.takePersistableUriPermission(treeUri, grantFlags)
        } catch (e: Exception) {
            pending.error("NO_ACCESS", e.message, null)
            return
        }
        val displayName = displayNameForTree(treeUri)
        pending.success(
            mapOf(
                "uri" to treeUri.toString(),
                "displayName" to displayName,
            ),
        )
    }

    /// Launches the system folder picker (`ACTION_OPEN_DOCUMENT_TREE`).
    ///
    /// SAF needs no manifest permission; the grant is persisted via
    /// `takePersistableUriPermission` in [onActivityResult]. Null
    /// success means the user dismissed the picker (never an error).
    private fun pickImage(result: MethodChannel.Result) {
        if (pendingImageResult != null) {
            result.error("IN_PROGRESS", "Image picker already open", null)
            return
        }
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            type = "image/*"
            addCategory(Intent.CATEGORY_OPENABLE)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        try {
            pendingImageResult = result
            startActivityForResult(intent, REQUEST_PICK_IMAGE)
        } catch (e: Exception) {
            pendingImageResult = null
            result.error("NO_PICKER", e.message, null)
        }
    }

    private fun pickFolder(result: MethodChannel.Result) {
        if (pendingPickResult != null) {
            result.error("IN_PROGRESS", "Picker already open", null)
            return
        }
        val intent =
            Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
                addFlags(
                    Intent.FLAG_GRANT_READ_URI_PERMISSION or
                        Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                        Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION or
                        Intent.FLAG_GRANT_PREFIX_URI_PERMISSION,
                )
            }
        try {
            pendingPickResult = result
            startActivityForResult(intent, REQUEST_OPEN_TREE)
        } catch (e: Exception) {
            pendingPickResult = null
            result.error("NO_PICKER", e.message, null)
        }
    }

    /// Streams one staged file into the picked tree.
    ///
    /// Runs off the UI thread and replies on it (matches the
    /// `YoutubeBridge` pattern). `SecurityException` (revoked grant)
    /// maps to `NO_ACCESS` so Dart can fall back to app-private;
    /// everything else maps to `IO_ERROR` with a typed message for
    /// the Downloads UI.
    private fun copyToTree(
        treeUriString: String,
        sourcePath: String,
        filename: String,
        result: MethodChannel.Result,
    ) {
        if (treeUriString.isEmpty() || sourcePath.isEmpty() ||
            filename.isEmpty()
        ) {
            result.error("IO_ERROR", "Missing copy arguments", null)
            return
        }
        Thread {
            try {
                val treeUri = Uri.parse(treeUriString)
                val src = File(sourcePath)
                if (!src.exists()) {
                    runOnUiThread {
                        result.error("IO_ERROR", "Staged file is gone", null)
                    }
                    return@Thread
                }
                val treeDocId =
                    DocumentsContract.getTreeDocumentId(treeUri)
                val parentUri =
                    DocumentsContract.buildDocumentUriUsingTree(
                        treeUri,
                        treeDocId,
                    )
                val mime = mimeForName(filename)
                val childUri =
                    DocumentsContract.createDocument(
                        contentResolver,
                        parentUri,
                        mime,
                        filename,
                    )
                if (childUri == null) {
                    runOnUiThread {
                        result.error(
                            "IO_ERROR",
                            "Could not create file in chosen folder",
                            null,
                        )
                    }
                    return@Thread
                }
                FileInputStream(src).use { input ->
                    contentResolver.openOutputStream(childUri)?.use { output ->
                        val buf = ByteArray(8192)
                        while (true) {
                            val n = input.read(buf)
                            if (n < 0) {
                                break
                            }
                            output.write(buf, 0, n)
                        }
                        output.flush()
                    } ?: throw java.io.IOException(
                        "Could not open chosen folder for writing",
                    )
                }
                runOnUiThread { result.success(filename) }
            } catch (e: SecurityException) {
                runOnUiThread {
                    result.error("NO_ACCESS", e.message, null)
                }
            } catch (e: Exception) {
                runOnUiThread {
                    result.error("IO_ERROR", e.message, null)
                }
            }
        }.start()
    }

    /// Human name for a picked tree (picker subtitle + settings row).
    private fun displayNameForTree(treeUri: Uri): String {
        try {
            contentResolver.query(
                treeUri,
                arrayOf(OpenableColumns.DISPLAY_NAME),
                null,
                null,
                null,
            )?.use { cursor ->
                val col =
                    cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                if (col >= 0 && cursor.moveToFirst() && !cursor.isNull(col)) {
                    val name = cursor.getString(col)
                    if (!name.isNullOrBlank()) {
                        return name
                    }
                }
            }
        } catch (e: Exception) {
            // Fall through to the document-id fallback below.
        }
        return try {
            val docId = DocumentsContract.getTreeDocumentId(treeUri)
            val raw = docId.substringAfter(":", docId).substringAfterLast("/")
            val decoded = Uri.decode(raw)
            if (decoded.isNullOrBlank()) "Custom folder" else decoded
        } catch (e: Exception) {
            "Custom folder"
        }
    }

    /// Audio-aware MIME for `createDocument` (fallback octet-stream).
    private fun mimeForName(filename: String): String {
        val lower = filename.lowercase()
        return when {
            lower.endsWith(".mp3") -> "audio/mpeg"
            lower.endsWith(".m4a") -> "audio/mp4"
            lower.endsWith(".opus") -> "audio/opus"
            lower.endsWith(".ogg") -> "audio/ogg"
            lower.endsWith(".wav") -> "audio/wav"
            lower.endsWith(".flac") -> "audio/flac"
            lower.endsWith(".webm") -> "audio/webm"
            else -> "application/octet-stream"
        }
    }

    /// Reads music rows from MediaStore (Android 11+ scoped-storage path:
    /// no filesystem walk, no extra manifest permission beyond the
    /// already-declared READ_MEDIA_AUDIO).
    private fun queryAudioFiles(): List<Map<String, Any?>> {
        val out = mutableListOf<Map<String, Any?>>()
        val uri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
        val projection = arrayOf(
            MediaStore.Audio.Media._ID,
            MediaStore.Audio.Media.TITLE,
            MediaStore.Audio.Media.DISPLAY_NAME,
            MediaStore.Audio.Media.ARTIST,
            MediaStore.Audio.Media.ALBUM,
            MediaStore.Audio.Media.ALBUM_ID,
            MediaStore.Audio.Media.DURATION,
            MediaStore.Audio.Media.YEAR,
            MediaStore.Audio.Media.SIZE,
            // Deprecated but still populated; enables direct file reads
            // (embedded-tag sniffing) under READ_MEDIA_AUDIO.
            MediaStore.Audio.Media.DATA,
        )
        val selection = "${MediaStore.Audio.Media.IS_MUSIC} != 0"
        contentResolver.query(
            uri,
            projection,
            selection,
            null,
            "${MediaStore.Audio.Media.TITLE} ASC",
        )?.use { cursor ->
            val idCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media._ID)
            val titleCol = cursor.getColumnIndex(MediaStore.Audio.Media.TITLE)
            val nameCol = cursor.getColumnIndex(MediaStore.Audio.Media.DISPLAY_NAME)
            val artistCol = cursor.getColumnIndex(MediaStore.Audio.Media.ARTIST)
            val albumCol = cursor.getColumnIndex(MediaStore.Audio.Media.ALBUM)
            val albumIdCol =
                cursor.getColumnIndex(MediaStore.Audio.Media.ALBUM_ID)
            val durationCol = cursor.getColumnIndex(MediaStore.Audio.Media.DURATION)
            val yearCol = cursor.getColumnIndex(MediaStore.Audio.Media.YEAR)
            val sizeCol = cursor.getColumnIndex(MediaStore.Audio.Media.SIZE)
            val dataCol = cursor.getColumnIndex(MediaStore.Audio.Media.DATA)
            while (cursor.moveToNext()) {
                val id = cursor.getLong(idCol)
                out.add(
                    mapOf(
                        "id" to id,
                        "title" to cursor.getStringOrNull(titleCol),
                        "displayName" to cursor.getStringOrNull(nameCol),
                        "artist" to cursor.getStringOrNull(artistCol),
                        "album" to cursor.getStringOrNull(albumCol),
                        "albumId" to cursor.getLongOrNull(albumIdCol),
                        "durationMs" to cursor.getLongOrNull(durationCol),
                        "year" to cursor.getIntOrNull(yearCol),
                        "size" to cursor.getLongOrNull(sizeCol),
                        "dataPath" to cursor.getStringOrNull(dataCol),
                    ),
                )
            }
        }
        return out
    }

    /// Thumbnail for one audio row, persisted under app cache.
    ///
    /// Prefers the album collection URI (`Audio.Albums/<albumId>`): the
    /// per-track audio URI does not serve thumbnails on all devices
    /// (`FileNotFoundException` even when the file carries embedded
    /// art), while the album URI does. Falls back to the track URI
    /// when the album is unknown or its thumbnail is missing. Uses
    /// `ContentResolver.loadThumbnail` (512px, JPEG 85, API 29+ guard)
    /// so no file-path access is needed. Returns the absolute path of
    /// `artwork/local-<audioId>.jpg`, or null when neither source
    /// carries art or on any failure (never throws).
    private fun artworkFor(audioId: Long, albumId: Long?): String? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            return null
        }
        if (albumId != null && albumId > 0) {
            thumbnailFor(
                ContentUris.withAppendedId(
                    MediaStore.Audio.Albums.EXTERNAL_CONTENT_URI,
                    albumId,
                ),
                audioId,
            )?.let { return it }
        }
        return thumbnailFor(
            ContentUris.withAppendedId(
                MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                audioId,
            ),
            audioId,
        )
    }

    /// Renders one MediaStore URI thumbnail into the artwork cache.
    ///
    /// Returns the cached file path, or null when the URI carries no
    /// thumbnail or on any failure (never throws — callers own the
    /// channel result).
    private fun thumbnailFor(uri: Uri, audioId: Long): String? {
        return try {
            val thumb = contentResolver.loadThumbnail(
                uri,
                Size(512, 512),
                null,
            )
            val dir = File(cacheDir, "artwork")
            dir.mkdirs()
            val out = File(dir, "local-$audioId.jpg")
            out.outputStream().use { stream ->
                thumb.compress(Bitmap.CompressFormat.JPEG, 85, stream)
            }
            out.absolutePath
        } catch (t: Throwable) {
            null
        }
    }

    /// Raw byte range of one audio row for embedded-art sniffing.
    ///
    /// Reads through the `content://` URI (no `DATA` path needed), so it
    /// works under scoped storage with only `READ_MEDIA_AUDIO` granted.
    /// A negative [offset] reads from the end (`moov`-at-end mp4 tail).
    /// Returns the bytes, or null when unreadable (never throws).
    private fun readAudioBytes(audioId: Long, offset: Long, length: Int): ByteArray? {
        return try {
            if (length <= 0) {
                return null
            }
            val uri =
                ContentUris.withAppendedId(
                    MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                    audioId,
                )
            contentResolver.openFileDescriptor(uri, "r")?.use { pfd ->
                FileInputStream(pfd.fileDescriptor).use { stream ->
                    val channel = stream.channel
                    val size = channel.size()
                    if (size <= 0) {
                        return null
                    }
                    val start =
                        if (offset < 0) {
                            maxOf(0L, size + offset)
                        } else {
                            minOf(offset, size - 1)
                        }
                    val capped = minOf(length.toLong(), size - start).toInt()
                    if (capped <= 0) {
                        return null
                    }
                    channel.position(start)
                    val buf = ByteArray(capped)
                    var read = 0
                    while (read < capped) {
                        val n = stream.read(buf, read, capped - read)
                        if (n < 0) {
                            break
                        }
                        read += n
                    }
                    if (read <= 0) {
                        null
                    } else if (read == capped) {
                        buf
                    } else {
                        buf.copyOf(read)
                    }
                }
            }
        } catch (t: Throwable) {
            null
        }
    }

    private fun requestNotificationPermission(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            result.success(true)
            return
        }
        if (checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) ==
            android.content.pm.PackageManager.PERMISSION_GRANTED
        ) {
            result.success(true)
            return
        }
        requestPermissions(
            arrayOf(Manifest.permission.POST_NOTIFICATIONS),
            REQUEST_NOTIFICATIONS,
        )
        result.success(false)
    }

    /// Long channel argument, tolerant of 32/64-bit ints and strings.
    private fun MethodCall.longArg(key: String): Long? =
        when (val value = argument<Any>(key)) {
            is Number -> value.toLong()
            is String -> value.toLongOrNull()
            else -> null
        }

    private fun Cursor.getStringOrNull(col: Int): String? =
        if (col < 0 || isNull(col)) null else getString(col)

    private fun Cursor.getLongOrNull(col: Int): Long? =
        if (col < 0 || isNull(col)) null else getLong(col)

    private fun Cursor.getIntOrNull(col: Int): Int? =
        if (col < 0 || isNull(col)) null else getInt(col)

    private var pendingPickResult: MethodChannel.Result? = null
    private var pendingImageResult: MethodChannel.Result? = null

    companion object {
        private const val MEDIA_STORE_CHANNEL = "aurora.player/media_store"
        private const val METHOD_REQUEST_NOTIFICATIONS = "requestNotificationPermission"
        private const val METHOD_QUERY_AUDIO = "queryAudio"
        private const val METHOD_ARTWORK_FOR = "artworkFor"
        private const val METHOD_READ_AUDIO_BYTES = "readAudioBytes"
        private const val DOWNLOADS_CHANNEL = "aurora.player/downloads"
        private const val METHOD_PICK_FOLDER = "downloads/pickFolder"
        private const val METHOD_PICK_IMAGE = "downloads/pickImage"
        private const val METHOD_COPY_TO_TREE = "downloads/copyToTree"
        private const val REQUEST_OPEN_TREE = 9001
        private const val REQUEST_PICK_IMAGE = 9003
        private const val REQUEST_NOTIFICATIONS = 9002
    }
}

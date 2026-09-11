import 'dart:io';

import 'package:aurora_core/aurora_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Picked SAF folder: persistable tree URI + human display name.
typedef PickedFolder = ({String uri, String displayName});

/// Writes one staged file into a user-picked SAF tree.
///
/// Real implementation streams via the platform channel
/// (`aurora.player/downloads` `copyToTree`); tests inject a fake.
/// Returns success with the tree child display name, or a typed
/// failure (`permission` when the grant was revoked, `io` otherwise)
/// so the Downloads UI can show the reason and fall back.
typedef TreeFileWriter =
    Future<Result<String, AppError>> Function({
      required String treeUri,
      required File sourceFile,
      required String filename,
    });

/// Storage Access Framework bridge (Android `ACTION_OPEN_DOCUMENT_TREE`).
///
/// - `pickFolder` opens the system folder picker (new channel
///   `aurora.player/downloads`, method `downloads/pickFolder`);
///   null means the user dismissed it.
/// - `copyToTree` streams a staged temp file into the tree
///   (method `downloads/copyToTree` via `ContentResolver`
///   `openOutputStream`); typed errors surface in the Downloads UI.
/// - SAF needs no manifest permission; revoked grants surface as
///   `AppErrorCode.permission` (`downloads:tree-no-access`) so the app
///   lane can fall back to app-private storage with a snackbar.
abstract final class DownloadTreeChannel {
  /// Platform channel for the SAF folder picker + tree writer.
  @visibleForTesting
  static MethodChannel channel = const MethodChannel(
    'aurora.player/downloads',
  );

  /// Injectable writer (defaults to the platform channel copy).
  static TreeFileWriter writer = _copyViaChannel;

  /// Opens the system folder picker; null on dismiss/cancel.
  static Future<PickedFolder?> pickFolder() async {
    try {
      final picked = await channel.invokeMapMethod<String, Object?>(
        'downloads/pickFolder',
      );
      if (picked == null) {
        return null;
      }
      final uri = picked['uri']?.toString() ?? '';
      if (uri.isEmpty) {
        return null;
      }
      final name = picked['displayName']?.toString().trim() ?? '';
      return (
        uri: uri,
        displayName: name.isEmpty ? uri : name,
      );
    } on PlatformException catch (error) {
      throw AppException(
        AppError(
          code: AppErrorCode.io,
          message: 'Could not open the folder picker',
          details: 'downloads:pick-folder:${error.code}',
          cause: error,
        ),
      );
    }
  }

  /// Copies `sourceFile` into `treeUri` as `filename` via the channel.
  static Future<Result<String, AppError>> _copyViaChannel({
    required String treeUri,
    required File sourceFile,
    required String filename,
  }) async {
    try {
      final name = await channel.invokeMethod<String>(
        'downloads/copyToTree',
        <String, Object?>{
          'treeUri': treeUri,
          'sourcePath': sourceFile.path,
          'filename': filename,
        },
      );
      return Success(name == null || name.isEmpty ? filename : name);
    } on PlatformException catch (error) {
      if (error.code == 'NO_ACCESS' || error.code == 'PERMISSION_REVOKED') {
        return const Failure(
          AppError(
            code: AppErrorCode.permission,
            message:
                'Lost access to the chosen folder — fell back to '
                'app-private storage',
            details: 'downloads:tree-no-access',
          ),
        );
      }
      return Failure(
        AppError(
          code: AppErrorCode.io,
          message: 'Could not write to the chosen folder',
          details: 'downloads:tree-write:${error.code}',
        ),
      );
    } on Exception catch (error) {
      return Failure(
        AppError(
          code: AppErrorCode.io,
          message: 'Could not write to the chosen folder',
          details: 'downloads:tree-write',
          cause: error,
        ),
      );
    }
  }
}

/// Persisted SAF tree destination shared with the download manager.
///
/// The app lane sets `treeUri` at restore/pick time (no wiring
/// changes needed); the manager reads it at completion time and
/// exports via `DownloadTreeChannel.writer`. Null/empty means the
/// classic `Directory` output path is authoritative.
abstract final class DownloadTreeDestination {
  /// Current tree URI string (null/empty = no custom folder).
  static String? treeUri;
}

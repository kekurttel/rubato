// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aurora_db.dart';

// ignore_for_file: type=lint
class $TracksTable extends Tracks with TableInfo<$TracksTable, DbTrack> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TracksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceTrackIdMeta = const VerificationMeta(
    'sourceTrackId',
  );
  @override
  late final GeneratedColumn<String> sourceTrackId = GeneratedColumn<String>(
    'source_track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _explicitMeta = const VerificationMeta(
    'explicit',
  );
  @override
  late final GeneratedColumn<int> explicit = GeneratedColumn<int>(
    'explicit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _albumIdMeta = const VerificationMeta(
    'albumId',
  );
  @override
  late final GeneratedColumn<String> albumId = GeneratedColumn<String>(
    'album_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _audioHashMeta = const VerificationMeta(
    'audioHash',
  );
  @override
  late final GeneratedColumn<String> audioHash = GeneratedColumn<String>(
    'audio_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDownloadedMeta = const VerificationMeta(
    'isDownloaded',
  );
  @override
  late final GeneratedColumn<int> isDownloaded = GeneratedColumn<int>(
    'is_downloaded',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _streamExpiresAtMeta = const VerificationMeta(
    'streamExpiresAt',
  );
  @override
  late final GeneratedColumn<int> streamExpiresAt = GeneratedColumn<int>(
    'stream_expires_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    providerId,
    sourceTrackId,
    title,
    durationMs,
    explicit,
    albumId,
    year,
    audioHash,
    localPath,
    isDownloaded,
    streamExpiresAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tracks';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbTrack> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('source_track_id')) {
      context.handle(
        _sourceTrackIdMeta,
        sourceTrackId.isAcceptableOrUnknown(
          data['source_track_id']!,
          _sourceTrackIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceTrackIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('explicit')) {
      context.handle(
        _explicitMeta,
        explicit.isAcceptableOrUnknown(data['explicit']!, _explicitMeta),
      );
    }
    if (data.containsKey('album_id')) {
      context.handle(
        _albumIdMeta,
        albumId.isAcceptableOrUnknown(data['album_id']!, _albumIdMeta),
      );
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('audio_hash')) {
      context.handle(
        _audioHashMeta,
        audioHash.isAcceptableOrUnknown(data['audio_hash']!, _audioHashMeta),
      );
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    }
    if (data.containsKey('is_downloaded')) {
      context.handle(
        _isDownloadedMeta,
        isDownloaded.isAcceptableOrUnknown(
          data['is_downloaded']!,
          _isDownloadedMeta,
        ),
      );
    }
    if (data.containsKey('stream_expires_at')) {
      context.handle(
        _streamExpiresAtMeta,
        streamExpiresAt.isAcceptableOrUnknown(
          data['stream_expires_at']!,
          _streamExpiresAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {providerId, sourceTrackId},
  ];
  @override
  DbTrack map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbTrack(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      sourceTrackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_track_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      explicit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}explicit'],
      )!,
      albumId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album_id'],
      ),
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      ),
      audioHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_hash'],
      ),
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      ),
      isDownloaded: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_downloaded'],
      )!,
      streamExpiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stream_expires_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TracksTable createAlias(String alias) {
    return $TracksTable(attachedDatabase, alias);
  }
}

class DbTrack extends DataClass implements Insertable<DbTrack> {
  /// Composite `${providerId}:${sourceId}` key.
  final String id;

  /// Owning provider (`local`, `fake`, `ytdlp`).
  final String providerId;

  /// Provider-scoped id (MYT `(_ID_)` suffix, video id, ...).
  final String sourceTrackId;

  /// Clean display title (never raw `(_ID_)` filename).
  final String title;

  /// Duration in milliseconds (0 when unknown).
  final int durationMs;

  /// Explicit flag as 0/1.
  final int explicit;

  /// Parent album id, if known.
  final String? albumId;

  /// Release year, if known.
  final int? year;

  /// Content hash (first+last 64KB + length) for dedupe.
  final String? audioHash;

  /// On-disk path when a usable local file exists.
  final String? localPath;

  /// Verified download persisted, as 0/1.
  final int isDownloaded;

  /// Stream URL expiry (epoch ms, null for local files).
  final int? streamExpiresAt;

  /// Row creation time (UTC epoch ms).
  final int createdAt;

  /// Row update time (UTC epoch ms).
  final int updatedAt;
  const DbTrack({
    required this.id,
    required this.providerId,
    required this.sourceTrackId,
    required this.title,
    required this.durationMs,
    required this.explicit,
    this.albumId,
    this.year,
    this.audioHash,
    this.localPath,
    required this.isDownloaded,
    this.streamExpiresAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['provider_id'] = Variable<String>(providerId);
    map['source_track_id'] = Variable<String>(sourceTrackId);
    map['title'] = Variable<String>(title);
    map['duration_ms'] = Variable<int>(durationMs);
    map['explicit'] = Variable<int>(explicit);
    if (!nullToAbsent || albumId != null) {
      map['album_id'] = Variable<String>(albumId);
    }
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    if (!nullToAbsent || audioHash != null) {
      map['audio_hash'] = Variable<String>(audioHash);
    }
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    map['is_downloaded'] = Variable<int>(isDownloaded);
    if (!nullToAbsent || streamExpiresAt != null) {
      map['stream_expires_at'] = Variable<int>(streamExpiresAt);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  TracksCompanion toCompanion(bool nullToAbsent) {
    return TracksCompanion(
      id: Value(id),
      providerId: Value(providerId),
      sourceTrackId: Value(sourceTrackId),
      title: Value(title),
      durationMs: Value(durationMs),
      explicit: Value(explicit),
      albumId: albumId == null && nullToAbsent
          ? const Value.absent()
          : Value(albumId),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      audioHash: audioHash == null && nullToAbsent
          ? const Value.absent()
          : Value(audioHash),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      isDownloaded: Value(isDownloaded),
      streamExpiresAt: streamExpiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(streamExpiresAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DbTrack.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbTrack(
      id: serializer.fromJson<String>(json['id']),
      providerId: serializer.fromJson<String>(json['providerId']),
      sourceTrackId: serializer.fromJson<String>(json['sourceTrackId']),
      title: serializer.fromJson<String>(json['title']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      explicit: serializer.fromJson<int>(json['explicit']),
      albumId: serializer.fromJson<String?>(json['albumId']),
      year: serializer.fromJson<int?>(json['year']),
      audioHash: serializer.fromJson<String?>(json['audioHash']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      isDownloaded: serializer.fromJson<int>(json['isDownloaded']),
      streamExpiresAt: serializer.fromJson<int?>(json['streamExpiresAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'providerId': serializer.toJson<String>(providerId),
      'sourceTrackId': serializer.toJson<String>(sourceTrackId),
      'title': serializer.toJson<String>(title),
      'durationMs': serializer.toJson<int>(durationMs),
      'explicit': serializer.toJson<int>(explicit),
      'albumId': serializer.toJson<String?>(albumId),
      'year': serializer.toJson<int?>(year),
      'audioHash': serializer.toJson<String?>(audioHash),
      'localPath': serializer.toJson<String?>(localPath),
      'isDownloaded': serializer.toJson<int>(isDownloaded),
      'streamExpiresAt': serializer.toJson<int?>(streamExpiresAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  DbTrack copyWith({
    String? id,
    String? providerId,
    String? sourceTrackId,
    String? title,
    int? durationMs,
    int? explicit,
    Value<String?> albumId = const Value.absent(),
    Value<int?> year = const Value.absent(),
    Value<String?> audioHash = const Value.absent(),
    Value<String?> localPath = const Value.absent(),
    int? isDownloaded,
    Value<int?> streamExpiresAt = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => DbTrack(
    id: id ?? this.id,
    providerId: providerId ?? this.providerId,
    sourceTrackId: sourceTrackId ?? this.sourceTrackId,
    title: title ?? this.title,
    durationMs: durationMs ?? this.durationMs,
    explicit: explicit ?? this.explicit,
    albumId: albumId.present ? albumId.value : this.albumId,
    year: year.present ? year.value : this.year,
    audioHash: audioHash.present ? audioHash.value : this.audioHash,
    localPath: localPath.present ? localPath.value : this.localPath,
    isDownloaded: isDownloaded ?? this.isDownloaded,
    streamExpiresAt: streamExpiresAt.present
        ? streamExpiresAt.value
        : this.streamExpiresAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DbTrack copyWithCompanion(TracksCompanion data) {
    return DbTrack(
      id: data.id.present ? data.id.value : this.id,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      sourceTrackId: data.sourceTrackId.present
          ? data.sourceTrackId.value
          : this.sourceTrackId,
      title: data.title.present ? data.title.value : this.title,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      explicit: data.explicit.present ? data.explicit.value : this.explicit,
      albumId: data.albumId.present ? data.albumId.value : this.albumId,
      year: data.year.present ? data.year.value : this.year,
      audioHash: data.audioHash.present ? data.audioHash.value : this.audioHash,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      isDownloaded: data.isDownloaded.present
          ? data.isDownloaded.value
          : this.isDownloaded,
      streamExpiresAt: data.streamExpiresAt.present
          ? data.streamExpiresAt.value
          : this.streamExpiresAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbTrack(')
          ..write('id: $id, ')
          ..write('providerId: $providerId, ')
          ..write('sourceTrackId: $sourceTrackId, ')
          ..write('title: $title, ')
          ..write('durationMs: $durationMs, ')
          ..write('explicit: $explicit, ')
          ..write('albumId: $albumId, ')
          ..write('year: $year, ')
          ..write('audioHash: $audioHash, ')
          ..write('localPath: $localPath, ')
          ..write('isDownloaded: $isDownloaded, ')
          ..write('streamExpiresAt: $streamExpiresAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    providerId,
    sourceTrackId,
    title,
    durationMs,
    explicit,
    albumId,
    year,
    audioHash,
    localPath,
    isDownloaded,
    streamExpiresAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbTrack &&
          other.id == this.id &&
          other.providerId == this.providerId &&
          other.sourceTrackId == this.sourceTrackId &&
          other.title == this.title &&
          other.durationMs == this.durationMs &&
          other.explicit == this.explicit &&
          other.albumId == this.albumId &&
          other.year == this.year &&
          other.audioHash == this.audioHash &&
          other.localPath == this.localPath &&
          other.isDownloaded == this.isDownloaded &&
          other.streamExpiresAt == this.streamExpiresAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TracksCompanion extends UpdateCompanion<DbTrack> {
  final Value<String> id;
  final Value<String> providerId;
  final Value<String> sourceTrackId;
  final Value<String> title;
  final Value<int> durationMs;
  final Value<int> explicit;
  final Value<String?> albumId;
  final Value<int?> year;
  final Value<String?> audioHash;
  final Value<String?> localPath;
  final Value<int> isDownloaded;
  final Value<int?> streamExpiresAt;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const TracksCompanion({
    this.id = const Value.absent(),
    this.providerId = const Value.absent(),
    this.sourceTrackId = const Value.absent(),
    this.title = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.explicit = const Value.absent(),
    this.albumId = const Value.absent(),
    this.year = const Value.absent(),
    this.audioHash = const Value.absent(),
    this.localPath = const Value.absent(),
    this.isDownloaded = const Value.absent(),
    this.streamExpiresAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TracksCompanion.insert({
    required String id,
    required String providerId,
    required String sourceTrackId,
    required String title,
    this.durationMs = const Value.absent(),
    this.explicit = const Value.absent(),
    this.albumId = const Value.absent(),
    this.year = const Value.absent(),
    this.audioHash = const Value.absent(),
    this.localPath = const Value.absent(),
    this.isDownloaded = const Value.absent(),
    this.streamExpiresAt = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       providerId = Value(providerId),
       sourceTrackId = Value(sourceTrackId),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DbTrack> custom({
    Expression<String>? id,
    Expression<String>? providerId,
    Expression<String>? sourceTrackId,
    Expression<String>? title,
    Expression<int>? durationMs,
    Expression<int>? explicit,
    Expression<String>? albumId,
    Expression<int>? year,
    Expression<String>? audioHash,
    Expression<String>? localPath,
    Expression<int>? isDownloaded,
    Expression<int>? streamExpiresAt,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (providerId != null) 'provider_id': providerId,
      if (sourceTrackId != null) 'source_track_id': sourceTrackId,
      if (title != null) 'title': title,
      if (durationMs != null) 'duration_ms': durationMs,
      if (explicit != null) 'explicit': explicit,
      if (albumId != null) 'album_id': albumId,
      if (year != null) 'year': year,
      if (audioHash != null) 'audio_hash': audioHash,
      if (localPath != null) 'local_path': localPath,
      if (isDownloaded != null) 'is_downloaded': isDownloaded,
      if (streamExpiresAt != null) 'stream_expires_at': streamExpiresAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TracksCompanion copyWith({
    Value<String>? id,
    Value<String>? providerId,
    Value<String>? sourceTrackId,
    Value<String>? title,
    Value<int>? durationMs,
    Value<int>? explicit,
    Value<String?>? albumId,
    Value<int?>? year,
    Value<String?>? audioHash,
    Value<String?>? localPath,
    Value<int>? isDownloaded,
    Value<int?>? streamExpiresAt,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return TracksCompanion(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      sourceTrackId: sourceTrackId ?? this.sourceTrackId,
      title: title ?? this.title,
      durationMs: durationMs ?? this.durationMs,
      explicit: explicit ?? this.explicit,
      albumId: albumId ?? this.albumId,
      year: year ?? this.year,
      audioHash: audioHash ?? this.audioHash,
      localPath: localPath ?? this.localPath,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      streamExpiresAt: streamExpiresAt ?? this.streamExpiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (sourceTrackId.present) {
      map['source_track_id'] = Variable<String>(sourceTrackId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (explicit.present) {
      map['explicit'] = Variable<int>(explicit.value);
    }
    if (albumId.present) {
      map['album_id'] = Variable<String>(albumId.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (audioHash.present) {
      map['audio_hash'] = Variable<String>(audioHash.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (isDownloaded.present) {
      map['is_downloaded'] = Variable<int>(isDownloaded.value);
    }
    if (streamExpiresAt.present) {
      map['stream_expires_at'] = Variable<int>(streamExpiresAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TracksCompanion(')
          ..write('id: $id, ')
          ..write('providerId: $providerId, ')
          ..write('sourceTrackId: $sourceTrackId, ')
          ..write('title: $title, ')
          ..write('durationMs: $durationMs, ')
          ..write('explicit: $explicit, ')
          ..write('albumId: $albumId, ')
          ..write('year: $year, ')
          ..write('audioHash: $audioHash, ')
          ..write('localPath: $localPath, ')
          ..write('isDownloaded: $isDownloaded, ')
          ..write('streamExpiresAt: $streamExpiresAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrackArtistsTable extends TrackArtists
    with TableInfo<$TrackArtistsTable, DbTrackArtist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackArtistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistIdMeta = const VerificationMeta(
    'artistId',
  );
  @override
  late final GeneratedColumn<String> artistId = GeneratedColumn<String>(
    'artist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [trackId, artistId, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'track_artists';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbTrackArtist> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('artist_id')) {
      context.handle(
        _artistIdMeta,
        artistId.isAcceptableOrUnknown(data['artist_id']!, _artistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_artistIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {trackId, artistId};
  @override
  DbTrackArtist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbTrackArtist(
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      artistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $TrackArtistsTable createAlias(String alias) {
    return $TrackArtistsTable(attachedDatabase, alias);
  }
}

class DbTrackArtist extends DataClass implements Insertable<DbTrackArtist> {
  /// Owning track id.
  final String trackId;

  /// Credited artist id.
  final String artistId;

  /// Credit order.
  final int position;
  const DbTrackArtist({
    required this.trackId,
    required this.artistId,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['track_id'] = Variable<String>(trackId);
    map['artist_id'] = Variable<String>(artistId);
    map['position'] = Variable<int>(position);
    return map;
  }

  TrackArtistsCompanion toCompanion(bool nullToAbsent) {
    return TrackArtistsCompanion(
      trackId: Value(trackId),
      artistId: Value(artistId),
      position: Value(position),
    );
  }

  factory DbTrackArtist.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbTrackArtist(
      trackId: serializer.fromJson<String>(json['trackId']),
      artistId: serializer.fromJson<String>(json['artistId']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trackId': serializer.toJson<String>(trackId),
      'artistId': serializer.toJson<String>(artistId),
      'position': serializer.toJson<int>(position),
    };
  }

  DbTrackArtist copyWith({String? trackId, String? artistId, int? position}) =>
      DbTrackArtist(
        trackId: trackId ?? this.trackId,
        artistId: artistId ?? this.artistId,
        position: position ?? this.position,
      );
  DbTrackArtist copyWithCompanion(TrackArtistsCompanion data) {
    return DbTrackArtist(
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      artistId: data.artistId.present ? data.artistId.value : this.artistId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbTrackArtist(')
          ..write('trackId: $trackId, ')
          ..write('artistId: $artistId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(trackId, artistId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbTrackArtist &&
          other.trackId == this.trackId &&
          other.artistId == this.artistId &&
          other.position == this.position);
}

class TrackArtistsCompanion extends UpdateCompanion<DbTrackArtist> {
  final Value<String> trackId;
  final Value<String> artistId;
  final Value<int> position;
  final Value<int> rowid;
  const TrackArtistsCompanion({
    this.trackId = const Value.absent(),
    this.artistId = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrackArtistsCompanion.insert({
    required String trackId,
    required String artistId,
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : trackId = Value(trackId),
       artistId = Value(artistId);
  static Insertable<DbTrackArtist> custom({
    Expression<String>? trackId,
    Expression<String>? artistId,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (trackId != null) 'track_id': trackId,
      if (artistId != null) 'artist_id': artistId,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrackArtistsCompanion copyWith({
    Value<String>? trackId,
    Value<String>? artistId,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return TrackArtistsCompanion(
      trackId: trackId ?? this.trackId,
      artistId: artistId ?? this.artistId,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (artistId.present) {
      map['artist_id'] = Variable<String>(artistId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackArtistsCompanion(')
          ..write('trackId: $trackId, ')
          ..write('artistId: $artistId, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrackGenresTable extends TrackGenres
    with TableInfo<$TrackGenresTable, DbTrackGenre> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackGenresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _genreIdMeta = const VerificationMeta(
    'genreId',
  );
  @override
  late final GeneratedColumn<String> genreId = GeneratedColumn<String>(
    'genre_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [trackId, genreId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'track_genres';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbTrackGenre> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('genre_id')) {
      context.handle(
        _genreIdMeta,
        genreId.isAcceptableOrUnknown(data['genre_id']!, _genreIdMeta),
      );
    } else if (isInserting) {
      context.missing(_genreIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {trackId, genreId};
  @override
  DbTrackGenre map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbTrackGenre(
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      genreId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genre_id'],
      )!,
    );
  }

  @override
  $TrackGenresTable createAlias(String alias) {
    return $TrackGenresTable(attachedDatabase, alias);
  }
}

class DbTrackGenre extends DataClass implements Insertable<DbTrackGenre> {
  /// Owning track id.
  final String trackId;

  /// Genre id.
  final String genreId;
  const DbTrackGenre({required this.trackId, required this.genreId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['track_id'] = Variable<String>(trackId);
    map['genre_id'] = Variable<String>(genreId);
    return map;
  }

  TrackGenresCompanion toCompanion(bool nullToAbsent) {
    return TrackGenresCompanion(
      trackId: Value(trackId),
      genreId: Value(genreId),
    );
  }

  factory DbTrackGenre.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbTrackGenre(
      trackId: serializer.fromJson<String>(json['trackId']),
      genreId: serializer.fromJson<String>(json['genreId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trackId': serializer.toJson<String>(trackId),
      'genreId': serializer.toJson<String>(genreId),
    };
  }

  DbTrackGenre copyWith({String? trackId, String? genreId}) => DbTrackGenre(
    trackId: trackId ?? this.trackId,
    genreId: genreId ?? this.genreId,
  );
  DbTrackGenre copyWithCompanion(TrackGenresCompanion data) {
    return DbTrackGenre(
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      genreId: data.genreId.present ? data.genreId.value : this.genreId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbTrackGenre(')
          ..write('trackId: $trackId, ')
          ..write('genreId: $genreId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(trackId, genreId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbTrackGenre &&
          other.trackId == this.trackId &&
          other.genreId == this.genreId);
}

class TrackGenresCompanion extends UpdateCompanion<DbTrackGenre> {
  final Value<String> trackId;
  final Value<String> genreId;
  final Value<int> rowid;
  const TrackGenresCompanion({
    this.trackId = const Value.absent(),
    this.genreId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrackGenresCompanion.insert({
    required String trackId,
    required String genreId,
    this.rowid = const Value.absent(),
  }) : trackId = Value(trackId),
       genreId = Value(genreId);
  static Insertable<DbTrackGenre> custom({
    Expression<String>? trackId,
    Expression<String>? genreId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (trackId != null) 'track_id': trackId,
      if (genreId != null) 'genre_id': genreId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrackGenresCompanion copyWith({
    Value<String>? trackId,
    Value<String>? genreId,
    Value<int>? rowid,
  }) {
    return TrackGenresCompanion(
      trackId: trackId ?? this.trackId,
      genreId: genreId ?? this.genreId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (genreId.present) {
      map['genre_id'] = Variable<String>(genreId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackGenresCompanion(')
          ..write('trackId: $trackId, ')
          ..write('genreId: $genreId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ArtistsTable extends Artists with TableInfo<$ArtistsTable, DbArtist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArtistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    providerId,
    sourceId,
    name,
    imageUrl,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'artists';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbArtist> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbArtist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbArtist(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      ),
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
    );
  }

  @override
  $ArtistsTable createAlias(String alias) {
    return $ArtistsTable(attachedDatabase, alias);
  }
}

class DbArtist extends DataClass implements Insertable<DbArtist> {
  /// Composite `${providerId}:${sourceId}` id.
  final String id;

  /// Owning provider.
  final String? providerId;

  /// Provider-scoped id.
  final String? sourceId;

  /// Display name.
  final String name;

  /// Artwork URL, if the provider supplied one.
  final String? imageUrl;
  const DbArtist({
    required this.id,
    this.providerId,
    this.sourceId,
    required this.name,
    this.imageUrl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || providerId != null) {
      map['provider_id'] = Variable<String>(providerId);
    }
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<String>(sourceId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    return map;
  }

  ArtistsCompanion toCompanion(bool nullToAbsent) {
    return ArtistsCompanion(
      id: Value(id),
      providerId: providerId == null && nullToAbsent
          ? const Value.absent()
          : Value(providerId),
      sourceId: sourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceId),
      name: Value(name),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
    );
  }

  factory DbArtist.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbArtist(
      id: serializer.fromJson<String>(json['id']),
      providerId: serializer.fromJson<String?>(json['providerId']),
      sourceId: serializer.fromJson<String?>(json['sourceId']),
      name: serializer.fromJson<String>(json['name']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'providerId': serializer.toJson<String?>(providerId),
      'sourceId': serializer.toJson<String?>(sourceId),
      'name': serializer.toJson<String>(name),
      'imageUrl': serializer.toJson<String?>(imageUrl),
    };
  }

  DbArtist copyWith({
    String? id,
    Value<String?> providerId = const Value.absent(),
    Value<String?> sourceId = const Value.absent(),
    String? name,
    Value<String?> imageUrl = const Value.absent(),
  }) => DbArtist(
    id: id ?? this.id,
    providerId: providerId.present ? providerId.value : this.providerId,
    sourceId: sourceId.present ? sourceId.value : this.sourceId,
    name: name ?? this.name,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
  );
  DbArtist copyWithCompanion(ArtistsCompanion data) {
    return DbArtist(
      id: data.id.present ? data.id.value : this.id,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      name: data.name.present ? data.name.value : this.name,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbArtist(')
          ..write('id: $id, ')
          ..write('providerId: $providerId, ')
          ..write('sourceId: $sourceId, ')
          ..write('name: $name, ')
          ..write('imageUrl: $imageUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, providerId, sourceId, name, imageUrl);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbArtist &&
          other.id == this.id &&
          other.providerId == this.providerId &&
          other.sourceId == this.sourceId &&
          other.name == this.name &&
          other.imageUrl == this.imageUrl);
}

class ArtistsCompanion extends UpdateCompanion<DbArtist> {
  final Value<String> id;
  final Value<String?> providerId;
  final Value<String?> sourceId;
  final Value<String> name;
  final Value<String?> imageUrl;
  final Value<int> rowid;
  const ArtistsCompanion({
    this.id = const Value.absent(),
    this.providerId = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.name = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ArtistsCompanion.insert({
    required String id,
    this.providerId = const Value.absent(),
    this.sourceId = const Value.absent(),
    required String name,
    this.imageUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<DbArtist> custom({
    Expression<String>? id,
    Expression<String>? providerId,
    Expression<String>? sourceId,
    Expression<String>? name,
    Expression<String>? imageUrl,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (providerId != null) 'provider_id': providerId,
      if (sourceId != null) 'source_id': sourceId,
      if (name != null) 'name': name,
      if (imageUrl != null) 'image_url': imageUrl,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ArtistsCompanion copyWith({
    Value<String>? id,
    Value<String?>? providerId,
    Value<String?>? sourceId,
    Value<String>? name,
    Value<String?>? imageUrl,
    Value<int>? rowid,
  }) {
    return ArtistsCompanion(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      sourceId: sourceId ?? this.sourceId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArtistsCompanion(')
          ..write('id: $id, ')
          ..write('providerId: $providerId, ')
          ..write('sourceId: $sourceId, ')
          ..write('name: $name, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AlbumsTable extends Albums with TableInfo<$AlbumsTable, DbAlbum> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlbumsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artworkIdMeta = const VerificationMeta(
    'artworkId',
  );
  @override
  late final GeneratedColumn<String> artworkId = GeneratedColumn<String>(
    'artwork_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trackCountMeta = const VerificationMeta(
    'trackCount',
  );
  @override
  late final GeneratedColumn<int> trackCount = GeneratedColumn<int>(
    'track_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    providerId,
    sourceId,
    title,
    year,
    artworkId,
    trackCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'albums';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbAlbum> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('artwork_id')) {
      context.handle(
        _artworkIdMeta,
        artworkId.isAcceptableOrUnknown(data['artwork_id']!, _artworkIdMeta),
      );
    }
    if (data.containsKey('track_count')) {
      context.handle(
        _trackCountMeta,
        trackCount.isAcceptableOrUnknown(data['track_count']!, _trackCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbAlbum map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbAlbum(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      ),
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      ),
      artworkId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artwork_id'],
      ),
      trackCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}track_count'],
      ),
    );
  }

  @override
  $AlbumsTable createAlias(String alias) {
    return $AlbumsTable(attachedDatabase, alias);
  }
}

class DbAlbum extends DataClass implements Insertable<DbAlbum> {
  /// Composite `${providerId}:${sourceId}` id.
  final String id;

  /// Owning provider.
  final String? providerId;

  /// Provider-scoped id.
  final String? sourceId;

  /// Display title.
  final String title;

  /// Release year, if known.
  final int? year;

  /// Cover artwork id, if cached.
  final String? artworkId;

  /// Known track count (0 when unknown).
  final int? trackCount;
  const DbAlbum({
    required this.id,
    this.providerId,
    this.sourceId,
    required this.title,
    this.year,
    this.artworkId,
    this.trackCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || providerId != null) {
      map['provider_id'] = Variable<String>(providerId);
    }
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<String>(sourceId);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    if (!nullToAbsent || artworkId != null) {
      map['artwork_id'] = Variable<String>(artworkId);
    }
    if (!nullToAbsent || trackCount != null) {
      map['track_count'] = Variable<int>(trackCount);
    }
    return map;
  }

  AlbumsCompanion toCompanion(bool nullToAbsent) {
    return AlbumsCompanion(
      id: Value(id),
      providerId: providerId == null && nullToAbsent
          ? const Value.absent()
          : Value(providerId),
      sourceId: sourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceId),
      title: Value(title),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      artworkId: artworkId == null && nullToAbsent
          ? const Value.absent()
          : Value(artworkId),
      trackCount: trackCount == null && nullToAbsent
          ? const Value.absent()
          : Value(trackCount),
    );
  }

  factory DbAlbum.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbAlbum(
      id: serializer.fromJson<String>(json['id']),
      providerId: serializer.fromJson<String?>(json['providerId']),
      sourceId: serializer.fromJson<String?>(json['sourceId']),
      title: serializer.fromJson<String>(json['title']),
      year: serializer.fromJson<int?>(json['year']),
      artworkId: serializer.fromJson<String?>(json['artworkId']),
      trackCount: serializer.fromJson<int?>(json['trackCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'providerId': serializer.toJson<String?>(providerId),
      'sourceId': serializer.toJson<String?>(sourceId),
      'title': serializer.toJson<String>(title),
      'year': serializer.toJson<int?>(year),
      'artworkId': serializer.toJson<String?>(artworkId),
      'trackCount': serializer.toJson<int?>(trackCount),
    };
  }

  DbAlbum copyWith({
    String? id,
    Value<String?> providerId = const Value.absent(),
    Value<String?> sourceId = const Value.absent(),
    String? title,
    Value<int?> year = const Value.absent(),
    Value<String?> artworkId = const Value.absent(),
    Value<int?> trackCount = const Value.absent(),
  }) => DbAlbum(
    id: id ?? this.id,
    providerId: providerId.present ? providerId.value : this.providerId,
    sourceId: sourceId.present ? sourceId.value : this.sourceId,
    title: title ?? this.title,
    year: year.present ? year.value : this.year,
    artworkId: artworkId.present ? artworkId.value : this.artworkId,
    trackCount: trackCount.present ? trackCount.value : this.trackCount,
  );
  DbAlbum copyWithCompanion(AlbumsCompanion data) {
    return DbAlbum(
      id: data.id.present ? data.id.value : this.id,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      title: data.title.present ? data.title.value : this.title,
      year: data.year.present ? data.year.value : this.year,
      artworkId: data.artworkId.present ? data.artworkId.value : this.artworkId,
      trackCount: data.trackCount.present
          ? data.trackCount.value
          : this.trackCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbAlbum(')
          ..write('id: $id, ')
          ..write('providerId: $providerId, ')
          ..write('sourceId: $sourceId, ')
          ..write('title: $title, ')
          ..write('year: $year, ')
          ..write('artworkId: $artworkId, ')
          ..write('trackCount: $trackCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, providerId, sourceId, title, year, artworkId, trackCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbAlbum &&
          other.id == this.id &&
          other.providerId == this.providerId &&
          other.sourceId == this.sourceId &&
          other.title == this.title &&
          other.year == this.year &&
          other.artworkId == this.artworkId &&
          other.trackCount == this.trackCount);
}

class AlbumsCompanion extends UpdateCompanion<DbAlbum> {
  final Value<String> id;
  final Value<String?> providerId;
  final Value<String?> sourceId;
  final Value<String> title;
  final Value<int?> year;
  final Value<String?> artworkId;
  final Value<int?> trackCount;
  final Value<int> rowid;
  const AlbumsCompanion({
    this.id = const Value.absent(),
    this.providerId = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.title = const Value.absent(),
    this.year = const Value.absent(),
    this.artworkId = const Value.absent(),
    this.trackCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlbumsCompanion.insert({
    required String id,
    this.providerId = const Value.absent(),
    this.sourceId = const Value.absent(),
    required String title,
    this.year = const Value.absent(),
    this.artworkId = const Value.absent(),
    this.trackCount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title);
  static Insertable<DbAlbum> custom({
    Expression<String>? id,
    Expression<String>? providerId,
    Expression<String>? sourceId,
    Expression<String>? title,
    Expression<int>? year,
    Expression<String>? artworkId,
    Expression<int>? trackCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (providerId != null) 'provider_id': providerId,
      if (sourceId != null) 'source_id': sourceId,
      if (title != null) 'title': title,
      if (year != null) 'year': year,
      if (artworkId != null) 'artwork_id': artworkId,
      if (trackCount != null) 'track_count': trackCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlbumsCompanion copyWith({
    Value<String>? id,
    Value<String?>? providerId,
    Value<String?>? sourceId,
    Value<String>? title,
    Value<int?>? year,
    Value<String?>? artworkId,
    Value<int?>? trackCount,
    Value<int>? rowid,
  }) {
    return AlbumsCompanion(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      sourceId: sourceId ?? this.sourceId,
      title: title ?? this.title,
      year: year ?? this.year,
      artworkId: artworkId ?? this.artworkId,
      trackCount: trackCount ?? this.trackCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (artworkId.present) {
      map['artwork_id'] = Variable<String>(artworkId.value);
    }
    if (trackCount.present) {
      map['track_count'] = Variable<int>(trackCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlbumsCompanion(')
          ..write('id: $id, ')
          ..write('providerId: $providerId, ')
          ..write('sourceId: $sourceId, ')
          ..write('title: $title, ')
          ..write('year: $year, ')
          ..write('artworkId: $artworkId, ')
          ..write('trackCount: $trackCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GenresTable extends Genres with TableInfo<$GenresTable, DbGenre> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GenresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'genres';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbGenre> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbGenre map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbGenre(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $GenresTable createAlias(String alias) {
    return $GenresTable(attachedDatabase, alias);
  }
}

class DbGenre extends DataClass implements Insertable<DbGenre> {
  /// Genre id.
  final String id;

  /// Display name (unique).
  final String name;
  const DbGenre({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  GenresCompanion toCompanion(bool nullToAbsent) {
    return GenresCompanion(id: Value(id), name: Value(name));
  }

  factory DbGenre.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbGenre(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  DbGenre copyWith({String? id, String? name}) =>
      DbGenre(id: id ?? this.id, name: name ?? this.name);
  DbGenre copyWithCompanion(GenresCompanion data) {
    return DbGenre(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbGenre(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbGenre && other.id == this.id && other.name == this.name);
}

class GenresCompanion extends UpdateCompanion<DbGenre> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> rowid;
  const GenresCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GenresCompanion.insert({
    required String id,
    required String name,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<DbGenre> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GenresCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return GenresCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GenresCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ArtworksTable extends Artworks
    with TableInfo<$ArtworksTable, DbArtwork> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArtworksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dominantArgbMeta = const VerificationMeta(
    'dominantArgb',
  );
  @override
  late final GeneratedColumn<int> dominantArgb = GeneratedColumn<int>(
    'dominant_argb',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    url,
    localPath,
    dominantArgb,
    width,
    height,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'artworks';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbArtwork> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    }
    if (data.containsKey('dominant_argb')) {
      context.handle(
        _dominantArgbMeta,
        dominantArgb.isAcceptableOrUnknown(
          data['dominant_argb']!,
          _dominantArgbMeta,
        ),
      );
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbArtwork map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbArtwork(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      ),
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      ),
      dominantArgb: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dominant_argb'],
      ),
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $ArtworksTable createAlias(String alias) {
    return $ArtworksTable(attachedDatabase, alias);
  }
}

class DbArtwork extends DataClass implements Insertable<DbArtwork> {
  /// Artwork id.
  final String id;

  /// Remote URL the bytes were fetched from, if any.
  final String? url;

  /// App-cache path of the persisted bytes, if any.
  final String? localPath;

  /// Dominant color as ARGB int.
  final int? dominantArgb;

  /// Pixel width, if known.
  final int? width;

  /// Pixel height, if known.
  final int? height;

  /// Last fetch/update time (UTC epoch ms).
  final int? updatedAt;
  const DbArtwork({
    required this.id,
    this.url,
    this.localPath,
    this.dominantArgb,
    this.width,
    this.height,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    if (!nullToAbsent || dominantArgb != null) {
      map['dominant_argb'] = Variable<int>(dominantArgb);
    }
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<int>(updatedAt);
    }
    return map;
  }

  ArtworksCompanion toCompanion(bool nullToAbsent) {
    return ArtworksCompanion(
      id: Value(id),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      dominantArgb: dominantArgb == null && nullToAbsent
          ? const Value.absent()
          : Value(dominantArgb),
      width: width == null && nullToAbsent
          ? const Value.absent()
          : Value(width),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory DbArtwork.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbArtwork(
      id: serializer.fromJson<String>(json['id']),
      url: serializer.fromJson<String?>(json['url']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      dominantArgb: serializer.fromJson<int?>(json['dominantArgb']),
      width: serializer.fromJson<int?>(json['width']),
      height: serializer.fromJson<int?>(json['height']),
      updatedAt: serializer.fromJson<int?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'url': serializer.toJson<String?>(url),
      'localPath': serializer.toJson<String?>(localPath),
      'dominantArgb': serializer.toJson<int?>(dominantArgb),
      'width': serializer.toJson<int?>(width),
      'height': serializer.toJson<int?>(height),
      'updatedAt': serializer.toJson<int?>(updatedAt),
    };
  }

  DbArtwork copyWith({
    String? id,
    Value<String?> url = const Value.absent(),
    Value<String?> localPath = const Value.absent(),
    Value<int?> dominantArgb = const Value.absent(),
    Value<int?> width = const Value.absent(),
    Value<int?> height = const Value.absent(),
    Value<int?> updatedAt = const Value.absent(),
  }) => DbArtwork(
    id: id ?? this.id,
    url: url.present ? url.value : this.url,
    localPath: localPath.present ? localPath.value : this.localPath,
    dominantArgb: dominantArgb.present ? dominantArgb.value : this.dominantArgb,
    width: width.present ? width.value : this.width,
    height: height.present ? height.value : this.height,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  DbArtwork copyWithCompanion(ArtworksCompanion data) {
    return DbArtwork(
      id: data.id.present ? data.id.value : this.id,
      url: data.url.present ? data.url.value : this.url,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      dominantArgb: data.dominantArgb.present
          ? data.dominantArgb.value
          : this.dominantArgb,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbArtwork(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('localPath: $localPath, ')
          ..write('dominantArgb: $dominantArgb, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, url, localPath, dominantArgb, width, height, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbArtwork &&
          other.id == this.id &&
          other.url == this.url &&
          other.localPath == this.localPath &&
          other.dominantArgb == this.dominantArgb &&
          other.width == this.width &&
          other.height == this.height &&
          other.updatedAt == this.updatedAt);
}

class ArtworksCompanion extends UpdateCompanion<DbArtwork> {
  final Value<String> id;
  final Value<String?> url;
  final Value<String?> localPath;
  final Value<int?> dominantArgb;
  final Value<int?> width;
  final Value<int?> height;
  final Value<int?> updatedAt;
  final Value<int> rowid;
  const ArtworksCompanion({
    this.id = const Value.absent(),
    this.url = const Value.absent(),
    this.localPath = const Value.absent(),
    this.dominantArgb = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ArtworksCompanion.insert({
    required String id,
    this.url = const Value.absent(),
    this.localPath = const Value.absent(),
    this.dominantArgb = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<DbArtwork> custom({
    Expression<String>? id,
    Expression<String>? url,
    Expression<String>? localPath,
    Expression<int>? dominantArgb,
    Expression<int>? width,
    Expression<int>? height,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (url != null) 'url': url,
      if (localPath != null) 'local_path': localPath,
      if (dominantArgb != null) 'dominant_argb': dominantArgb,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ArtworksCompanion copyWith({
    Value<String>? id,
    Value<String?>? url,
    Value<String?>? localPath,
    Value<int?>? dominantArgb,
    Value<int?>? width,
    Value<int?>? height,
    Value<int?>? updatedAt,
    Value<int>? rowid,
  }) {
    return ArtworksCompanion(
      id: id ?? this.id,
      url: url ?? this.url,
      localPath: localPath ?? this.localPath,
      dominantArgb: dominantArgb ?? this.dominantArgb,
      width: width ?? this.width,
      height: height ?? this.height,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (dominantArgb.present) {
      map['dominant_argb'] = Variable<int>(dominantArgb.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArtworksCompanion(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('localPath: $localPath, ')
          ..write('dominantArgb: $dominantArgb, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistsTable extends Playlists
    with TableInfo<$PlaylistsTable, DbPlaylist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artworkIdMeta = const VerificationMeta(
    'artworkId',
  );
  @override
  late final GeneratedColumn<String> artworkId = GeneratedColumn<String>(
    'artwork_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSystemMeta = const VerificationMeta(
    'isSystem',
  );
  @override
  late final GeneratedColumn<int> isSystem = GeneratedColumn<int>(
    'is_system',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    artworkId,
    isSystem,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlists';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbPlaylist> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('artwork_id')) {
      context.handle(
        _artworkIdMeta,
        artworkId.isAcceptableOrUnknown(data['artwork_id']!, _artworkIdMeta),
      );
    }
    if (data.containsKey('is_system')) {
      context.handle(
        _isSystemMeta,
        isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbPlaylist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbPlaylist(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      artworkId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artwork_id'],
      ),
      isSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_system'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $PlaylistsTable createAlias(String alias) {
    return $PlaylistsTable(attachedDatabase, alias);
  }
}

class DbPlaylist extends DataClass implements Insertable<DbPlaylist> {
  /// Playlist id (uuid v7; well-known strings for system lists).
  final String id;

  /// Display title.
  final String title;

  /// Optional user description.
  final String? description;

  /// Cover artwork id, if any.
  final String? artworkId;

  /// Built-in system playlist, as 0/1.
  final int isSystem;

  /// Creation time (UTC epoch ms).
  final int? createdAt;

  /// Last modification time (UTC epoch ms).
  final int? updatedAt;
  const DbPlaylist({
    required this.id,
    required this.title,
    this.description,
    this.artworkId,
    required this.isSystem,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || artworkId != null) {
      map['artwork_id'] = Variable<String>(artworkId);
    }
    map['is_system'] = Variable<int>(isSystem);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<int>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<int>(updatedAt);
    }
    return map;
  }

  PlaylistsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistsCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      artworkId: artworkId == null && nullToAbsent
          ? const Value.absent()
          : Value(artworkId),
      isSystem: Value(isSystem),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory DbPlaylist.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbPlaylist(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      artworkId: serializer.fromJson<String?>(json['artworkId']),
      isSystem: serializer.fromJson<int>(json['isSystem']),
      createdAt: serializer.fromJson<int?>(json['createdAt']),
      updatedAt: serializer.fromJson<int?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'artworkId': serializer.toJson<String?>(artworkId),
      'isSystem': serializer.toJson<int>(isSystem),
      'createdAt': serializer.toJson<int?>(createdAt),
      'updatedAt': serializer.toJson<int?>(updatedAt),
    };
  }

  DbPlaylist copyWith({
    String? id,
    String? title,
    Value<String?> description = const Value.absent(),
    Value<String?> artworkId = const Value.absent(),
    int? isSystem,
    Value<int?> createdAt = const Value.absent(),
    Value<int?> updatedAt = const Value.absent(),
  }) => DbPlaylist(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    artworkId: artworkId.present ? artworkId.value : this.artworkId,
    isSystem: isSystem ?? this.isSystem,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  DbPlaylist copyWithCompanion(PlaylistsCompanion data) {
    return DbPlaylist(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      artworkId: data.artworkId.present ? data.artworkId.value : this.artworkId,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbPlaylist(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('artworkId: $artworkId, ')
          ..write('isSystem: $isSystem, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    artworkId,
    isSystem,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbPlaylist &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.artworkId == this.artworkId &&
          other.isSystem == this.isSystem &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PlaylistsCompanion extends UpdateCompanion<DbPlaylist> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<String?> artworkId;
  final Value<int> isSystem;
  final Value<int?> createdAt;
  final Value<int?> updatedAt;
  final Value<int> rowid;
  const PlaylistsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.artworkId = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistsCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    this.artworkId = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title);
  static Insertable<DbPlaylist> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? artworkId,
    Expression<int>? isSystem,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (artworkId != null) 'artwork_id': artworkId,
      if (isSystem != null) 'is_system': isSystem,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? description,
    Value<String?>? artworkId,
    Value<int>? isSystem,
    Value<int?>? createdAt,
    Value<int?>? updatedAt,
    Value<int>? rowid,
  }) {
    return PlaylistsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      artworkId: artworkId ?? this.artworkId,
      isSystem: isSystem ?? this.isSystem,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (artworkId.present) {
      map['artwork_id'] = Variable<String>(artworkId.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<int>(isSystem.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('artworkId: $artworkId, ')
          ..write('isSystem: $isSystem, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistEntriesTable extends PlaylistEntries
    with TableInfo<$PlaylistEntriesTable, DbPlaylistEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playlistIdMeta = const VerificationMeta(
    'playlistId',
  );
  @override
  late final GeneratedColumn<String> playlistId = GeneratedColumn<String>(
    'playlist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<int> addedAt = GeneratedColumn<int>(
    'added_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    playlistId,
    trackId,
    position,
    addedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbPlaylistEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('playlist_id')) {
      context.handle(
        _playlistIdMeta,
        playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playlistId, trackId};
  @override
  DbPlaylistEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbPlaylistEntry(
      playlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}playlist_id'],
      )!,
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}added_at'],
      ),
    );
  }

  @override
  $PlaylistEntriesTable createAlias(String alias) {
    return $PlaylistEntriesTable(attachedDatabase, alias);
  }
}

class DbPlaylistEntry extends DataClass implements Insertable<DbPlaylistEntry> {
  /// Owning playlist id.
  final String playlistId;

  /// Member track id.
  final String trackId;

  /// Zero-based order inside the playlist.
  final int position;

  /// Time the track was added (UTC epoch ms).
  final int? addedAt;
  const DbPlaylistEntry({
    required this.playlistId,
    required this.trackId,
    required this.position,
    this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['playlist_id'] = Variable<String>(playlistId);
    map['track_id'] = Variable<String>(trackId);
    map['position'] = Variable<int>(position);
    if (!nullToAbsent || addedAt != null) {
      map['added_at'] = Variable<int>(addedAt);
    }
    return map;
  }

  PlaylistEntriesCompanion toCompanion(bool nullToAbsent) {
    return PlaylistEntriesCompanion(
      playlistId: Value(playlistId),
      trackId: Value(trackId),
      position: Value(position),
      addedAt: addedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(addedAt),
    );
  }

  factory DbPlaylistEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbPlaylistEntry(
      playlistId: serializer.fromJson<String>(json['playlistId']),
      trackId: serializer.fromJson<String>(json['trackId']),
      position: serializer.fromJson<int>(json['position']),
      addedAt: serializer.fromJson<int?>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playlistId': serializer.toJson<String>(playlistId),
      'trackId': serializer.toJson<String>(trackId),
      'position': serializer.toJson<int>(position),
      'addedAt': serializer.toJson<int?>(addedAt),
    };
  }

  DbPlaylistEntry copyWith({
    String? playlistId,
    String? trackId,
    int? position,
    Value<int?> addedAt = const Value.absent(),
  }) => DbPlaylistEntry(
    playlistId: playlistId ?? this.playlistId,
    trackId: trackId ?? this.trackId,
    position: position ?? this.position,
    addedAt: addedAt.present ? addedAt.value : this.addedAt,
  );
  DbPlaylistEntry copyWithCompanion(PlaylistEntriesCompanion data) {
    return DbPlaylistEntry(
      playlistId: data.playlistId.present
          ? data.playlistId.value
          : this.playlistId,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      position: data.position.present ? data.position.value : this.position,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbPlaylistEntry(')
          ..write('playlistId: $playlistId, ')
          ..write('trackId: $trackId, ')
          ..write('position: $position, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(playlistId, trackId, position, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbPlaylistEntry &&
          other.playlistId == this.playlistId &&
          other.trackId == this.trackId &&
          other.position == this.position &&
          other.addedAt == this.addedAt);
}

class PlaylistEntriesCompanion extends UpdateCompanion<DbPlaylistEntry> {
  final Value<String> playlistId;
  final Value<String> trackId;
  final Value<int> position;
  final Value<int?> addedAt;
  final Value<int> rowid;
  const PlaylistEntriesCompanion({
    this.playlistId = const Value.absent(),
    this.trackId = const Value.absent(),
    this.position = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistEntriesCompanion.insert({
    required String playlistId,
    required String trackId,
    this.position = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : playlistId = Value(playlistId),
       trackId = Value(trackId);
  static Insertable<DbPlaylistEntry> custom({
    Expression<String>? playlistId,
    Expression<String>? trackId,
    Expression<int>? position,
    Expression<int>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (playlistId != null) 'playlist_id': playlistId,
      if (trackId != null) 'track_id': trackId,
      if (position != null) 'position': position,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistEntriesCompanion copyWith({
    Value<String>? playlistId,
    Value<String>? trackId,
    Value<int>? position,
    Value<int?>? addedAt,
    Value<int>? rowid,
  }) {
    return PlaylistEntriesCompanion(
      playlistId: playlistId ?? this.playlistId,
      trackId: trackId ?? this.trackId,
      position: position ?? this.position,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<int>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistEntriesCompanion(')
          ..write('playlistId: $playlistId, ')
          ..write('trackId: $trackId, ')
          ..write('position: $position, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlayEventsTable extends PlayEvents
    with TableInfo<$PlayEventsTable, DbPlayEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<int> endedAt = GeneratedColumn<int>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _listenedMsMeta = const VerificationMeta(
    'listenedMs',
  );
  @override
  late final GeneratedColumn<int> listenedMs = GeneratedColumn<int>(
    'listened_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completionRatioMeta = const VerificationMeta(
    'completionRatio',
  );
  @override
  late final GeneratedColumn<double> completionRatio = GeneratedColumn<double>(
    'completion_ratio',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _skippedMeta = const VerificationMeta(
    'skipped',
  );
  @override
  late final GeneratedColumn<int> skipped = GeneratedColumn<int>(
    'skipped',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _skipAtMsMeta = const VerificationMeta(
    'skipAtMs',
  );
  @override
  late final GeneratedColumn<int> skipAtMs = GeneratedColumn<int>(
    'skip_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timeOfDayBucketMeta = const VerificationMeta(
    'timeOfDayBucket',
  );
  @override
  late final GeneratedColumn<String> timeOfDayBucket = GeneratedColumn<String>(
    'time_of_day_bucket',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dayOfWeekMeta = const VerificationMeta(
    'dayOfWeek',
  );
  @override
  late final GeneratedColumn<int> dayOfWeek = GeneratedColumn<int>(
    'day_of_week',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _playbackSpeedMeta = const VerificationMeta(
    'playbackSpeed',
  );
  @override
  late final GeneratedColumn<double> playbackSpeed = GeneratedColumn<double>(
    'playback_speed',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wasOfflineMeta = const VerificationMeta(
    'wasOffline',
  );
  @override
  late final GeneratedColumn<int> wasOffline = GeneratedColumn<int>(
    'was_offline',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seekCountMeta = const VerificationMeta(
    'seekCount',
  );
  @override
  late final GeneratedColumn<int> seekCount = GeneratedColumn<int>(
    'seek_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    trackId,
    sessionId,
    startedAt,
    endedAt,
    durationMs,
    listenedMs,
    completionRatio,
    skipped,
    skipAtMs,
    source,
    timeOfDayBucket,
    dayOfWeek,
    playbackSpeed,
    wasOffline,
    seekCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'play_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbPlayEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('listened_ms')) {
      context.handle(
        _listenedMsMeta,
        listenedMs.isAcceptableOrUnknown(data['listened_ms']!, _listenedMsMeta),
      );
    }
    if (data.containsKey('completion_ratio')) {
      context.handle(
        _completionRatioMeta,
        completionRatio.isAcceptableOrUnknown(
          data['completion_ratio']!,
          _completionRatioMeta,
        ),
      );
    }
    if (data.containsKey('skipped')) {
      context.handle(
        _skippedMeta,
        skipped.isAcceptableOrUnknown(data['skipped']!, _skippedMeta),
      );
    }
    if (data.containsKey('skip_at_ms')) {
      context.handle(
        _skipAtMsMeta,
        skipAtMs.isAcceptableOrUnknown(data['skip_at_ms']!, _skipAtMsMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('time_of_day_bucket')) {
      context.handle(
        _timeOfDayBucketMeta,
        timeOfDayBucket.isAcceptableOrUnknown(
          data['time_of_day_bucket']!,
          _timeOfDayBucketMeta,
        ),
      );
    }
    if (data.containsKey('day_of_week')) {
      context.handle(
        _dayOfWeekMeta,
        dayOfWeek.isAcceptableOrUnknown(data['day_of_week']!, _dayOfWeekMeta),
      );
    }
    if (data.containsKey('playback_speed')) {
      context.handle(
        _playbackSpeedMeta,
        playbackSpeed.isAcceptableOrUnknown(
          data['playback_speed']!,
          _playbackSpeedMeta,
        ),
      );
    }
    if (data.containsKey('was_offline')) {
      context.handle(
        _wasOfflineMeta,
        wasOffline.isAcceptableOrUnknown(data['was_offline']!, _wasOfflineMeta),
      );
    }
    if (data.containsKey('seek_count')) {
      context.handle(
        _seekCountMeta,
        seekCount.isAcceptableOrUnknown(data['seek_count']!, _seekCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbPlayEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbPlayEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ended_at'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      listenedMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}listened_ms'],
      ),
      completionRatio: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}completion_ratio'],
      ),
      skipped: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}skipped'],
      ),
      skipAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}skip_at_ms'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      ),
      timeOfDayBucket: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_of_day_bucket'],
      ),
      dayOfWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_of_week'],
      ),
      playbackSpeed: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}playback_speed'],
      ),
      wasOffline: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}was_offline'],
      ),
      seekCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seek_count'],
      ),
    );
  }

  @override
  $PlayEventsTable createAlias(String alias) {
    return $PlayEventsTable(attachedDatabase, alias);
  }
}

class DbPlayEvent extends DataClass implements Insertable<DbPlayEvent> {
  /// Event id (uuid v7).
  final String id;

  /// Played track id.
  final String trackId;

  /// Playback session id.
  final String sessionId;

  /// Playback start (UTC epoch ms).
  final int startedAt;

  /// Playback end, if the window closed (UTC epoch ms).
  final int? endedAt;

  /// Track length at play time, in milliseconds.
  final int? durationMs;

  /// Milliseconds actually heard.
  final int? listenedMs;

  /// `listenedMs / max(durationMs, 1)`, clamped 0..1.
  final double? completionRatio;

  /// User moved on before 0.85, as 0/1.
  final int? skipped;

  /// Position of the skip, if skipped.
  final int? skipAtMs;

  /// Where playback originated (PlaySource name).
  final String? source;

  /// Local-time bucket name.
  final String? timeOfDayBucket;

  /// `startedAt.weekday % 7`.
  final int? dayOfWeek;

  /// Playback speed multiplier.
  final double? playbackSpeed;

  /// Device was offline during playback, as 0/1.
  final int? wasOffline;

  /// Seek gestures observed during this event.
  final int? seekCount;
  const DbPlayEvent({
    required this.id,
    required this.trackId,
    required this.sessionId,
    required this.startedAt,
    this.endedAt,
    this.durationMs,
    this.listenedMs,
    this.completionRatio,
    this.skipped,
    this.skipAtMs,
    this.source,
    this.timeOfDayBucket,
    this.dayOfWeek,
    this.playbackSpeed,
    this.wasOffline,
    this.seekCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['track_id'] = Variable<String>(trackId);
    map['session_id'] = Variable<String>(sessionId);
    map['started_at'] = Variable<int>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<int>(endedAt);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || listenedMs != null) {
      map['listened_ms'] = Variable<int>(listenedMs);
    }
    if (!nullToAbsent || completionRatio != null) {
      map['completion_ratio'] = Variable<double>(completionRatio);
    }
    if (!nullToAbsent || skipped != null) {
      map['skipped'] = Variable<int>(skipped);
    }
    if (!nullToAbsent || skipAtMs != null) {
      map['skip_at_ms'] = Variable<int>(skipAtMs);
    }
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    if (!nullToAbsent || timeOfDayBucket != null) {
      map['time_of_day_bucket'] = Variable<String>(timeOfDayBucket);
    }
    if (!nullToAbsent || dayOfWeek != null) {
      map['day_of_week'] = Variable<int>(dayOfWeek);
    }
    if (!nullToAbsent || playbackSpeed != null) {
      map['playback_speed'] = Variable<double>(playbackSpeed);
    }
    if (!nullToAbsent || wasOffline != null) {
      map['was_offline'] = Variable<int>(wasOffline);
    }
    if (!nullToAbsent || seekCount != null) {
      map['seek_count'] = Variable<int>(seekCount);
    }
    return map;
  }

  PlayEventsCompanion toCompanion(bool nullToAbsent) {
    return PlayEventsCompanion(
      id: Value(id),
      trackId: Value(trackId),
      sessionId: Value(sessionId),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      listenedMs: listenedMs == null && nullToAbsent
          ? const Value.absent()
          : Value(listenedMs),
      completionRatio: completionRatio == null && nullToAbsent
          ? const Value.absent()
          : Value(completionRatio),
      skipped: skipped == null && nullToAbsent
          ? const Value.absent()
          : Value(skipped),
      skipAtMs: skipAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(skipAtMs),
      source: source == null && nullToAbsent
          ? const Value.absent()
          : Value(source),
      timeOfDayBucket: timeOfDayBucket == null && nullToAbsent
          ? const Value.absent()
          : Value(timeOfDayBucket),
      dayOfWeek: dayOfWeek == null && nullToAbsent
          ? const Value.absent()
          : Value(dayOfWeek),
      playbackSpeed: playbackSpeed == null && nullToAbsent
          ? const Value.absent()
          : Value(playbackSpeed),
      wasOffline: wasOffline == null && nullToAbsent
          ? const Value.absent()
          : Value(wasOffline),
      seekCount: seekCount == null && nullToAbsent
          ? const Value.absent()
          : Value(seekCount),
    );
  }

  factory DbPlayEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbPlayEvent(
      id: serializer.fromJson<String>(json['id']),
      trackId: serializer.fromJson<String>(json['trackId']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      startedAt: serializer.fromJson<int>(json['startedAt']),
      endedAt: serializer.fromJson<int?>(json['endedAt']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      listenedMs: serializer.fromJson<int?>(json['listenedMs']),
      completionRatio: serializer.fromJson<double?>(json['completionRatio']),
      skipped: serializer.fromJson<int?>(json['skipped']),
      skipAtMs: serializer.fromJson<int?>(json['skipAtMs']),
      source: serializer.fromJson<String?>(json['source']),
      timeOfDayBucket: serializer.fromJson<String?>(json['timeOfDayBucket']),
      dayOfWeek: serializer.fromJson<int?>(json['dayOfWeek']),
      playbackSpeed: serializer.fromJson<double?>(json['playbackSpeed']),
      wasOffline: serializer.fromJson<int?>(json['wasOffline']),
      seekCount: serializer.fromJson<int?>(json['seekCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'trackId': serializer.toJson<String>(trackId),
      'sessionId': serializer.toJson<String>(sessionId),
      'startedAt': serializer.toJson<int>(startedAt),
      'endedAt': serializer.toJson<int?>(endedAt),
      'durationMs': serializer.toJson<int?>(durationMs),
      'listenedMs': serializer.toJson<int?>(listenedMs),
      'completionRatio': serializer.toJson<double?>(completionRatio),
      'skipped': serializer.toJson<int?>(skipped),
      'skipAtMs': serializer.toJson<int?>(skipAtMs),
      'source': serializer.toJson<String?>(source),
      'timeOfDayBucket': serializer.toJson<String?>(timeOfDayBucket),
      'dayOfWeek': serializer.toJson<int?>(dayOfWeek),
      'playbackSpeed': serializer.toJson<double?>(playbackSpeed),
      'wasOffline': serializer.toJson<int?>(wasOffline),
      'seekCount': serializer.toJson<int?>(seekCount),
    };
  }

  DbPlayEvent copyWith({
    String? id,
    String? trackId,
    String? sessionId,
    int? startedAt,
    Value<int?> endedAt = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    Value<int?> listenedMs = const Value.absent(),
    Value<double?> completionRatio = const Value.absent(),
    Value<int?> skipped = const Value.absent(),
    Value<int?> skipAtMs = const Value.absent(),
    Value<String?> source = const Value.absent(),
    Value<String?> timeOfDayBucket = const Value.absent(),
    Value<int?> dayOfWeek = const Value.absent(),
    Value<double?> playbackSpeed = const Value.absent(),
    Value<int?> wasOffline = const Value.absent(),
    Value<int?> seekCount = const Value.absent(),
  }) => DbPlayEvent(
    id: id ?? this.id,
    trackId: trackId ?? this.trackId,
    sessionId: sessionId ?? this.sessionId,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    listenedMs: listenedMs.present ? listenedMs.value : this.listenedMs,
    completionRatio: completionRatio.present
        ? completionRatio.value
        : this.completionRatio,
    skipped: skipped.present ? skipped.value : this.skipped,
    skipAtMs: skipAtMs.present ? skipAtMs.value : this.skipAtMs,
    source: source.present ? source.value : this.source,
    timeOfDayBucket: timeOfDayBucket.present
        ? timeOfDayBucket.value
        : this.timeOfDayBucket,
    dayOfWeek: dayOfWeek.present ? dayOfWeek.value : this.dayOfWeek,
    playbackSpeed: playbackSpeed.present
        ? playbackSpeed.value
        : this.playbackSpeed,
    wasOffline: wasOffline.present ? wasOffline.value : this.wasOffline,
    seekCount: seekCount.present ? seekCount.value : this.seekCount,
  );
  DbPlayEvent copyWithCompanion(PlayEventsCompanion data) {
    return DbPlayEvent(
      id: data.id.present ? data.id.value : this.id,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      listenedMs: data.listenedMs.present
          ? data.listenedMs.value
          : this.listenedMs,
      completionRatio: data.completionRatio.present
          ? data.completionRatio.value
          : this.completionRatio,
      skipped: data.skipped.present ? data.skipped.value : this.skipped,
      skipAtMs: data.skipAtMs.present ? data.skipAtMs.value : this.skipAtMs,
      source: data.source.present ? data.source.value : this.source,
      timeOfDayBucket: data.timeOfDayBucket.present
          ? data.timeOfDayBucket.value
          : this.timeOfDayBucket,
      dayOfWeek: data.dayOfWeek.present ? data.dayOfWeek.value : this.dayOfWeek,
      playbackSpeed: data.playbackSpeed.present
          ? data.playbackSpeed.value
          : this.playbackSpeed,
      wasOffline: data.wasOffline.present
          ? data.wasOffline.value
          : this.wasOffline,
      seekCount: data.seekCount.present ? data.seekCount.value : this.seekCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbPlayEvent(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('sessionId: $sessionId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationMs: $durationMs, ')
          ..write('listenedMs: $listenedMs, ')
          ..write('completionRatio: $completionRatio, ')
          ..write('skipped: $skipped, ')
          ..write('skipAtMs: $skipAtMs, ')
          ..write('source: $source, ')
          ..write('timeOfDayBucket: $timeOfDayBucket, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('playbackSpeed: $playbackSpeed, ')
          ..write('wasOffline: $wasOffline, ')
          ..write('seekCount: $seekCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    trackId,
    sessionId,
    startedAt,
    endedAt,
    durationMs,
    listenedMs,
    completionRatio,
    skipped,
    skipAtMs,
    source,
    timeOfDayBucket,
    dayOfWeek,
    playbackSpeed,
    wasOffline,
    seekCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbPlayEvent &&
          other.id == this.id &&
          other.trackId == this.trackId &&
          other.sessionId == this.sessionId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.durationMs == this.durationMs &&
          other.listenedMs == this.listenedMs &&
          other.completionRatio == this.completionRatio &&
          other.skipped == this.skipped &&
          other.skipAtMs == this.skipAtMs &&
          other.source == this.source &&
          other.timeOfDayBucket == this.timeOfDayBucket &&
          other.dayOfWeek == this.dayOfWeek &&
          other.playbackSpeed == this.playbackSpeed &&
          other.wasOffline == this.wasOffline &&
          other.seekCount == this.seekCount);
}

class PlayEventsCompanion extends UpdateCompanion<DbPlayEvent> {
  final Value<String> id;
  final Value<String> trackId;
  final Value<String> sessionId;
  final Value<int> startedAt;
  final Value<int?> endedAt;
  final Value<int?> durationMs;
  final Value<int?> listenedMs;
  final Value<double?> completionRatio;
  final Value<int?> skipped;
  final Value<int?> skipAtMs;
  final Value<String?> source;
  final Value<String?> timeOfDayBucket;
  final Value<int?> dayOfWeek;
  final Value<double?> playbackSpeed;
  final Value<int?> wasOffline;
  final Value<int?> seekCount;
  final Value<int> rowid;
  const PlayEventsCompanion({
    this.id = const Value.absent(),
    this.trackId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.listenedMs = const Value.absent(),
    this.completionRatio = const Value.absent(),
    this.skipped = const Value.absent(),
    this.skipAtMs = const Value.absent(),
    this.source = const Value.absent(),
    this.timeOfDayBucket = const Value.absent(),
    this.dayOfWeek = const Value.absent(),
    this.playbackSpeed = const Value.absent(),
    this.wasOffline = const Value.absent(),
    this.seekCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlayEventsCompanion.insert({
    required String id,
    required String trackId,
    required String sessionId,
    required int startedAt,
    this.endedAt = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.listenedMs = const Value.absent(),
    this.completionRatio = const Value.absent(),
    this.skipped = const Value.absent(),
    this.skipAtMs = const Value.absent(),
    this.source = const Value.absent(),
    this.timeOfDayBucket = const Value.absent(),
    this.dayOfWeek = const Value.absent(),
    this.playbackSpeed = const Value.absent(),
    this.wasOffline = const Value.absent(),
    this.seekCount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       trackId = Value(trackId),
       sessionId = Value(sessionId),
       startedAt = Value(startedAt);
  static Insertable<DbPlayEvent> custom({
    Expression<String>? id,
    Expression<String>? trackId,
    Expression<String>? sessionId,
    Expression<int>? startedAt,
    Expression<int>? endedAt,
    Expression<int>? durationMs,
    Expression<int>? listenedMs,
    Expression<double>? completionRatio,
    Expression<int>? skipped,
    Expression<int>? skipAtMs,
    Expression<String>? source,
    Expression<String>? timeOfDayBucket,
    Expression<int>? dayOfWeek,
    Expression<double>? playbackSpeed,
    Expression<int>? wasOffline,
    Expression<int>? seekCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (trackId != null) 'track_id': trackId,
      if (sessionId != null) 'session_id': sessionId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (durationMs != null) 'duration_ms': durationMs,
      if (listenedMs != null) 'listened_ms': listenedMs,
      if (completionRatio != null) 'completion_ratio': completionRatio,
      if (skipped != null) 'skipped': skipped,
      if (skipAtMs != null) 'skip_at_ms': skipAtMs,
      if (source != null) 'source': source,
      if (timeOfDayBucket != null) 'time_of_day_bucket': timeOfDayBucket,
      if (dayOfWeek != null) 'day_of_week': dayOfWeek,
      if (playbackSpeed != null) 'playback_speed': playbackSpeed,
      if (wasOffline != null) 'was_offline': wasOffline,
      if (seekCount != null) 'seek_count': seekCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlayEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? trackId,
    Value<String>? sessionId,
    Value<int>? startedAt,
    Value<int?>? endedAt,
    Value<int?>? durationMs,
    Value<int?>? listenedMs,
    Value<double?>? completionRatio,
    Value<int?>? skipped,
    Value<int?>? skipAtMs,
    Value<String?>? source,
    Value<String?>? timeOfDayBucket,
    Value<int?>? dayOfWeek,
    Value<double?>? playbackSpeed,
    Value<int?>? wasOffline,
    Value<int?>? seekCount,
    Value<int>? rowid,
  }) {
    return PlayEventsCompanion(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      sessionId: sessionId ?? this.sessionId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationMs: durationMs ?? this.durationMs,
      listenedMs: listenedMs ?? this.listenedMs,
      completionRatio: completionRatio ?? this.completionRatio,
      skipped: skipped ?? this.skipped,
      skipAtMs: skipAtMs ?? this.skipAtMs,
      source: source ?? this.source,
      timeOfDayBucket: timeOfDayBucket ?? this.timeOfDayBucket,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      wasOffline: wasOffline ?? this.wasOffline,
      seekCount: seekCount ?? this.seekCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<int>(endedAt.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (listenedMs.present) {
      map['listened_ms'] = Variable<int>(listenedMs.value);
    }
    if (completionRatio.present) {
      map['completion_ratio'] = Variable<double>(completionRatio.value);
    }
    if (skipped.present) {
      map['skipped'] = Variable<int>(skipped.value);
    }
    if (skipAtMs.present) {
      map['skip_at_ms'] = Variable<int>(skipAtMs.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (timeOfDayBucket.present) {
      map['time_of_day_bucket'] = Variable<String>(timeOfDayBucket.value);
    }
    if (dayOfWeek.present) {
      map['day_of_week'] = Variable<int>(dayOfWeek.value);
    }
    if (playbackSpeed.present) {
      map['playback_speed'] = Variable<double>(playbackSpeed.value);
    }
    if (wasOffline.present) {
      map['was_offline'] = Variable<int>(wasOffline.value);
    }
    if (seekCount.present) {
      map['seek_count'] = Variable<int>(seekCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayEventsCompanion(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('sessionId: $sessionId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationMs: $durationMs, ')
          ..write('listenedMs: $listenedMs, ')
          ..write('completionRatio: $completionRatio, ')
          ..write('skipped: $skipped, ')
          ..write('skipAtMs: $skipAtMs, ')
          ..write('source: $source, ')
          ..write('timeOfDayBucket: $timeOfDayBucket, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('playbackSpeed: $playbackSpeed, ')
          ..write('wasOffline: $wasOffline, ')
          ..write('seekCount: $seekCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserTrackStatsTable extends UserTrackStats
    with TableInfo<$UserTrackStatsTable, DbUserTrackStat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserTrackStatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playCountMeta = const VerificationMeta(
    'playCount',
  );
  @override
  late final GeneratedColumn<int> playCount = GeneratedColumn<int>(
    'play_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _skipCountMeta = const VerificationMeta(
    'skipCount',
  );
  @override
  late final GeneratedColumn<int> skipCount = GeneratedColumn<int>(
    'skip_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completeCountMeta = const VerificationMeta(
    'completeCount',
  );
  @override
  late final GeneratedColumn<int> completeCount = GeneratedColumn<int>(
    'complete_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _replayCountMeta = const VerificationMeta(
    'replayCount',
  );
  @override
  late final GeneratedColumn<int> replayCount = GeneratedColumn<int>(
    'replay_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalListenMsMeta = const VerificationMeta(
    'totalListenMs',
  );
  @override
  late final GeneratedColumn<int> totalListenMs = GeneratedColumn<int>(
    'total_listen_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastPlayedAtMeta = const VerificationMeta(
    'lastPlayedAt',
  );
  @override
  late final GeneratedColumn<int> lastPlayedAt = GeneratedColumn<int>(
    'last_played_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _likeStateMeta = const VerificationMeta(
    'likeState',
  );
  @override
  late final GeneratedColumn<int> likeState = GeneratedColumn<int>(
    'like_state',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _decayedScoreMeta = const VerificationMeta(
    'decayedScore',
  );
  @override
  late final GeneratedColumn<double> decayedScore = GeneratedColumn<double>(
    'decayed_score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    trackId,
    playCount,
    skipCount,
    completeCount,
    replayCount,
    totalListenMs,
    lastPlayedAt,
    likeState,
    decayedScore,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_track_stats';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbUserTrackStat> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('play_count')) {
      context.handle(
        _playCountMeta,
        playCount.isAcceptableOrUnknown(data['play_count']!, _playCountMeta),
      );
    }
    if (data.containsKey('skip_count')) {
      context.handle(
        _skipCountMeta,
        skipCount.isAcceptableOrUnknown(data['skip_count']!, _skipCountMeta),
      );
    }
    if (data.containsKey('complete_count')) {
      context.handle(
        _completeCountMeta,
        completeCount.isAcceptableOrUnknown(
          data['complete_count']!,
          _completeCountMeta,
        ),
      );
    }
    if (data.containsKey('replay_count')) {
      context.handle(
        _replayCountMeta,
        replayCount.isAcceptableOrUnknown(
          data['replay_count']!,
          _replayCountMeta,
        ),
      );
    }
    if (data.containsKey('total_listen_ms')) {
      context.handle(
        _totalListenMsMeta,
        totalListenMs.isAcceptableOrUnknown(
          data['total_listen_ms']!,
          _totalListenMsMeta,
        ),
      );
    }
    if (data.containsKey('last_played_at')) {
      context.handle(
        _lastPlayedAtMeta,
        lastPlayedAt.isAcceptableOrUnknown(
          data['last_played_at']!,
          _lastPlayedAtMeta,
        ),
      );
    }
    if (data.containsKey('like_state')) {
      context.handle(
        _likeStateMeta,
        likeState.isAcceptableOrUnknown(data['like_state']!, _likeStateMeta),
      );
    }
    if (data.containsKey('decayed_score')) {
      context.handle(
        _decayedScoreMeta,
        decayedScore.isAcceptableOrUnknown(
          data['decayed_score']!,
          _decayedScoreMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {trackId};
  @override
  DbUserTrackStat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbUserTrackStat(
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      playCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}play_count'],
      ),
      skipCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}skip_count'],
      ),
      completeCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}complete_count'],
      ),
      replayCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}replay_count'],
      ),
      totalListenMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_listen_ms'],
      ),
      lastPlayedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_played_at'],
      ),
      likeState: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}like_state'],
      ),
      decayedScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}decayed_score'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $UserTrackStatsTable createAlias(String alias) {
    return $UserTrackStatsTable(attachedDatabase, alias);
  }
}

class DbUserTrackStat extends DataClass implements Insertable<DbUserTrackStat> {
  /// Observed track id.
  final String trackId;

  /// Started plays (noise-filtered).
  final int? playCount;

  /// Skipped plays.
  final int? skipCount;

  /// Plays with `completionRatio` >= 0.85.
  final int? completeCount;

  /// Restarts within 10s of a complete (or replays within 30s).
  final int? replayCount;

  /// Total heard milliseconds across all plays.
  final int? totalListenMs;

  /// Last play time (UTC epoch ms).
  final int? lastPlayedAt;

  /// -1 dislike, 0 none, 1 like.
  final int? likeState;

  /// Time-decayed aggregate score.
  final double? decayedScore;

  /// Last update time (UTC epoch ms).
  final int? updatedAt;
  const DbUserTrackStat({
    required this.trackId,
    this.playCount,
    this.skipCount,
    this.completeCount,
    this.replayCount,
    this.totalListenMs,
    this.lastPlayedAt,
    this.likeState,
    this.decayedScore,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['track_id'] = Variable<String>(trackId);
    if (!nullToAbsent || playCount != null) {
      map['play_count'] = Variable<int>(playCount);
    }
    if (!nullToAbsent || skipCount != null) {
      map['skip_count'] = Variable<int>(skipCount);
    }
    if (!nullToAbsent || completeCount != null) {
      map['complete_count'] = Variable<int>(completeCount);
    }
    if (!nullToAbsent || replayCount != null) {
      map['replay_count'] = Variable<int>(replayCount);
    }
    if (!nullToAbsent || totalListenMs != null) {
      map['total_listen_ms'] = Variable<int>(totalListenMs);
    }
    if (!nullToAbsent || lastPlayedAt != null) {
      map['last_played_at'] = Variable<int>(lastPlayedAt);
    }
    if (!nullToAbsent || likeState != null) {
      map['like_state'] = Variable<int>(likeState);
    }
    if (!nullToAbsent || decayedScore != null) {
      map['decayed_score'] = Variable<double>(decayedScore);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<int>(updatedAt);
    }
    return map;
  }

  UserTrackStatsCompanion toCompanion(bool nullToAbsent) {
    return UserTrackStatsCompanion(
      trackId: Value(trackId),
      playCount: playCount == null && nullToAbsent
          ? const Value.absent()
          : Value(playCount),
      skipCount: skipCount == null && nullToAbsent
          ? const Value.absent()
          : Value(skipCount),
      completeCount: completeCount == null && nullToAbsent
          ? const Value.absent()
          : Value(completeCount),
      replayCount: replayCount == null && nullToAbsent
          ? const Value.absent()
          : Value(replayCount),
      totalListenMs: totalListenMs == null && nullToAbsent
          ? const Value.absent()
          : Value(totalListenMs),
      lastPlayedAt: lastPlayedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPlayedAt),
      likeState: likeState == null && nullToAbsent
          ? const Value.absent()
          : Value(likeState),
      decayedScore: decayedScore == null && nullToAbsent
          ? const Value.absent()
          : Value(decayedScore),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory DbUserTrackStat.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbUserTrackStat(
      trackId: serializer.fromJson<String>(json['trackId']),
      playCount: serializer.fromJson<int?>(json['playCount']),
      skipCount: serializer.fromJson<int?>(json['skipCount']),
      completeCount: serializer.fromJson<int?>(json['completeCount']),
      replayCount: serializer.fromJson<int?>(json['replayCount']),
      totalListenMs: serializer.fromJson<int?>(json['totalListenMs']),
      lastPlayedAt: serializer.fromJson<int?>(json['lastPlayedAt']),
      likeState: serializer.fromJson<int?>(json['likeState']),
      decayedScore: serializer.fromJson<double?>(json['decayedScore']),
      updatedAt: serializer.fromJson<int?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trackId': serializer.toJson<String>(trackId),
      'playCount': serializer.toJson<int?>(playCount),
      'skipCount': serializer.toJson<int?>(skipCount),
      'completeCount': serializer.toJson<int?>(completeCount),
      'replayCount': serializer.toJson<int?>(replayCount),
      'totalListenMs': serializer.toJson<int?>(totalListenMs),
      'lastPlayedAt': serializer.toJson<int?>(lastPlayedAt),
      'likeState': serializer.toJson<int?>(likeState),
      'decayedScore': serializer.toJson<double?>(decayedScore),
      'updatedAt': serializer.toJson<int?>(updatedAt),
    };
  }

  DbUserTrackStat copyWith({
    String? trackId,
    Value<int?> playCount = const Value.absent(),
    Value<int?> skipCount = const Value.absent(),
    Value<int?> completeCount = const Value.absent(),
    Value<int?> replayCount = const Value.absent(),
    Value<int?> totalListenMs = const Value.absent(),
    Value<int?> lastPlayedAt = const Value.absent(),
    Value<int?> likeState = const Value.absent(),
    Value<double?> decayedScore = const Value.absent(),
    Value<int?> updatedAt = const Value.absent(),
  }) => DbUserTrackStat(
    trackId: trackId ?? this.trackId,
    playCount: playCount.present ? playCount.value : this.playCount,
    skipCount: skipCount.present ? skipCount.value : this.skipCount,
    completeCount: completeCount.present
        ? completeCount.value
        : this.completeCount,
    replayCount: replayCount.present ? replayCount.value : this.replayCount,
    totalListenMs: totalListenMs.present
        ? totalListenMs.value
        : this.totalListenMs,
    lastPlayedAt: lastPlayedAt.present ? lastPlayedAt.value : this.lastPlayedAt,
    likeState: likeState.present ? likeState.value : this.likeState,
    decayedScore: decayedScore.present ? decayedScore.value : this.decayedScore,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  DbUserTrackStat copyWithCompanion(UserTrackStatsCompanion data) {
    return DbUserTrackStat(
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      playCount: data.playCount.present ? data.playCount.value : this.playCount,
      skipCount: data.skipCount.present ? data.skipCount.value : this.skipCount,
      completeCount: data.completeCount.present
          ? data.completeCount.value
          : this.completeCount,
      replayCount: data.replayCount.present
          ? data.replayCount.value
          : this.replayCount,
      totalListenMs: data.totalListenMs.present
          ? data.totalListenMs.value
          : this.totalListenMs,
      lastPlayedAt: data.lastPlayedAt.present
          ? data.lastPlayedAt.value
          : this.lastPlayedAt,
      likeState: data.likeState.present ? data.likeState.value : this.likeState,
      decayedScore: data.decayedScore.present
          ? data.decayedScore.value
          : this.decayedScore,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbUserTrackStat(')
          ..write('trackId: $trackId, ')
          ..write('playCount: $playCount, ')
          ..write('skipCount: $skipCount, ')
          ..write('completeCount: $completeCount, ')
          ..write('replayCount: $replayCount, ')
          ..write('totalListenMs: $totalListenMs, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('likeState: $likeState, ')
          ..write('decayedScore: $decayedScore, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    trackId,
    playCount,
    skipCount,
    completeCount,
    replayCount,
    totalListenMs,
    lastPlayedAt,
    likeState,
    decayedScore,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbUserTrackStat &&
          other.trackId == this.trackId &&
          other.playCount == this.playCount &&
          other.skipCount == this.skipCount &&
          other.completeCount == this.completeCount &&
          other.replayCount == this.replayCount &&
          other.totalListenMs == this.totalListenMs &&
          other.lastPlayedAt == this.lastPlayedAt &&
          other.likeState == this.likeState &&
          other.decayedScore == this.decayedScore &&
          other.updatedAt == this.updatedAt);
}

class UserTrackStatsCompanion extends UpdateCompanion<DbUserTrackStat> {
  final Value<String> trackId;
  final Value<int?> playCount;
  final Value<int?> skipCount;
  final Value<int?> completeCount;
  final Value<int?> replayCount;
  final Value<int?> totalListenMs;
  final Value<int?> lastPlayedAt;
  final Value<int?> likeState;
  final Value<double?> decayedScore;
  final Value<int?> updatedAt;
  final Value<int> rowid;
  const UserTrackStatsCompanion({
    this.trackId = const Value.absent(),
    this.playCount = const Value.absent(),
    this.skipCount = const Value.absent(),
    this.completeCount = const Value.absent(),
    this.replayCount = const Value.absent(),
    this.totalListenMs = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    this.likeState = const Value.absent(),
    this.decayedScore = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserTrackStatsCompanion.insert({
    required String trackId,
    this.playCount = const Value.absent(),
    this.skipCount = const Value.absent(),
    this.completeCount = const Value.absent(),
    this.replayCount = const Value.absent(),
    this.totalListenMs = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    this.likeState = const Value.absent(),
    this.decayedScore = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : trackId = Value(trackId);
  static Insertable<DbUserTrackStat> custom({
    Expression<String>? trackId,
    Expression<int>? playCount,
    Expression<int>? skipCount,
    Expression<int>? completeCount,
    Expression<int>? replayCount,
    Expression<int>? totalListenMs,
    Expression<int>? lastPlayedAt,
    Expression<int>? likeState,
    Expression<double>? decayedScore,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (trackId != null) 'track_id': trackId,
      if (playCount != null) 'play_count': playCount,
      if (skipCount != null) 'skip_count': skipCount,
      if (completeCount != null) 'complete_count': completeCount,
      if (replayCount != null) 'replay_count': replayCount,
      if (totalListenMs != null) 'total_listen_ms': totalListenMs,
      if (lastPlayedAt != null) 'last_played_at': lastPlayedAt,
      if (likeState != null) 'like_state': likeState,
      if (decayedScore != null) 'decayed_score': decayedScore,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserTrackStatsCompanion copyWith({
    Value<String>? trackId,
    Value<int?>? playCount,
    Value<int?>? skipCount,
    Value<int?>? completeCount,
    Value<int?>? replayCount,
    Value<int?>? totalListenMs,
    Value<int?>? lastPlayedAt,
    Value<int?>? likeState,
    Value<double?>? decayedScore,
    Value<int?>? updatedAt,
    Value<int>? rowid,
  }) {
    return UserTrackStatsCompanion(
      trackId: trackId ?? this.trackId,
      playCount: playCount ?? this.playCount,
      skipCount: skipCount ?? this.skipCount,
      completeCount: completeCount ?? this.completeCount,
      replayCount: replayCount ?? this.replayCount,
      totalListenMs: totalListenMs ?? this.totalListenMs,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      likeState: likeState ?? this.likeState,
      decayedScore: decayedScore ?? this.decayedScore,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (playCount.present) {
      map['play_count'] = Variable<int>(playCount.value);
    }
    if (skipCount.present) {
      map['skip_count'] = Variable<int>(skipCount.value);
    }
    if (completeCount.present) {
      map['complete_count'] = Variable<int>(completeCount.value);
    }
    if (replayCount.present) {
      map['replay_count'] = Variable<int>(replayCount.value);
    }
    if (totalListenMs.present) {
      map['total_listen_ms'] = Variable<int>(totalListenMs.value);
    }
    if (lastPlayedAt.present) {
      map['last_played_at'] = Variable<int>(lastPlayedAt.value);
    }
    if (likeState.present) {
      map['like_state'] = Variable<int>(likeState.value);
    }
    if (decayedScore.present) {
      map['decayed_score'] = Variable<double>(decayedScore.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserTrackStatsCompanion(')
          ..write('trackId: $trackId, ')
          ..write('playCount: $playCount, ')
          ..write('skipCount: $skipCount, ')
          ..write('completeCount: $completeCount, ')
          ..write('replayCount: $replayCount, ')
          ..write('totalListenMs: $totalListenMs, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('likeState: $likeState, ')
          ..write('decayedScore: $decayedScore, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PreferenceProfileTable extends PreferenceProfile
    with TableInfo<$PreferenceProfileTable, DbPreferenceProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreferenceProfileTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, version, json, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'preference_profile';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbPreferenceProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbPreferenceProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbPreferenceProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      ),
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $PreferenceProfileTable createAlias(String alias) {
    return $PreferenceProfileTable(attachedDatabase, alias);
  }
}

class DbPreferenceProfile extends DataClass
    implements Insertable<DbPreferenceProfile> {
  /// Always 1 (single-row table).
  final int id;

  /// Schema version (starts at 1).
  final int? version;

  /// Versioned JSON payload.
  final String json;

  /// Last update time (UTC epoch ms).
  final int? updatedAt;
  const DbPreferenceProfile({
    required this.id,
    this.version,
    required this.json,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || version != null) {
      map['version'] = Variable<int>(version);
    }
    map['json'] = Variable<String>(json);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<int>(updatedAt);
    }
    return map;
  }

  PreferenceProfileCompanion toCompanion(bool nullToAbsent) {
    return PreferenceProfileCompanion(
      id: Value(id),
      version: version == null && nullToAbsent
          ? const Value.absent()
          : Value(version),
      json: Value(json),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory DbPreferenceProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbPreferenceProfile(
      id: serializer.fromJson<int>(json['id']),
      version: serializer.fromJson<int?>(json['version']),
      json: serializer.fromJson<String>(json['json']),
      updatedAt: serializer.fromJson<int?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'version': serializer.toJson<int?>(version),
      'json': serializer.toJson<String>(json),
      'updatedAt': serializer.toJson<int?>(updatedAt),
    };
  }

  DbPreferenceProfile copyWith({
    int? id,
    Value<int?> version = const Value.absent(),
    String? json,
    Value<int?> updatedAt = const Value.absent(),
  }) => DbPreferenceProfile(
    id: id ?? this.id,
    version: version.present ? version.value : this.version,
    json: json ?? this.json,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  DbPreferenceProfile copyWithCompanion(PreferenceProfileCompanion data) {
    return DbPreferenceProfile(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
      json: data.json.present ? data.json.value : this.json,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbPreferenceProfile(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('json: $json, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, version, json, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbPreferenceProfile &&
          other.id == this.id &&
          other.version == this.version &&
          other.json == this.json &&
          other.updatedAt == this.updatedAt);
}

class PreferenceProfileCompanion extends UpdateCompanion<DbPreferenceProfile> {
  final Value<int> id;
  final Value<int?> version;
  final Value<String> json;
  final Value<int?> updatedAt;
  const PreferenceProfileCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
    this.json = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PreferenceProfileCompanion.insert({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
    required String json,
    this.updatedAt = const Value.absent(),
  }) : json = Value(json);
  static Insertable<DbPreferenceProfile> custom({
    Expression<int>? id,
    Expression<int>? version,
    Expression<String>? json,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
      if (json != null) 'json': json,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PreferenceProfileCompanion copyWith({
    Value<int>? id,
    Value<int?>? version,
    Value<String>? json,
    Value<int?>? updatedAt,
  }) {
    return PreferenceProfileCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
      json: json ?? this.json,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PreferenceProfileCompanion(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('json: $json, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $QueueItemsTable extends QueueItems
    with TableInfo<$QueueItemsTable, DbQueueItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QueueItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _frozenScoreMeta = const VerificationMeta(
    'frozenScore',
  );
  @override
  late final GeneratedColumn<double> frozenScore = GeneratedColumn<double>(
    'frozen_score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<int> addedAt = GeneratedColumn<int>(
    'added_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    trackId,
    origin,
    position,
    frozenScore,
    addedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'queue_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbQueueItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('frozen_score')) {
      context.handle(
        _frozenScoreMeta,
        frozenScore.isAcceptableOrUnknown(
          data['frozen_score']!,
          _frozenScoreMeta,
        ),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbQueueItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbQueueItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      ),
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      frozenScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}frozen_score'],
      ),
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}added_at'],
      ),
    );
  }

  @override
  $QueueItemsTable createAlias(String alias) {
    return $QueueItemsTable(attachedDatabase, alias);
  }
}

class DbQueueItem extends DataClass implements Insertable<DbQueueItem> {
  /// Queue row id (uuid v7).
  final String id;

  /// Queued track id.
  final String? trackId;

  /// Where the item was enqueued from (PlaySource name).
  final String? origin;

  /// Zero-based order.
  final int position;

  /// Ranker score frozen at enqueue time, if ranked.
  final double? frozenScore;

  /// Enqueue time (UTC epoch ms).
  final int? addedAt;
  const DbQueueItem({
    required this.id,
    this.trackId,
    this.origin,
    required this.position,
    this.frozenScore,
    this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || trackId != null) {
      map['track_id'] = Variable<String>(trackId);
    }
    if (!nullToAbsent || origin != null) {
      map['origin'] = Variable<String>(origin);
    }
    map['position'] = Variable<int>(position);
    if (!nullToAbsent || frozenScore != null) {
      map['frozen_score'] = Variable<double>(frozenScore);
    }
    if (!nullToAbsent || addedAt != null) {
      map['added_at'] = Variable<int>(addedAt);
    }
    return map;
  }

  QueueItemsCompanion toCompanion(bool nullToAbsent) {
    return QueueItemsCompanion(
      id: Value(id),
      trackId: trackId == null && nullToAbsent
          ? const Value.absent()
          : Value(trackId),
      origin: origin == null && nullToAbsent
          ? const Value.absent()
          : Value(origin),
      position: Value(position),
      frozenScore: frozenScore == null && nullToAbsent
          ? const Value.absent()
          : Value(frozenScore),
      addedAt: addedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(addedAt),
    );
  }

  factory DbQueueItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbQueueItem(
      id: serializer.fromJson<String>(json['id']),
      trackId: serializer.fromJson<String?>(json['trackId']),
      origin: serializer.fromJson<String?>(json['origin']),
      position: serializer.fromJson<int>(json['position']),
      frozenScore: serializer.fromJson<double?>(json['frozenScore']),
      addedAt: serializer.fromJson<int?>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'trackId': serializer.toJson<String?>(trackId),
      'origin': serializer.toJson<String?>(origin),
      'position': serializer.toJson<int>(position),
      'frozenScore': serializer.toJson<double?>(frozenScore),
      'addedAt': serializer.toJson<int?>(addedAt),
    };
  }

  DbQueueItem copyWith({
    String? id,
    Value<String?> trackId = const Value.absent(),
    Value<String?> origin = const Value.absent(),
    int? position,
    Value<double?> frozenScore = const Value.absent(),
    Value<int?> addedAt = const Value.absent(),
  }) => DbQueueItem(
    id: id ?? this.id,
    trackId: trackId.present ? trackId.value : this.trackId,
    origin: origin.present ? origin.value : this.origin,
    position: position ?? this.position,
    frozenScore: frozenScore.present ? frozenScore.value : this.frozenScore,
    addedAt: addedAt.present ? addedAt.value : this.addedAt,
  );
  DbQueueItem copyWithCompanion(QueueItemsCompanion data) {
    return DbQueueItem(
      id: data.id.present ? data.id.value : this.id,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      origin: data.origin.present ? data.origin.value : this.origin,
      position: data.position.present ? data.position.value : this.position,
      frozenScore: data.frozenScore.present
          ? data.frozenScore.value
          : this.frozenScore,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbQueueItem(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('origin: $origin, ')
          ..write('position: $position, ')
          ..write('frozenScore: $frozenScore, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, trackId, origin, position, frozenScore, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbQueueItem &&
          other.id == this.id &&
          other.trackId == this.trackId &&
          other.origin == this.origin &&
          other.position == this.position &&
          other.frozenScore == this.frozenScore &&
          other.addedAt == this.addedAt);
}

class QueueItemsCompanion extends UpdateCompanion<DbQueueItem> {
  final Value<String> id;
  final Value<String?> trackId;
  final Value<String?> origin;
  final Value<int> position;
  final Value<double?> frozenScore;
  final Value<int?> addedAt;
  final Value<int> rowid;
  const QueueItemsCompanion({
    this.id = const Value.absent(),
    this.trackId = const Value.absent(),
    this.origin = const Value.absent(),
    this.position = const Value.absent(),
    this.frozenScore = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QueueItemsCompanion.insert({
    required String id,
    this.trackId = const Value.absent(),
    this.origin = const Value.absent(),
    this.position = const Value.absent(),
    this.frozenScore = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<DbQueueItem> custom({
    Expression<String>? id,
    Expression<String>? trackId,
    Expression<String>? origin,
    Expression<int>? position,
    Expression<double>? frozenScore,
    Expression<int>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (trackId != null) 'track_id': trackId,
      if (origin != null) 'origin': origin,
      if (position != null) 'position': position,
      if (frozenScore != null) 'frozen_score': frozenScore,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QueueItemsCompanion copyWith({
    Value<String>? id,
    Value<String?>? trackId,
    Value<String?>? origin,
    Value<int>? position,
    Value<double?>? frozenScore,
    Value<int?>? addedAt,
    Value<int>? rowid,
  }) {
    return QueueItemsCompanion(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      origin: origin ?? this.origin,
      position: position ?? this.position,
      frozenScore: frozenScore ?? this.frozenScore,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (frozenScore.present) {
      map['frozen_score'] = Variable<double>(frozenScore.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<int>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QueueItemsCompanion(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('origin: $origin, ')
          ..write('position: $position, ')
          ..write('frozenScore: $frozenScore, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaybackStateTable extends PlaybackState
    with TableInfo<$PlaybackStateTable, DbPlaybackState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaybackStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMsMeta = const VerificationMeta(
    'positionMs',
  );
  @override
  late final GeneratedColumn<int> positionMs = GeneratedColumn<int>(
    'position_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPlayingMeta = const VerificationMeta(
    'isPlaying',
  );
  @override
  late final GeneratedColumn<int> isPlaying = GeneratedColumn<int>(
    'is_playing',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shuffleMeta = const VerificationMeta(
    'shuffle',
  );
  @override
  late final GeneratedColumn<int> shuffle = GeneratedColumn<int>(
    'shuffle',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repeatModeMeta = const VerificationMeta(
    'repeatMode',
  );
  @override
  late final GeneratedColumn<String> repeatMode = GeneratedColumn<String>(
    'repeat_mode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    trackId,
    positionMs,
    isPlaying,
    shuffle,
    repeatMode,
    sessionId,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playback_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbPlaybackState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    }
    if (data.containsKey('position_ms')) {
      context.handle(
        _positionMsMeta,
        positionMs.isAcceptableOrUnknown(data['position_ms']!, _positionMsMeta),
      );
    }
    if (data.containsKey('is_playing')) {
      context.handle(
        _isPlayingMeta,
        isPlaying.isAcceptableOrUnknown(data['is_playing']!, _isPlayingMeta),
      );
    }
    if (data.containsKey('shuffle')) {
      context.handle(
        _shuffleMeta,
        shuffle.isAcceptableOrUnknown(data['shuffle']!, _shuffleMeta),
      );
    }
    if (data.containsKey('repeat_mode')) {
      context.handle(
        _repeatModeMeta,
        repeatMode.isAcceptableOrUnknown(data['repeat_mode']!, _repeatModeMeta),
      );
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbPlaybackState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbPlaybackState(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      ),
      positionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_ms'],
      ),
      isPlaying: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_playing'],
      ),
      shuffle: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shuffle'],
      ),
      repeatMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat_mode'],
      ),
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $PlaybackStateTable createAlias(String alias) {
    return $PlaybackStateTable(attachedDatabase, alias);
  }
}

class DbPlaybackState extends DataClass implements Insertable<DbPlaybackState> {
  /// Always 1 (single-row table).
  final int id;

  /// Current track id, if any.
  final String? trackId;

  /// Resume position in milliseconds.
  final int? positionMs;

  /// Whether audio was playing, as 0/1.
  final int? isPlaying;

  /// Shuffle enabled, as 0/1.
  final int? shuffle;

  /// Repeat mode (`off|one|all`).
  final String? repeatMode;

  /// Playback session id (uuid).
  final String? sessionId;

  /// Last update time (UTC epoch ms).
  final int? updatedAt;
  const DbPlaybackState({
    required this.id,
    this.trackId,
    this.positionMs,
    this.isPlaying,
    this.shuffle,
    this.repeatMode,
    this.sessionId,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || trackId != null) {
      map['track_id'] = Variable<String>(trackId);
    }
    if (!nullToAbsent || positionMs != null) {
      map['position_ms'] = Variable<int>(positionMs);
    }
    if (!nullToAbsent || isPlaying != null) {
      map['is_playing'] = Variable<int>(isPlaying);
    }
    if (!nullToAbsent || shuffle != null) {
      map['shuffle'] = Variable<int>(shuffle);
    }
    if (!nullToAbsent || repeatMode != null) {
      map['repeat_mode'] = Variable<String>(repeatMode);
    }
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<String>(sessionId);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<int>(updatedAt);
    }
    return map;
  }

  PlaybackStateCompanion toCompanion(bool nullToAbsent) {
    return PlaybackStateCompanion(
      id: Value(id),
      trackId: trackId == null && nullToAbsent
          ? const Value.absent()
          : Value(trackId),
      positionMs: positionMs == null && nullToAbsent
          ? const Value.absent()
          : Value(positionMs),
      isPlaying: isPlaying == null && nullToAbsent
          ? const Value.absent()
          : Value(isPlaying),
      shuffle: shuffle == null && nullToAbsent
          ? const Value.absent()
          : Value(shuffle),
      repeatMode: repeatMode == null && nullToAbsent
          ? const Value.absent()
          : Value(repeatMode),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory DbPlaybackState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbPlaybackState(
      id: serializer.fromJson<int>(json['id']),
      trackId: serializer.fromJson<String?>(json['trackId']),
      positionMs: serializer.fromJson<int?>(json['positionMs']),
      isPlaying: serializer.fromJson<int?>(json['isPlaying']),
      shuffle: serializer.fromJson<int?>(json['shuffle']),
      repeatMode: serializer.fromJson<String?>(json['repeatMode']),
      sessionId: serializer.fromJson<String?>(json['sessionId']),
      updatedAt: serializer.fromJson<int?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'trackId': serializer.toJson<String?>(trackId),
      'positionMs': serializer.toJson<int?>(positionMs),
      'isPlaying': serializer.toJson<int?>(isPlaying),
      'shuffle': serializer.toJson<int?>(shuffle),
      'repeatMode': serializer.toJson<String?>(repeatMode),
      'sessionId': serializer.toJson<String?>(sessionId),
      'updatedAt': serializer.toJson<int?>(updatedAt),
    };
  }

  DbPlaybackState copyWith({
    int? id,
    Value<String?> trackId = const Value.absent(),
    Value<int?> positionMs = const Value.absent(),
    Value<int?> isPlaying = const Value.absent(),
    Value<int?> shuffle = const Value.absent(),
    Value<String?> repeatMode = const Value.absent(),
    Value<String?> sessionId = const Value.absent(),
    Value<int?> updatedAt = const Value.absent(),
  }) => DbPlaybackState(
    id: id ?? this.id,
    trackId: trackId.present ? trackId.value : this.trackId,
    positionMs: positionMs.present ? positionMs.value : this.positionMs,
    isPlaying: isPlaying.present ? isPlaying.value : this.isPlaying,
    shuffle: shuffle.present ? shuffle.value : this.shuffle,
    repeatMode: repeatMode.present ? repeatMode.value : this.repeatMode,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  DbPlaybackState copyWithCompanion(PlaybackStateCompanion data) {
    return DbPlaybackState(
      id: data.id.present ? data.id.value : this.id,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      positionMs: data.positionMs.present
          ? data.positionMs.value
          : this.positionMs,
      isPlaying: data.isPlaying.present ? data.isPlaying.value : this.isPlaying,
      shuffle: data.shuffle.present ? data.shuffle.value : this.shuffle,
      repeatMode: data.repeatMode.present
          ? data.repeatMode.value
          : this.repeatMode,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbPlaybackState(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('positionMs: $positionMs, ')
          ..write('isPlaying: $isPlaying, ')
          ..write('shuffle: $shuffle, ')
          ..write('repeatMode: $repeatMode, ')
          ..write('sessionId: $sessionId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    trackId,
    positionMs,
    isPlaying,
    shuffle,
    repeatMode,
    sessionId,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbPlaybackState &&
          other.id == this.id &&
          other.trackId == this.trackId &&
          other.positionMs == this.positionMs &&
          other.isPlaying == this.isPlaying &&
          other.shuffle == this.shuffle &&
          other.repeatMode == this.repeatMode &&
          other.sessionId == this.sessionId &&
          other.updatedAt == this.updatedAt);
}

class PlaybackStateCompanion extends UpdateCompanion<DbPlaybackState> {
  final Value<int> id;
  final Value<String?> trackId;
  final Value<int?> positionMs;
  final Value<int?> isPlaying;
  final Value<int?> shuffle;
  final Value<String?> repeatMode;
  final Value<String?> sessionId;
  final Value<int?> updatedAt;
  const PlaybackStateCompanion({
    this.id = const Value.absent(),
    this.trackId = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.isPlaying = const Value.absent(),
    this.shuffle = const Value.absent(),
    this.repeatMode = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PlaybackStateCompanion.insert({
    this.id = const Value.absent(),
    this.trackId = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.isPlaying = const Value.absent(),
    this.shuffle = const Value.absent(),
    this.repeatMode = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<DbPlaybackState> custom({
    Expression<int>? id,
    Expression<String>? trackId,
    Expression<int>? positionMs,
    Expression<int>? isPlaying,
    Expression<int>? shuffle,
    Expression<String>? repeatMode,
    Expression<String>? sessionId,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (trackId != null) 'track_id': trackId,
      if (positionMs != null) 'position_ms': positionMs,
      if (isPlaying != null) 'is_playing': isPlaying,
      if (shuffle != null) 'shuffle': shuffle,
      if (repeatMode != null) 'repeat_mode': repeatMode,
      if (sessionId != null) 'session_id': sessionId,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PlaybackStateCompanion copyWith({
    Value<int>? id,
    Value<String?>? trackId,
    Value<int?>? positionMs,
    Value<int?>? isPlaying,
    Value<int?>? shuffle,
    Value<String?>? repeatMode,
    Value<String?>? sessionId,
    Value<int?>? updatedAt,
  }) {
    return PlaybackStateCompanion(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      positionMs: positionMs ?? this.positionMs,
      isPlaying: isPlaying ?? this.isPlaying,
      shuffle: shuffle ?? this.shuffle,
      repeatMode: repeatMode ?? this.repeatMode,
      sessionId: sessionId ?? this.sessionId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (positionMs.present) {
      map['position_ms'] = Variable<int>(positionMs.value);
    }
    if (isPlaying.present) {
      map['is_playing'] = Variable<int>(isPlaying.value);
    }
    if (shuffle.present) {
      map['shuffle'] = Variable<int>(shuffle.value);
    }
    if (repeatMode.present) {
      map['repeat_mode'] = Variable<String>(repeatMode.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackStateCompanion(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('positionMs: $positionMs, ')
          ..write('isPlaying: $isPlaying, ')
          ..write('shuffle: $shuffle, ')
          ..write('repeatMode: $repeatMode, ')
          ..write('sessionId: $sessionId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $DownloadJobsTable extends DownloadJobs
    with TableInfo<$DownloadJobsTable, DbDownloadJob> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadJobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _progressMeta = const VerificationMeta(
    'progress',
  );
  @override
  late final GeneratedColumn<double> progress = GeneratedColumn<double>(
    'progress',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bytesReceivedMeta = const VerificationMeta(
    'bytesReceived',
  );
  @override
  late final GeneratedColumn<int> bytesReceived = GeneratedColumn<int>(
    'bytes_received',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bytesTotalMeta = const VerificationMeta(
    'bytesTotal',
  );
  @override
  late final GeneratedColumn<int> bytesTotal = GeneratedColumn<int>(
    'bytes_total',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorCodeMeta = const VerificationMeta(
    'errorCode',
  );
  @override
  late final GeneratedColumn<String> errorCode = GeneratedColumn<String>(
    'error_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _qualityLabelMeta = const VerificationMeta(
    'qualityLabel',
  );
  @override
  late final GeneratedColumn<String> qualityLabel = GeneratedColumn<String>(
    'quality_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    trackId,
    state,
    progress,
    bytesReceived,
    bytesTotal,
    errorCode,
    errorMessage,
    attempts,
    qualityLabel,
    filePath,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_jobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbDownloadJob> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('progress')) {
      context.handle(
        _progressMeta,
        progress.isAcceptableOrUnknown(data['progress']!, _progressMeta),
      );
    }
    if (data.containsKey('bytes_received')) {
      context.handle(
        _bytesReceivedMeta,
        bytesReceived.isAcceptableOrUnknown(
          data['bytes_received']!,
          _bytesReceivedMeta,
        ),
      );
    }
    if (data.containsKey('bytes_total')) {
      context.handle(
        _bytesTotalMeta,
        bytesTotal.isAcceptableOrUnknown(data['bytes_total']!, _bytesTotalMeta),
      );
    }
    if (data.containsKey('error_code')) {
      context.handle(
        _errorCodeMeta,
        errorCode.isAcceptableOrUnknown(data['error_code']!, _errorCodeMeta),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('quality_label')) {
      context.handle(
        _qualityLabelMeta,
        qualityLabel.isAcceptableOrUnknown(
          data['quality_label']!,
          _qualityLabelMeta,
        ),
      );
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbDownloadJob map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbDownloadJob(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      ),
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      ),
      progress: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}progress'],
      ),
      bytesReceived: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bytes_received'],
      ),
      bytesTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bytes_total'],
      ),
      errorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_code'],
      ),
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      ),
      qualityLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quality_label'],
      ),
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $DownloadJobsTable createAlias(String alias) {
    return $DownloadJobsTable(attachedDatabase, alias);
  }
}

class DbDownloadJob extends DataClass implements Insertable<DbDownloadJob> {
  /// Job id (uuid v7).
  final String id;

  /// Track being persisted.
  final String? trackId;

  /// Lifecycle state (DownloadState name).
  final String? state;

  /// 0..1 progress of the active phase.
  final double? progress;

  /// Bytes received so far.
  final int? bytesReceived;

  /// Expected total bytes, when reported.
  final int? bytesTotal;

  /// Machine-readable failure code of the last attempt.
  final String? errorCode;

  /// Human-readable failure message of the last attempt.
  final String? errorMessage;

  /// Attempts made so far (drives backoff, caps at 5).
  final int? attempts;

  /// Quality label used for this job.
  final String? qualityLabel;

  /// Persisted file path once completed.
  final String? filePath;

  /// Creation time (UTC epoch ms).
  final int? createdAt;

  /// Last update time (UTC epoch ms).
  final int? updatedAt;
  const DbDownloadJob({
    required this.id,
    this.trackId,
    this.state,
    this.progress,
    this.bytesReceived,
    this.bytesTotal,
    this.errorCode,
    this.errorMessage,
    this.attempts,
    this.qualityLabel,
    this.filePath,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || trackId != null) {
      map['track_id'] = Variable<String>(trackId);
    }
    if (!nullToAbsent || state != null) {
      map['state'] = Variable<String>(state);
    }
    if (!nullToAbsent || progress != null) {
      map['progress'] = Variable<double>(progress);
    }
    if (!nullToAbsent || bytesReceived != null) {
      map['bytes_received'] = Variable<int>(bytesReceived);
    }
    if (!nullToAbsent || bytesTotal != null) {
      map['bytes_total'] = Variable<int>(bytesTotal);
    }
    if (!nullToAbsent || errorCode != null) {
      map['error_code'] = Variable<String>(errorCode);
    }
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    if (!nullToAbsent || attempts != null) {
      map['attempts'] = Variable<int>(attempts);
    }
    if (!nullToAbsent || qualityLabel != null) {
      map['quality_label'] = Variable<String>(qualityLabel);
    }
    if (!nullToAbsent || filePath != null) {
      map['file_path'] = Variable<String>(filePath);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<int>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<int>(updatedAt);
    }
    return map;
  }

  DownloadJobsCompanion toCompanion(bool nullToAbsent) {
    return DownloadJobsCompanion(
      id: Value(id),
      trackId: trackId == null && nullToAbsent
          ? const Value.absent()
          : Value(trackId),
      state: state == null && nullToAbsent
          ? const Value.absent()
          : Value(state),
      progress: progress == null && nullToAbsent
          ? const Value.absent()
          : Value(progress),
      bytesReceived: bytesReceived == null && nullToAbsent
          ? const Value.absent()
          : Value(bytesReceived),
      bytesTotal: bytesTotal == null && nullToAbsent
          ? const Value.absent()
          : Value(bytesTotal),
      errorCode: errorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(errorCode),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      attempts: attempts == null && nullToAbsent
          ? const Value.absent()
          : Value(attempts),
      qualityLabel: qualityLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(qualityLabel),
      filePath: filePath == null && nullToAbsent
          ? const Value.absent()
          : Value(filePath),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory DbDownloadJob.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbDownloadJob(
      id: serializer.fromJson<String>(json['id']),
      trackId: serializer.fromJson<String?>(json['trackId']),
      state: serializer.fromJson<String?>(json['state']),
      progress: serializer.fromJson<double?>(json['progress']),
      bytesReceived: serializer.fromJson<int?>(json['bytesReceived']),
      bytesTotal: serializer.fromJson<int?>(json['bytesTotal']),
      errorCode: serializer.fromJson<String?>(json['errorCode']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      attempts: serializer.fromJson<int?>(json['attempts']),
      qualityLabel: serializer.fromJson<String?>(json['qualityLabel']),
      filePath: serializer.fromJson<String?>(json['filePath']),
      createdAt: serializer.fromJson<int?>(json['createdAt']),
      updatedAt: serializer.fromJson<int?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'trackId': serializer.toJson<String?>(trackId),
      'state': serializer.toJson<String?>(state),
      'progress': serializer.toJson<double?>(progress),
      'bytesReceived': serializer.toJson<int?>(bytesReceived),
      'bytesTotal': serializer.toJson<int?>(bytesTotal),
      'errorCode': serializer.toJson<String?>(errorCode),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'attempts': serializer.toJson<int?>(attempts),
      'qualityLabel': serializer.toJson<String?>(qualityLabel),
      'filePath': serializer.toJson<String?>(filePath),
      'createdAt': serializer.toJson<int?>(createdAt),
      'updatedAt': serializer.toJson<int?>(updatedAt),
    };
  }

  DbDownloadJob copyWith({
    String? id,
    Value<String?> trackId = const Value.absent(),
    Value<String?> state = const Value.absent(),
    Value<double?> progress = const Value.absent(),
    Value<int?> bytesReceived = const Value.absent(),
    Value<int?> bytesTotal = const Value.absent(),
    Value<String?> errorCode = const Value.absent(),
    Value<String?> errorMessage = const Value.absent(),
    Value<int?> attempts = const Value.absent(),
    Value<String?> qualityLabel = const Value.absent(),
    Value<String?> filePath = const Value.absent(),
    Value<int?> createdAt = const Value.absent(),
    Value<int?> updatedAt = const Value.absent(),
  }) => DbDownloadJob(
    id: id ?? this.id,
    trackId: trackId.present ? trackId.value : this.trackId,
    state: state.present ? state.value : this.state,
    progress: progress.present ? progress.value : this.progress,
    bytesReceived: bytesReceived.present
        ? bytesReceived.value
        : this.bytesReceived,
    bytesTotal: bytesTotal.present ? bytesTotal.value : this.bytesTotal,
    errorCode: errorCode.present ? errorCode.value : this.errorCode,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    attempts: attempts.present ? attempts.value : this.attempts,
    qualityLabel: qualityLabel.present ? qualityLabel.value : this.qualityLabel,
    filePath: filePath.present ? filePath.value : this.filePath,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  DbDownloadJob copyWithCompanion(DownloadJobsCompanion data) {
    return DbDownloadJob(
      id: data.id.present ? data.id.value : this.id,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      state: data.state.present ? data.state.value : this.state,
      progress: data.progress.present ? data.progress.value : this.progress,
      bytesReceived: data.bytesReceived.present
          ? data.bytesReceived.value
          : this.bytesReceived,
      bytesTotal: data.bytesTotal.present
          ? data.bytesTotal.value
          : this.bytesTotal,
      errorCode: data.errorCode.present ? data.errorCode.value : this.errorCode,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      qualityLabel: data.qualityLabel.present
          ? data.qualityLabel.value
          : this.qualityLabel,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbDownloadJob(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('state: $state, ')
          ..write('progress: $progress, ')
          ..write('bytesReceived: $bytesReceived, ')
          ..write('bytesTotal: $bytesTotal, ')
          ..write('errorCode: $errorCode, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('attempts: $attempts, ')
          ..write('qualityLabel: $qualityLabel, ')
          ..write('filePath: $filePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    trackId,
    state,
    progress,
    bytesReceived,
    bytesTotal,
    errorCode,
    errorMessage,
    attempts,
    qualityLabel,
    filePath,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbDownloadJob &&
          other.id == this.id &&
          other.trackId == this.trackId &&
          other.state == this.state &&
          other.progress == this.progress &&
          other.bytesReceived == this.bytesReceived &&
          other.bytesTotal == this.bytesTotal &&
          other.errorCode == this.errorCode &&
          other.errorMessage == this.errorMessage &&
          other.attempts == this.attempts &&
          other.qualityLabel == this.qualityLabel &&
          other.filePath == this.filePath &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DownloadJobsCompanion extends UpdateCompanion<DbDownloadJob> {
  final Value<String> id;
  final Value<String?> trackId;
  final Value<String?> state;
  final Value<double?> progress;
  final Value<int?> bytesReceived;
  final Value<int?> bytesTotal;
  final Value<String?> errorCode;
  final Value<String?> errorMessage;
  final Value<int?> attempts;
  final Value<String?> qualityLabel;
  final Value<String?> filePath;
  final Value<int?> createdAt;
  final Value<int?> updatedAt;
  final Value<int> rowid;
  const DownloadJobsCompanion({
    this.id = const Value.absent(),
    this.trackId = const Value.absent(),
    this.state = const Value.absent(),
    this.progress = const Value.absent(),
    this.bytesReceived = const Value.absent(),
    this.bytesTotal = const Value.absent(),
    this.errorCode = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.attempts = const Value.absent(),
    this.qualityLabel = const Value.absent(),
    this.filePath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadJobsCompanion.insert({
    required String id,
    this.trackId = const Value.absent(),
    this.state = const Value.absent(),
    this.progress = const Value.absent(),
    this.bytesReceived = const Value.absent(),
    this.bytesTotal = const Value.absent(),
    this.errorCode = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.attempts = const Value.absent(),
    this.qualityLabel = const Value.absent(),
    this.filePath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<DbDownloadJob> custom({
    Expression<String>? id,
    Expression<String>? trackId,
    Expression<String>? state,
    Expression<double>? progress,
    Expression<int>? bytesReceived,
    Expression<int>? bytesTotal,
    Expression<String>? errorCode,
    Expression<String>? errorMessage,
    Expression<int>? attempts,
    Expression<String>? qualityLabel,
    Expression<String>? filePath,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (trackId != null) 'track_id': trackId,
      if (state != null) 'state': state,
      if (progress != null) 'progress': progress,
      if (bytesReceived != null) 'bytes_received': bytesReceived,
      if (bytesTotal != null) 'bytes_total': bytesTotal,
      if (errorCode != null) 'error_code': errorCode,
      if (errorMessage != null) 'error_message': errorMessage,
      if (attempts != null) 'attempts': attempts,
      if (qualityLabel != null) 'quality_label': qualityLabel,
      if (filePath != null) 'file_path': filePath,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadJobsCompanion copyWith({
    Value<String>? id,
    Value<String?>? trackId,
    Value<String?>? state,
    Value<double?>? progress,
    Value<int?>? bytesReceived,
    Value<int?>? bytesTotal,
    Value<String?>? errorCode,
    Value<String?>? errorMessage,
    Value<int?>? attempts,
    Value<String?>? qualityLabel,
    Value<String?>? filePath,
    Value<int?>? createdAt,
    Value<int?>? updatedAt,
    Value<int>? rowid,
  }) {
    return DownloadJobsCompanion(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      state: state ?? this.state,
      progress: progress ?? this.progress,
      bytesReceived: bytesReceived ?? this.bytesReceived,
      bytesTotal: bytesTotal ?? this.bytesTotal,
      errorCode: errorCode ?? this.errorCode,
      errorMessage: errorMessage ?? this.errorMessage,
      attempts: attempts ?? this.attempts,
      qualityLabel: qualityLabel ?? this.qualityLabel,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (progress.present) {
      map['progress'] = Variable<double>(progress.value);
    }
    if (bytesReceived.present) {
      map['bytes_received'] = Variable<int>(bytesReceived.value);
    }
    if (bytesTotal.present) {
      map['bytes_total'] = Variable<int>(bytesTotal.value);
    }
    if (errorCode.present) {
      map['error_code'] = Variable<String>(errorCode.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (qualityLabel.present) {
      map['quality_label'] = Variable<String>(qualityLabel.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadJobsCompanion(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('state: $state, ')
          ..write('progress: $progress, ')
          ..write('bytesReceived: $bytesReceived, ')
          ..write('bytesTotal: $bytesTotal, ')
          ..write('errorCode: $errorCode, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('attempts: $attempts, ')
          ..write('qualityLabel: $qualityLabel, ')
          ..write('filePath: $filePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SearchHistoryTable extends SearchHistory
    with TableInfo<$SearchHistoryTable, DbSearchHistory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SearchHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _queryMeta = const VerificationMeta('query');
  @override
  late final GeneratedColumn<String> query = GeneratedColumn<String>(
    'query',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, query, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'search_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbSearchHistory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('query')) {
      context.handle(
        _queryMeta,
        query.isAcceptableOrUnknown(data['query']!, _queryMeta),
      );
    } else if (isInserting) {
      context.missing(_queryMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbSearchHistory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbSearchHistory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      query: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}query'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      ),
    );
  }

  @override
  $SearchHistoryTable createAlias(String alias) {
    return $SearchHistoryTable(attachedDatabase, alias);
  }
}

class DbSearchHistory extends DataClass implements Insertable<DbSearchHistory> {
  /// Row id (uuid v7).
  final String id;

  /// Raw query text.
  final String query;

  /// Creation time (UTC epoch ms).
  final int? createdAt;
  const DbSearchHistory({
    required this.id,
    required this.query,
    this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['query'] = Variable<String>(query);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<int>(createdAt);
    }
    return map;
  }

  SearchHistoryCompanion toCompanion(bool nullToAbsent) {
    return SearchHistoryCompanion(
      id: Value(id),
      query: Value(query),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
    );
  }

  factory DbSearchHistory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbSearchHistory(
      id: serializer.fromJson<String>(json['id']),
      query: serializer.fromJson<String>(json['query']),
      createdAt: serializer.fromJson<int?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'query': serializer.toJson<String>(query),
      'createdAt': serializer.toJson<int?>(createdAt),
    };
  }

  DbSearchHistory copyWith({
    String? id,
    String? query,
    Value<int?> createdAt = const Value.absent(),
  }) => DbSearchHistory(
    id: id ?? this.id,
    query: query ?? this.query,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
  );
  DbSearchHistory copyWithCompanion(SearchHistoryCompanion data) {
    return DbSearchHistory(
      id: data.id.present ? data.id.value : this.id,
      query: data.query.present ? data.query.value : this.query,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbSearchHistory(')
          ..write('id: $id, ')
          ..write('query: $query, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, query, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbSearchHistory &&
          other.id == this.id &&
          other.query == this.query &&
          other.createdAt == this.createdAt);
}

class SearchHistoryCompanion extends UpdateCompanion<DbSearchHistory> {
  final Value<String> id;
  final Value<String> query;
  final Value<int?> createdAt;
  final Value<int> rowid;
  const SearchHistoryCompanion({
    this.id = const Value.absent(),
    this.query = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SearchHistoryCompanion.insert({
    required String id,
    required String query,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       query = Value(query);
  static Insertable<DbSearchHistory> custom({
    Expression<String>? id,
    Expression<String>? query,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (query != null) 'query': query,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SearchHistoryCompanion copyWith({
    Value<String>? id,
    Value<String>? query,
    Value<int?>? createdAt,
    Value<int>? rowid,
  }) {
    return SearchHistoryCompanion(
      id: id ?? this.id,
      query: query ?? this.query,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (query.present) {
      map['query'] = Variable<String>(query.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SearchHistoryCompanion(')
          ..write('id: $id, ')
          ..write('query: $query, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecoSnapshotsTable extends RecoSnapshots
    with TableInfo<$RecoSnapshotsTable, DbRecoSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecoSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _surfaceMeta = const VerificationMeta(
    'surface',
  );
  @override
  late final GeneratedColumn<String> surface = GeneratedColumn<String>(
    'surface',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _computedAtMeta = const VerificationMeta(
    'computedAt',
  );
  @override
  late final GeneratedColumn<int> computedAt = GeneratedColumn<int>(
    'computed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ttlMsMeta = const VerificationMeta('ttlMs');
  @override
  late final GeneratedColumn<int> ttlMs = GeneratedColumn<int>(
    'ttl_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, surface, json, computedAt, ttlMs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reco_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbRecoSnapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('surface')) {
      context.handle(
        _surfaceMeta,
        surface.isAcceptableOrUnknown(data['surface']!, _surfaceMeta),
      );
    } else if (isInserting) {
      context.missing(_surfaceMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    if (data.containsKey('computed_at')) {
      context.handle(
        _computedAtMeta,
        computedAt.isAcceptableOrUnknown(data['computed_at']!, _computedAtMeta),
      );
    }
    if (data.containsKey('ttl_ms')) {
      context.handle(
        _ttlMsMeta,
        ttlMs.isAcceptableOrUnknown(data['ttl_ms']!, _ttlMsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbRecoSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbRecoSnapshot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      surface: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}surface'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
      computedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}computed_at'],
      ),
      ttlMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ttl_ms'],
      ),
    );
  }

  @override
  $RecoSnapshotsTable createAlias(String alias) {
    return $RecoSnapshotsTable(attachedDatabase, alias);
  }
}

class DbRecoSnapshot extends DataClass implements Insertable<DbRecoSnapshot> {
  /// Snapshot id (uuid v7).
  final String id;

  /// Surface (`home_made_for_you`, `daily_mix_1`, ...).
  final String surface;

  /// List of track ids + scores + reasons (JSON).
  final String json;

  /// Computation time (UTC epoch ms).
  final int? computedAt;

  /// Freshness window in milliseconds.
  final int? ttlMs;
  const DbRecoSnapshot({
    required this.id,
    required this.surface,
    required this.json,
    this.computedAt,
    this.ttlMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['surface'] = Variable<String>(surface);
    map['json'] = Variable<String>(json);
    if (!nullToAbsent || computedAt != null) {
      map['computed_at'] = Variable<int>(computedAt);
    }
    if (!nullToAbsent || ttlMs != null) {
      map['ttl_ms'] = Variable<int>(ttlMs);
    }
    return map;
  }

  RecoSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return RecoSnapshotsCompanion(
      id: Value(id),
      surface: Value(surface),
      json: Value(json),
      computedAt: computedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(computedAt),
      ttlMs: ttlMs == null && nullToAbsent
          ? const Value.absent()
          : Value(ttlMs),
    );
  }

  factory DbRecoSnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbRecoSnapshot(
      id: serializer.fromJson<String>(json['id']),
      surface: serializer.fromJson<String>(json['surface']),
      json: serializer.fromJson<String>(json['json']),
      computedAt: serializer.fromJson<int?>(json['computedAt']),
      ttlMs: serializer.fromJson<int?>(json['ttlMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'surface': serializer.toJson<String>(surface),
      'json': serializer.toJson<String>(json),
      'computedAt': serializer.toJson<int?>(computedAt),
      'ttlMs': serializer.toJson<int?>(ttlMs),
    };
  }

  DbRecoSnapshot copyWith({
    String? id,
    String? surface,
    String? json,
    Value<int?> computedAt = const Value.absent(),
    Value<int?> ttlMs = const Value.absent(),
  }) => DbRecoSnapshot(
    id: id ?? this.id,
    surface: surface ?? this.surface,
    json: json ?? this.json,
    computedAt: computedAt.present ? computedAt.value : this.computedAt,
    ttlMs: ttlMs.present ? ttlMs.value : this.ttlMs,
  );
  DbRecoSnapshot copyWithCompanion(RecoSnapshotsCompanion data) {
    return DbRecoSnapshot(
      id: data.id.present ? data.id.value : this.id,
      surface: data.surface.present ? data.surface.value : this.surface,
      json: data.json.present ? data.json.value : this.json,
      computedAt: data.computedAt.present
          ? data.computedAt.value
          : this.computedAt,
      ttlMs: data.ttlMs.present ? data.ttlMs.value : this.ttlMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbRecoSnapshot(')
          ..write('id: $id, ')
          ..write('surface: $surface, ')
          ..write('json: $json, ')
          ..write('computedAt: $computedAt, ')
          ..write('ttlMs: $ttlMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, surface, json, computedAt, ttlMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbRecoSnapshot &&
          other.id == this.id &&
          other.surface == this.surface &&
          other.json == this.json &&
          other.computedAt == this.computedAt &&
          other.ttlMs == this.ttlMs);
}

class RecoSnapshotsCompanion extends UpdateCompanion<DbRecoSnapshot> {
  final Value<String> id;
  final Value<String> surface;
  final Value<String> json;
  final Value<int?> computedAt;
  final Value<int?> ttlMs;
  final Value<int> rowid;
  const RecoSnapshotsCompanion({
    this.id = const Value.absent(),
    this.surface = const Value.absent(),
    this.json = const Value.absent(),
    this.computedAt = const Value.absent(),
    this.ttlMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecoSnapshotsCompanion.insert({
    required String id,
    required String surface,
    required String json,
    this.computedAt = const Value.absent(),
    this.ttlMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       surface = Value(surface),
       json = Value(json);
  static Insertable<DbRecoSnapshot> custom({
    Expression<String>? id,
    Expression<String>? surface,
    Expression<String>? json,
    Expression<int>? computedAt,
    Expression<int>? ttlMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (surface != null) 'surface': surface,
      if (json != null) 'json': json,
      if (computedAt != null) 'computed_at': computedAt,
      if (ttlMs != null) 'ttl_ms': ttlMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecoSnapshotsCompanion copyWith({
    Value<String>? id,
    Value<String>? surface,
    Value<String>? json,
    Value<int?>? computedAt,
    Value<int?>? ttlMs,
    Value<int>? rowid,
  }) {
    return RecoSnapshotsCompanion(
      id: id ?? this.id,
      surface: surface ?? this.surface,
      json: json ?? this.json,
      computedAt: computedAt ?? this.computedAt,
      ttlMs: ttlMs ?? this.ttlMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (surface.present) {
      map['surface'] = Variable<String>(surface.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (computedAt.present) {
      map['computed_at'] = Variable<int>(computedAt.value);
    }
    if (ttlMs.present) {
      map['ttl_ms'] = Variable<int>(ttlMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecoSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('surface: $surface, ')
          ..write('json: $json, ')
          ..write('computedAt: $computedAt, ')
          ..write('ttlMs: $ttlMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MetadataCacheTable extends MetadataCache
    with TableInfo<$MetadataCacheTable, DbMetadataCache> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetadataCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<int> fetchedAt = GeneratedColumn<int>(
    'fetched_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ttlMsMeta = const VerificationMeta('ttlMs');
  @override
  late final GeneratedColumn<int> ttlMs = GeneratedColumn<int>(
    'ttl_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [key, json, fetchedAt, ttlMs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'metadata_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbMetadataCache> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    }
    if (data.containsKey('ttl_ms')) {
      context.handle(
        _ttlMsMeta,
        ttlMs.isAcceptableOrUnknown(data['ttl_ms']!, _ttlMsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  DbMetadataCache map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbMetadataCache(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      ),
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fetched_at'],
      ),
      ttlMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ttl_ms'],
      ),
    );
  }

  @override
  $MetadataCacheTable createAlias(String alias) {
    return $MetadataCacheTable(attachedDatabase, alias);
  }
}

class DbMetadataCache extends DataClass implements Insertable<DbMetadataCache> {
  /// Cache key (`provider+kind+sourceId`).
  final String key;

  /// Cached JSON payload.
  final String? json;

  /// Fetch time (UTC epoch ms).
  final int? fetchedAt;

  /// Freshness window in milliseconds.
  final int? ttlMs;
  const DbMetadataCache({
    required this.key,
    this.json,
    this.fetchedAt,
    this.ttlMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || json != null) {
      map['json'] = Variable<String>(json);
    }
    if (!nullToAbsent || fetchedAt != null) {
      map['fetched_at'] = Variable<int>(fetchedAt);
    }
    if (!nullToAbsent || ttlMs != null) {
      map['ttl_ms'] = Variable<int>(ttlMs);
    }
    return map;
  }

  MetadataCacheCompanion toCompanion(bool nullToAbsent) {
    return MetadataCacheCompanion(
      key: Value(key),
      json: json == null && nullToAbsent ? const Value.absent() : Value(json),
      fetchedAt: fetchedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(fetchedAt),
      ttlMs: ttlMs == null && nullToAbsent
          ? const Value.absent()
          : Value(ttlMs),
    );
  }

  factory DbMetadataCache.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbMetadataCache(
      key: serializer.fromJson<String>(json['key']),
      json: serializer.fromJson<String?>(json['json']),
      fetchedAt: serializer.fromJson<int?>(json['fetchedAt']),
      ttlMs: serializer.fromJson<int?>(json['ttlMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'json': serializer.toJson<String?>(json),
      'fetchedAt': serializer.toJson<int?>(fetchedAt),
      'ttlMs': serializer.toJson<int?>(ttlMs),
    };
  }

  DbMetadataCache copyWith({
    String? key,
    Value<String?> json = const Value.absent(),
    Value<int?> fetchedAt = const Value.absent(),
    Value<int?> ttlMs = const Value.absent(),
  }) => DbMetadataCache(
    key: key ?? this.key,
    json: json.present ? json.value : this.json,
    fetchedAt: fetchedAt.present ? fetchedAt.value : this.fetchedAt,
    ttlMs: ttlMs.present ? ttlMs.value : this.ttlMs,
  );
  DbMetadataCache copyWithCompanion(MetadataCacheCompanion data) {
    return DbMetadataCache(
      key: data.key.present ? data.key.value : this.key,
      json: data.json.present ? data.json.value : this.json,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      ttlMs: data.ttlMs.present ? data.ttlMs.value : this.ttlMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbMetadataCache(')
          ..write('key: $key, ')
          ..write('json: $json, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('ttlMs: $ttlMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, json, fetchedAt, ttlMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbMetadataCache &&
          other.key == this.key &&
          other.json == this.json &&
          other.fetchedAt == this.fetchedAt &&
          other.ttlMs == this.ttlMs);
}

class MetadataCacheCompanion extends UpdateCompanion<DbMetadataCache> {
  final Value<String> key;
  final Value<String?> json;
  final Value<int?> fetchedAt;
  final Value<int?> ttlMs;
  final Value<int> rowid;
  const MetadataCacheCompanion({
    this.key = const Value.absent(),
    this.json = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.ttlMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MetadataCacheCompanion.insert({
    required String key,
    this.json = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.ttlMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<DbMetadataCache> custom({
    Expression<String>? key,
    Expression<String>? json,
    Expression<int>? fetchedAt,
    Expression<int>? ttlMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (json != null) 'json': json,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (ttlMs != null) 'ttl_ms': ttlMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MetadataCacheCompanion copyWith({
    Value<String>? key,
    Value<String?>? json,
    Value<int?>? fetchedAt,
    Value<int?>? ttlMs,
    Value<int>? rowid,
  }) {
    return MetadataCacheCompanion(
      key: key ?? this.key,
      json: json ?? this.json,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      ttlMs: ttlMs ?? this.ttlMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<int>(fetchedAt.value);
    }
    if (ttlMs.present) {
      map['ttl_ms'] = Variable<int>(ttlMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetadataCacheCompanion(')
          ..write('key: $key, ')
          ..write('json: $json, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('ttlMs: $ttlMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AuroraDatabase extends GeneratedDatabase {
  _$AuroraDatabase(QueryExecutor e) : super(e);
  $AuroraDatabaseManager get managers => $AuroraDatabaseManager(this);
  late final $TracksTable tracks = $TracksTable(this);
  late final $TrackArtistsTable trackArtists = $TrackArtistsTable(this);
  late final $TrackGenresTable trackGenres = $TrackGenresTable(this);
  late final $ArtistsTable artists = $ArtistsTable(this);
  late final $AlbumsTable albums = $AlbumsTable(this);
  late final $GenresTable genres = $GenresTable(this);
  late final $ArtworksTable artworks = $ArtworksTable(this);
  late final $PlaylistsTable playlists = $PlaylistsTable(this);
  late final $PlaylistEntriesTable playlistEntries = $PlaylistEntriesTable(
    this,
  );
  late final $PlayEventsTable playEvents = $PlayEventsTable(this);
  late final $UserTrackStatsTable userTrackStats = $UserTrackStatsTable(this);
  late final $PreferenceProfileTable preferenceProfile =
      $PreferenceProfileTable(this);
  late final $QueueItemsTable queueItems = $QueueItemsTable(this);
  late final $PlaybackStateTable playbackState = $PlaybackStateTable(this);
  late final $DownloadJobsTable downloadJobs = $DownloadJobsTable(this);
  late final $SearchHistoryTable searchHistory = $SearchHistoryTable(this);
  late final $RecoSnapshotsTable recoSnapshots = $RecoSnapshotsTable(this);
  late final $MetadataCacheTable metadataCache = $MetadataCacheTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tracks,
    trackArtists,
    trackGenres,
    artists,
    albums,
    genres,
    artworks,
    playlists,
    playlistEntries,
    playEvents,
    userTrackStats,
    preferenceProfile,
    queueItems,
    playbackState,
    downloadJobs,
    searchHistory,
    recoSnapshots,
    metadataCache,
  ];
}

typedef $$TracksTableCreateCompanionBuilder =
    TracksCompanion Function({
      required String id,
      required String providerId,
      required String sourceTrackId,
      required String title,
      Value<int> durationMs,
      Value<int> explicit,
      Value<String?> albumId,
      Value<int?> year,
      Value<String?> audioHash,
      Value<String?> localPath,
      Value<int> isDownloaded,
      Value<int?> streamExpiresAt,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$TracksTableUpdateCompanionBuilder =
    TracksCompanion Function({
      Value<String> id,
      Value<String> providerId,
      Value<String> sourceTrackId,
      Value<String> title,
      Value<int> durationMs,
      Value<int> explicit,
      Value<String?> albumId,
      Value<int?> year,
      Value<String?> audioHash,
      Value<String?> localPath,
      Value<int> isDownloaded,
      Value<int?> streamExpiresAt,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$TracksTableFilterComposer
    extends Composer<_$AuroraDatabase, $TracksTable> {
  $$TracksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceTrackId => $composableBuilder(
    column: $table.sourceTrackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get explicit => $composableBuilder(
    column: $table.explicit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get albumId => $composableBuilder(
    column: $table.albumId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioHash => $composableBuilder(
    column: $table.audioHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isDownloaded => $composableBuilder(
    column: $table.isDownloaded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get streamExpiresAt => $composableBuilder(
    column: $table.streamExpiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TracksTableOrderingComposer
    extends Composer<_$AuroraDatabase, $TracksTable> {
  $$TracksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceTrackId => $composableBuilder(
    column: $table.sourceTrackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get explicit => $composableBuilder(
    column: $table.explicit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get albumId => $composableBuilder(
    column: $table.albumId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioHash => $composableBuilder(
    column: $table.audioHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isDownloaded => $composableBuilder(
    column: $table.isDownloaded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get streamExpiresAt => $composableBuilder(
    column: $table.streamExpiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TracksTableAnnotationComposer
    extends Composer<_$AuroraDatabase, $TracksTable> {
  $$TracksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceTrackId => $composableBuilder(
    column: $table.sourceTrackId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get explicit =>
      $composableBuilder(column: $table.explicit, builder: (column) => column);

  GeneratedColumn<String> get albumId =>
      $composableBuilder(column: $table.albumId, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get audioHash =>
      $composableBuilder(column: $table.audioHash, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<int> get isDownloaded => $composableBuilder(
    column: $table.isDownloaded,
    builder: (column) => column,
  );

  GeneratedColumn<int> get streamExpiresAt => $composableBuilder(
    column: $table.streamExpiresAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TracksTableTableManager
    extends
        RootTableManager<
          _$AuroraDatabase,
          $TracksTable,
          DbTrack,
          $$TracksTableFilterComposer,
          $$TracksTableOrderingComposer,
          $$TracksTableAnnotationComposer,
          $$TracksTableCreateCompanionBuilder,
          $$TracksTableUpdateCompanionBuilder,
          (DbTrack, BaseReferences<_$AuroraDatabase, $TracksTable, DbTrack>),
          DbTrack,
          PrefetchHooks Function()
        > {
  $$TracksTableTableManager(_$AuroraDatabase db, $TracksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TracksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TracksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TracksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> sourceTrackId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<int> explicit = const Value.absent(),
                Value<String?> albumId = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<String?> audioHash = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<int> isDownloaded = const Value.absent(),
                Value<int?> streamExpiresAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TracksCompanion(
                id: id,
                providerId: providerId,
                sourceTrackId: sourceTrackId,
                title: title,
                durationMs: durationMs,
                explicit: explicit,
                albumId: albumId,
                year: year,
                audioHash: audioHash,
                localPath: localPath,
                isDownloaded: isDownloaded,
                streamExpiresAt: streamExpiresAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String providerId,
                required String sourceTrackId,
                required String title,
                Value<int> durationMs = const Value.absent(),
                Value<int> explicit = const Value.absent(),
                Value<String?> albumId = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<String?> audioHash = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<int> isDownloaded = const Value.absent(),
                Value<int?> streamExpiresAt = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TracksCompanion.insert(
                id: id,
                providerId: providerId,
                sourceTrackId: sourceTrackId,
                title: title,
                durationMs: durationMs,
                explicit: explicit,
                albumId: albumId,
                year: year,
                audioHash: audioHash,
                localPath: localPath,
                isDownloaded: isDownloaded,
                streamExpiresAt: streamExpiresAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TracksTableProcessedTableManager =
    ProcessedTableManager<
      _$AuroraDatabase,
      $TracksTable,
      DbTrack,
      $$TracksTableFilterComposer,
      $$TracksTableOrderingComposer,
      $$TracksTableAnnotationComposer,
      $$TracksTableCreateCompanionBuilder,
      $$TracksTableUpdateCompanionBuilder,
      (DbTrack, BaseReferences<_$AuroraDatabase, $TracksTable, DbTrack>),
      DbTrack,
      PrefetchHooks Function()
    >;
typedef $$TrackArtistsTableCreateCompanionBuilder =
    TrackArtistsCompanion Function({
      required String trackId,
      required String artistId,
      Value<int> position,
      Value<int> rowid,
    });
typedef $$TrackArtistsTableUpdateCompanionBuilder =
    TrackArtistsCompanion Function({
      Value<String> trackId,
      Value<String> artistId,
      Value<int> position,
      Value<int> rowid,
    });

class $$TrackArtistsTableFilterComposer
    extends Composer<_$AuroraDatabase, $TrackArtistsTable> {
  $$TrackArtistsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artistId => $composableBuilder(
    column: $table.artistId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TrackArtistsTableOrderingComposer
    extends Composer<_$AuroraDatabase, $TrackArtistsTable> {
  $$TrackArtistsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artistId => $composableBuilder(
    column: $table.artistId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TrackArtistsTableAnnotationComposer
    extends Composer<_$AuroraDatabase, $TrackArtistsTable> {
  $$TrackArtistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get trackId =>
      $composableBuilder(column: $table.trackId, builder: (column) => column);

  GeneratedColumn<String> get artistId =>
      $composableBuilder(column: $table.artistId, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$TrackArtistsTableTableManager
    extends
        RootTableManager<
          _$AuroraDatabase,
          $TrackArtistsTable,
          DbTrackArtist,
          $$TrackArtistsTableFilterComposer,
          $$TrackArtistsTableOrderingComposer,
          $$TrackArtistsTableAnnotationComposer,
          $$TrackArtistsTableCreateCompanionBuilder,
          $$TrackArtistsTableUpdateCompanionBuilder,
          (
            DbTrackArtist,
            BaseReferences<_$AuroraDatabase, $TrackArtistsTable, DbTrackArtist>,
          ),
          DbTrackArtist,
          PrefetchHooks Function()
        > {
  $$TrackArtistsTableTableManager(_$AuroraDatabase db, $TrackArtistsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackArtistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackArtistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackArtistsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> trackId = const Value.absent(),
                Value<String> artistId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackArtistsCompanion(
                trackId: trackId,
                artistId: artistId,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String trackId,
                required String artistId,
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackArtistsCompanion.insert(
                trackId: trackId,
                artistId: artistId,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TrackArtistsTableProcessedTableManager =
    ProcessedTableManager<
      _$AuroraDatabase,
      $TrackArtistsTable,
      DbTrackArtist,
      $$TrackArtistsTableFilterComposer,
      $$TrackArtistsTableOrderingComposer,
      $$TrackArtistsTableAnnotationComposer,
      $$TrackArtistsTableCreateCompanionBuilder,
      $$TrackArtistsTableUpdateCompanionBuilder,
      (
        DbTrackArtist,
        BaseReferences<_$AuroraDatabase, $TrackArtistsTable, DbTrackArtist>,
      ),
      DbTrackArtist,
      PrefetchHooks Function()
    >;
typedef $$TrackGenresTableCreateCompanionBuilder =
    TrackGenresCompanion Function({
      required String trackId,
      required String genreId,
      Value<int> rowid,
    });
typedef $$TrackGenresTableUpdateCompanionBuilder =
    TrackGenresCompanion Function({
      Value<String> trackId,
      Value<String> genreId,
      Value<int> rowid,
    });

class $$TrackGenresTableFilterComposer
    extends Composer<_$AuroraDatabase, $TrackGenresTable> {
  $$TrackGenresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genreId => $composableBuilder(
    column: $table.genreId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TrackGenresTableOrderingComposer
    extends Composer<_$AuroraDatabase, $TrackGenresTable> {
  $$TrackGenresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genreId => $composableBuilder(
    column: $table.genreId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TrackGenresTableAnnotationComposer
    extends Composer<_$AuroraDatabase, $TrackGenresTable> {
  $$TrackGenresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get trackId =>
      $composableBuilder(column: $table.trackId, builder: (column) => column);

  GeneratedColumn<String> get genreId =>
      $composableBuilder(column: $table.genreId, builder: (column) => column);
}

class $$TrackGenresTableTableManager
    extends
        RootTableManager<
          _$AuroraDatabase,
          $TrackGenresTable,
          DbTrackGenre,
          $$TrackGenresTableFilterComposer,
          $$TrackGenresTableOrderingComposer,
          $$TrackGenresTableAnnotationComposer,
          $$TrackGenresTableCreateCompanionBuilder,
          $$TrackGenresTableUpdateCompanionBuilder,
          (
            DbTrackGenre,
            BaseReferences<_$AuroraDatabase, $TrackGenresTable, DbTrackGenre>,
          ),
          DbTrackGenre,
          PrefetchHooks Function()
        > {
  $$TrackGenresTableTableManager(_$AuroraDatabase db, $TrackGenresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackGenresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackGenresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackGenresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> trackId = const Value.absent(),
                Value<String> genreId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackGenresCompanion(
                trackId: trackId,
                genreId: genreId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String trackId,
                required String genreId,
                Value<int> rowid = const Value.absent(),
              }) => TrackGenresCompanion.insert(
                trackId: trackId,
                genreId: genreId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TrackGenresTableProcessedTableManager =
    ProcessedTableManager<
      _$AuroraDatabase,
      $TrackGenresTable,
      DbTrackGenre,
      $$TrackGenresTableFilterComposer,
      $$TrackGenresTableOrderingComposer,
      $$TrackGenresTableAnnotationComposer,
      $$TrackGenresTableCreateCompanionBuilder,
      $$TrackGenresTableUpdateCompanionBuilder,
      (
        DbTrackGenre,
        BaseReferences<_$AuroraDatabase, $TrackGenresTable, DbTrackGenre>,
      ),
      DbTrackGenre,
      PrefetchHooks Function()
    >;
typedef $$ArtistsTableCreateCompanionBuilder =
    ArtistsCompanion Function({
      required String id,
      Value<String?> providerId,
      Value<String?> sourceId,
      required String name,
      Value<String?> imageUrl,
      Value<int> rowid,
    });
typedef $$ArtistsTableUpdateCompanionBuilder =
    ArtistsCompanion Function({
      Value<String> id,
      Value<String?> providerId,
      Value<String?> sourceId,
      Value<String> name,
      Value<String?> imageUrl,
      Value<int> rowid,
    });

class $$ArtistsTableFilterComposer
    extends Composer<_$AuroraDatabase, $ArtistsTable> {
  $$ArtistsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ArtistsTableOrderingComposer
    extends Composer<_$AuroraDatabase, $ArtistsTable> {
  $$ArtistsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ArtistsTableAnnotationComposer
    extends Composer<_$AuroraDatabase, $ArtistsTable> {
  $$ArtistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);
}

class $$ArtistsTableTableManager
    extends
        RootTableManager<
          _$AuroraDatabase,
          $ArtistsTable,
          DbArtist,
          $$ArtistsTableFilterComposer,
          $$ArtistsTableOrderingComposer,
          $$ArtistsTableAnnotationComposer,
          $$ArtistsTableCreateCompanionBuilder,
          $$ArtistsTableUpdateCompanionBuilder,
          (DbArtist, BaseReferences<_$AuroraDatabase, $ArtistsTable, DbArtist>),
          DbArtist,
          PrefetchHooks Function()
        > {
  $$ArtistsTableTableManager(_$AuroraDatabase db, $ArtistsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArtistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArtistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArtistsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> providerId = const Value.absent(),
                Value<String?> sourceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArtistsCompanion(
                id: id,
                providerId: providerId,
                sourceId: sourceId,
                name: name,
                imageUrl: imageUrl,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> providerId = const Value.absent(),
                Value<String?> sourceId = const Value.absent(),
                required String name,
                Value<String?> imageUrl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArtistsCompanion.insert(
                id: id,
                providerId: providerId,
                sourceId: sourceId,
                name: name,
                imageUrl: imageUrl,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ArtistsTableProcessedTableManager =
    ProcessedTableManager<
      _$AuroraDatabase,
      $ArtistsTable,
      DbArtist,
      $$ArtistsTableFilterComposer,
      $$ArtistsTableOrderingComposer,
      $$ArtistsTableAnnotationComposer,
      $$ArtistsTableCreateCompanionBuilder,
      $$ArtistsTableUpdateCompanionBuilder,
      (DbArtist, BaseReferences<_$AuroraDatabase, $ArtistsTable, DbArtist>),
      DbArtist,
      PrefetchHooks Function()
    >;
typedef $$AlbumsTableCreateCompanionBuilder =
    AlbumsCompanion Function({
      required String id,
      Value<String?> providerId,
      Value<String?> sourceId,
      required String title,
      Value<int?> year,
      Value<String?> artworkId,
      Value<int?> trackCount,
      Value<int> rowid,
    });
typedef $$AlbumsTableUpdateCompanionBuilder =
    AlbumsCompanion Function({
      Value<String> id,
      Value<String?> providerId,
      Value<String?> sourceId,
      Value<String> title,
      Value<int?> year,
      Value<String?> artworkId,
      Value<int?> trackCount,
      Value<int> rowid,
    });

class $$AlbumsTableFilterComposer
    extends Composer<_$AuroraDatabase, $AlbumsTable> {
  $$AlbumsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artworkId => $composableBuilder(
    column: $table.artworkId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get trackCount => $composableBuilder(
    column: $table.trackCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AlbumsTableOrderingComposer
    extends Composer<_$AuroraDatabase, $AlbumsTable> {
  $$AlbumsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artworkId => $composableBuilder(
    column: $table.artworkId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get trackCount => $composableBuilder(
    column: $table.trackCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AlbumsTableAnnotationComposer
    extends Composer<_$AuroraDatabase, $AlbumsTable> {
  $$AlbumsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get artworkId =>
      $composableBuilder(column: $table.artworkId, builder: (column) => column);

  GeneratedColumn<int> get trackCount => $composableBuilder(
    column: $table.trackCount,
    builder: (column) => column,
  );
}

class $$AlbumsTableTableManager
    extends
        RootTableManager<
          _$AuroraDatabase,
          $AlbumsTable,
          DbAlbum,
          $$AlbumsTableFilterComposer,
          $$AlbumsTableOrderingComposer,
          $$AlbumsTableAnnotationComposer,
          $$AlbumsTableCreateCompanionBuilder,
          $$AlbumsTableUpdateCompanionBuilder,
          (DbAlbum, BaseReferences<_$AuroraDatabase, $AlbumsTable, DbAlbum>),
          DbAlbum,
          PrefetchHooks Function()
        > {
  $$AlbumsTableTableManager(_$AuroraDatabase db, $AlbumsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlbumsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlbumsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlbumsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> providerId = const Value.absent(),
                Value<String?> sourceId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<String?> artworkId = const Value.absent(),
                Value<int?> trackCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlbumsCompanion(
                id: id,
                providerId: providerId,
                sourceId: sourceId,
                title: title,
                year: year,
                artworkId: artworkId,
                trackCount: trackCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> providerId = const Value.absent(),
                Value<String?> sourceId = const Value.absent(),
                required String title,
                Value<int?> year = const Value.absent(),
                Value<String?> artworkId = const Value.absent(),
                Value<int?> trackCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlbumsCompanion.insert(
                id: id,
                providerId: providerId,
                sourceId: sourceId,
                title: title,
                year: year,
                artworkId: artworkId,
                trackCount: trackCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AlbumsTableProcessedTableManager =
    ProcessedTableManager<
      _$AuroraDatabase,
      $AlbumsTable,
      DbAlbum,
      $$AlbumsTableFilterComposer,
      $$AlbumsTableOrderingComposer,
      $$AlbumsTableAnnotationComposer,
      $$AlbumsTableCreateCompanionBuilder,
      $$AlbumsTableUpdateCompanionBuilder,
      (DbAlbum, BaseReferences<_$AuroraDatabase, $AlbumsTable, DbAlbum>),
      DbAlbum,
      PrefetchHooks Function()
    >;
typedef $$GenresTableCreateCompanionBuilder =
    GenresCompanion Function({
      required String id,
      required String name,
      Value<int> rowid,
    });
typedef $$GenresTableUpdateCompanionBuilder =
    GenresCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> rowid,
    });

class $$GenresTableFilterComposer
    extends Composer<_$AuroraDatabase, $GenresTable> {
  $$GenresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GenresTableOrderingComposer
    extends Composer<_$AuroraDatabase, $GenresTable> {
  $$GenresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GenresTableAnnotationComposer
    extends Composer<_$AuroraDatabase, $GenresTable> {
  $$GenresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$GenresTableTableManager
    extends
        RootTableManager<
          _$AuroraDatabase,
          $GenresTable,
          DbGenre,
          $$GenresTableFilterComposer,
          $$GenresTableOrderingComposer,
          $$GenresTableAnnotationComposer,
          $$GenresTableCreateCompanionBuilder,
          $$GenresTableUpdateCompanionBuilder,
          (DbGenre, BaseReferences<_$AuroraDatabase, $GenresTable, DbGenre>),
          DbGenre,
          PrefetchHooks Function()
        > {
  $$GenresTableTableManager(_$AuroraDatabase db, $GenresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GenresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GenresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GenresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GenresCompanion(id: id, name: name, rowid: rowid),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => GenresCompanion.insert(id: id, name: name, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GenresTableProcessedTableManager =
    ProcessedTableManager<
      _$AuroraDatabase,
      $GenresTable,
      DbGenre,
      $$GenresTableFilterComposer,
      $$GenresTableOrderingComposer,
      $$GenresTableAnnotationComposer,
      $$GenresTableCreateCompanionBuilder,
      $$GenresTableUpdateCompanionBuilder,
      (DbGenre, BaseReferences<_$AuroraDatabase, $GenresTable, DbGenre>),
      DbGenre,
      PrefetchHooks Function()
    >;
typedef $$ArtworksTableCreateCompanionBuilder =
    ArtworksCompanion Function({
      required String id,
      Value<String?> url,
      Value<String?> localPath,
      Value<int?> dominantArgb,
      Value<int?> width,
      Value<int?> height,
      Value<int?> updatedAt,
      Value<int> rowid,
    });
typedef $$ArtworksTableUpdateCompanionBuilder =
    ArtworksCompanion Function({
      Value<String> id,
      Value<String?> url,
      Value<String?> localPath,
      Value<int?> dominantArgb,
      Value<int?> width,
      Value<int?> height,
      Value<int?> updatedAt,
      Value<int> rowid,
    });

class $$ArtworksTableFilterComposer
    extends Composer<_$AuroraDatabase, $ArtworksTable> {
  $$ArtworksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dominantArgb => $composableBuilder(
    column: $table.dominantArgb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ArtworksTableOrderingComposer
    extends Composer<_$AuroraDatabase, $ArtworksTable> {
  $$ArtworksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dominantArgb => $composableBuilder(
    column: $table.dominantArgb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ArtworksTableAnnotationComposer
    extends Composer<_$AuroraDatabase, $ArtworksTable> {
  $$ArtworksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<int> get dominantArgb => $composableBuilder(
    column: $table.dominantArgb,
    builder: (column) => column,
  );

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ArtworksTableTableManager
    extends
        RootTableManager<
          _$AuroraDatabase,
          $ArtworksTable,
          DbArtwork,
          $$ArtworksTableFilterComposer,
          $$ArtworksTableOrderingComposer,
          $$ArtworksTableAnnotationComposer,
          $$ArtworksTableCreateCompanionBuilder,
          $$ArtworksTableUpdateCompanionBuilder,
          (
            DbArtwork,
            BaseReferences<_$AuroraDatabase, $ArtworksTable, DbArtwork>,
          ),
          DbArtwork,
          PrefetchHooks Function()
        > {
  $$ArtworksTableTableManager(_$AuroraDatabase db, $ArtworksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArtworksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArtworksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArtworksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<int?> dominantArgb = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<int?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArtworksCompanion(
                id: id,
                url: url,
                localPath: localPath,
                dominantArgb: dominantArgb,
                width: width,
                height: height,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> url = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<int?> dominantArgb = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<int?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArtworksCompanion.insert(
                id: id,
                url: url,
                localPath: localPath,
                dominantArgb: dominantArgb,
                width: width,
                height: height,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ArtworksTableProcessedTableManager =
    ProcessedTableManager<
      _$AuroraDatabase,
      $ArtworksTable,
      DbArtwork,
      $$ArtworksTableFilterComposer,
      $$ArtworksTableOrderingComposer,
      $$ArtworksTableAnnotationComposer,
      $$ArtworksTableCreateCompanionBuilder,
      $$ArtworksTableUpdateCompanionBuilder,
      (DbArtwork, BaseReferences<_$AuroraDatabase, $ArtworksTable, DbArtwork>),
      DbArtwork,
      PrefetchHooks Function()
    >;
typedef $$PlaylistsTableCreateCompanionBuilder =
    PlaylistsCompanion Function({
      required String id,
      required String title,
      Value<String?> description,
      Value<String?> artworkId,
      Value<int> isSystem,
      Value<int?> createdAt,
      Value<int?> updatedAt,
      Value<int> rowid,
    });
typedef $$PlaylistsTableUpdateCompanionBuilder =
    PlaylistsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> description,
      Value<String?> artworkId,
      Value<int> isSystem,
      Value<int?> createdAt,
      Value<int?> updatedAt,
      Value<int> rowid,
    });

class $$PlaylistsTableFilterComposer
    extends Composer<_$AuroraDatabase, $PlaylistsTable> {
  $$PlaylistsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artworkId => $composableBuilder(
    column: $table.artworkId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlaylistsTableOrderingComposer
    extends Composer<_$AuroraDatabase, $PlaylistsTable> {
  $$PlaylistsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artworkId => $composableBuilder(
    column: $table.artworkId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaylistsTableAnnotationComposer
    extends Composer<_$AuroraDatabase, $PlaylistsTable> {
  $$PlaylistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get artworkId =>
      $composableBuilder(column: $table.artworkId, builder: (column) => column);

  GeneratedColumn<int> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PlaylistsTableTableManager
    extends
        RootTableManager<
          _$AuroraDatabase,
          $PlaylistsTable,
          DbPlaylist,
          $$PlaylistsTableFilterComposer,
          $$PlaylistsTableOrderingComposer,
          $$PlaylistsTableAnnotationComposer,
          $$PlaylistsTableCreateCompanionBuilder,
          $$PlaylistsTableUpdateCompanionBuilder,
          (
            DbPlaylist,
            BaseReferences<_$AuroraDatabase, $PlaylistsTable, DbPlaylist>,
          ),
          DbPlaylist,
          PrefetchHooks Function()
        > {
  $$PlaylistsTableTableManager(_$AuroraDatabase db, $PlaylistsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> artworkId = const Value.absent(),
                Value<int> isSystem = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistsCompanion(
                id: id,
                title: title,
                description: description,
                artworkId: artworkId,
                isSystem: isSystem,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> description = const Value.absent(),
                Value<String?> artworkId = const Value.absent(),
                Value<int> isSystem = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistsCompanion.insert(
                id: id,
                title: title,
                description: description,
                artworkId: artworkId,
                isSystem: isSystem,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlaylistsTableProcessedTableManager =
    ProcessedTableManager<
      _$AuroraDatabase,
      $PlaylistsTable,
      DbPlaylist,
      $$PlaylistsTableFilterComposer,
      $$PlaylistsTableOrderingComposer,
      $$PlaylistsTableAnnotationComposer,
      $$PlaylistsTableCreateCompanionBuilder,
      $$PlaylistsTableUpdateCompanionBuilder,
      (
        DbPlaylist,
        BaseReferences<_$AuroraDatabase, $PlaylistsTable, DbPlaylist>,
      ),
      DbPlaylist,
      PrefetchHooks Function()
    >;
typedef $$PlaylistEntriesTableCreateCompanionBuilder =
    PlaylistEntriesCompanion Function({
      required String playlistId,
      required String trackId,
      Value<int> position,
      Value<int?> addedAt,
      Value<int> rowid,
    });
typedef $$PlaylistEntriesTableUpdateCompanionBuilder =
    PlaylistEntriesCompanion Function({
      Value<String> playlistId,
      Value<String> trackId,
      Value<int> position,
      Value<int?> addedAt,
      Value<int> rowid,
    });

class $$PlaylistEntriesTableFilterComposer
    extends Composer<_$AuroraDatabase, $PlaylistEntriesTable> {
  $$PlaylistEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get playlistId => $composableBuilder(
    column: $table.playlistId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlaylistEntriesTableOrderingComposer
    extends Composer<_$AuroraDatabase, $PlaylistEntriesTable> {
  $$PlaylistEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get playlistId => $composableBuilder(
    column: $table.playlistId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaylistEntriesTableAnnotationComposer
    extends Composer<_$AuroraDatabase, $PlaylistEntriesTable> {
  $$PlaylistEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get playlistId => $composableBuilder(
    column: $table.playlistId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get trackId =>
      $composableBuilder(column: $table.trackId, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);
}

class $$PlaylistEntriesTableTableManager
    extends
        RootTableManager<
          _$AuroraDatabase,
          $PlaylistEntriesTable,
          DbPlaylistEntry,
          $$PlaylistEntriesTableFilterComposer,
          $$PlaylistEntriesTableOrderingComposer,
          $$PlaylistEntriesTableAnnotationComposer,
          $$PlaylistEntriesTableCreateCompanionBuilder,
          $$PlaylistEntriesTableUpdateCompanionBuilder,
          (
            DbPlaylistEntry,
            BaseReferences<
              _$AuroraDatabase,
              $PlaylistEntriesTable,
              DbPlaylistEntry
            >,
          ),
          DbPlaylistEntry,
          PrefetchHooks Function()
        > {
  $$PlaylistEntriesTableTableManager(
    _$AuroraDatabase db,
    $PlaylistEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> playlistId = const Value.absent(),
                Value<String> trackId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int?> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistEntriesCompanion(
                playlistId: playlistId,
                trackId: trackId,
                position: position,
                addedAt: addedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String playlistId,
                required String trackId,
                Value<int> position = const Value.absent(),
                Value<int?> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistEntriesCompanion.insert(
                playlistId: playlistId,
                trackId: trackId,
                position: position,
                addedAt: addedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlaylistEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AuroraDatabase,
      $PlaylistEntriesTable,
      DbPlaylistEntry,
      $$PlaylistEntriesTableFilterComposer,
      $$PlaylistEntriesTableOrderingComposer,
      $$PlaylistEntriesTableAnnotationComposer,
      $$PlaylistEntriesTableCreateCompanionBuilder,
      $$PlaylistEntriesTableUpdateCompanionBuilder,
      (
        DbPlaylistEntry,
        BaseReferences<
          _$AuroraDatabase,
          $PlaylistEntriesTable,
          DbPlaylistEntry
        >,
      ),
      DbPlaylistEntry,
      PrefetchHooks Function()
    >;
typedef $$PlayEventsTableCreateCompanionBuilder =
    PlayEventsCompanion Function({
      required String id,
      required String trackId,
      required String sessionId,
      required int startedAt,
      Value<int?> endedAt,
      Value<int?> durationMs,
      Value<int?> listenedMs,
      Value<double?> completionRatio,
      Value<int?> skipped,
      Value<int?> skipAtMs,
      Value<String?> source,
      Value<String?> timeOfDayBucket,
      Value<int?> dayOfWeek,
      Value<double?> playbackSpeed,
      Value<int?> wasOffline,
      Value<int?> seekCount,
      Value<int> rowid,
    });
typedef $$PlayEventsTableUpdateCompanionBuilder =
    PlayEventsCompanion Function({
      Value<String> id,
      Value<String> trackId,
      Value<String> sessionId,
      Value<int> startedAt,
      Value<int?> endedAt,
      Value<int?> durationMs,
      Value<int?> listenedMs,
      Value<double?> completionRatio,
      Value<int?> skipped,
      Value<int?> skipAtMs,
      Value<String?> source,
      Value<String?> timeOfDayBucket,
      Value<int?> dayOfWeek,
      Value<double?> playbackSpeed,
      Value<int?> wasOffline,
      Value<int?> seekCount,
      Value<int> rowid,
    });

class $$PlayEventsTableFilterComposer
    extends Composer<_$AuroraDatabase, $PlayEventsTable> {
  $$PlayEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get listenedMs => $composableBuilder(
    column: $table.listenedMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get completionRatio => $composableBuilder(
    column: $table.completionRatio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get skipped => $composableBuilder(
    column: $table.skipped,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get skipAtMs => $composableBuilder(
    column: $table.skipAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeOfDayBucket => $composableBuilder(
    column: $table.timeOfDayBucket,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayOfWeek => $composableBuilder(
    column: $table.dayOfWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get playbackSpeed => $composableBuilder(
    column: $table.playbackSpeed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wasOffline => $composableBuilder(
    column: $table.wasOffline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seekCount => $composableBuilder(
    column: $table.seekCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlayEventsTableOrderingComposer
    extends Composer<_$AuroraDatabase, $PlayEventsTable> {
  $$PlayEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get listenedMs => $composableBuilder(
    column: $table.listenedMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get completionRatio => $composableBuilder(
    column: $table.completionRatio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get skipped => $composableBuilder(
    column: $table.skipped,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get skipAtMs => $composableBuilder(
    column: $table.skipAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeOfDayBucket => $composableBuilder(
    column: $table.timeOfDayBucket,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayOfWeek => $composableBuilder(
    column: $table.dayOfWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get playbackSpeed => $composableBuilder(
    column: $table.playbackSpeed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wasOffline => $composableBuilder(
    column: $table.wasOffline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seekCount => $composableBuilder(
    column: $table.seekCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlayEventsTableAnnotationComposer
    extends Composer<_$AuroraDatabase, $PlayEventsTable> {
  $$PlayEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get trackId =>
      $composableBuilder(column: $table.trackId, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get listenedMs => $composableBuilder(
    column: $table.listenedMs,
    builder: (column) => column,
  );

  GeneratedColumn<double> get completionRatio => $composableBuilder(
    column: $table.completionRatio,
    builder: (column) => column,
  );

  GeneratedColumn<int> get skipped =>
      $composableBuilder(column: $table.skipped, builder: (column) => column);

  GeneratedColumn<int> get skipAtMs =>
      $composableBuilder(column: $table.skipAtMs, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get timeOfDayBucket => $composableBuilder(
    column: $table.timeOfDayBucket,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dayOfWeek =>
      $composableBuilder(column: $table.dayOfWeek, builder: (column) => column);

  GeneratedColumn<double> get playbackSpeed => $composableBuilder(
    column: $table.playbackSpeed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wasOffline => $composableBuilder(
    column: $table.wasOffline,
    builder: (column) => column,
  );

  GeneratedColumn<int> get seekCount =>
      $composableBuilder(column: $table.seekCount, builder: (column) => column);
}

class $$PlayEventsTableTableManager
    extends
        RootTableManager<
          _$AuroraDatabase,
          $PlayEventsTable,
          DbPlayEvent,
          $$PlayEventsTableFilterComposer,
          $$PlayEventsTableOrderingComposer,
          $$PlayEventsTableAnnotationComposer,
          $$PlayEventsTableCreateCompanionBuilder,
          $$PlayEventsTableUpdateCompanionBuilder,
          (
            DbPlayEvent,
            BaseReferences<_$AuroraDatabase, $PlayEventsTable, DbPlayEvent>,
          ),
          DbPlayEvent,
          PrefetchHooks Function()
        > {
  $$PlayEventsTableTableManager(_$AuroraDatabase db, $PlayEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> trackId = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<int> startedAt = const Value.absent(),
                Value<int?> endedAt = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<int?> listenedMs = const Value.absent(),
                Value<double?> completionRatio = const Value.absent(),
                Value<int?> skipped = const Value.absent(),
                Value<int?> skipAtMs = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<String?> timeOfDayBucket = const Value.absent(),
                Value<int?> dayOfWeek = const Value.absent(),
                Value<double?> playbackSpeed = const Value.absent(),
                Value<int?> wasOffline = const Value.absent(),
                Value<int?> seekCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlayEventsCompanion(
                id: id,
                trackId: trackId,
                sessionId: sessionId,
                startedAt: startedAt,
                endedAt: endedAt,
                durationMs: durationMs,
                listenedMs: listenedMs,
                completionRatio: completionRatio,
                skipped: skipped,
                skipAtMs: skipAtMs,
                source: source,
                timeOfDayBucket: timeOfDayBucket,
                dayOfWeek: dayOfWeek,
                playbackSpeed: playbackSpeed,
                wasOffline: wasOffline,
                seekCount: seekCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String trackId,
                required String sessionId,
                required int startedAt,
                Value<int?> endedAt = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<int?> listenedMs = const Value.absent(),
                Value<double?> completionRatio = const Value.absent(),
                Value<int?> skipped = const Value.absent(),
                Value<int?> skipAtMs = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<String?> timeOfDayBucket = const Value.absent(),
                Value<int?> dayOfWeek = const Value.absent(),
                Value<double?> playbackSpeed = const Value.absent(),
                Value<int?> wasOffline = const Value.absent(),
                Value<int?> seekCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlayEventsCompanion.insert(
                id: id,
                trackId: trackId,
                sessionId: sessionId,
                startedAt: startedAt,
                endedAt: endedAt,
                durationMs: durationMs,
                listenedMs: listenedMs,
                completionRatio: completionRatio,
                skipped: skipped,
                skipAtMs: skipAtMs,
                source: source,
                timeOfDayBucket: timeOfDayBucket,
                dayOfWeek: dayOfWeek,
                playbackSpeed: playbackSpeed,
                wasOffline: wasOffline,
                seekCount: seekCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlayEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AuroraDatabase,
      $PlayEventsTable,
      DbPlayEvent,
      $$PlayEventsTableFilterComposer,
      $$PlayEventsTableOrderingComposer,
      $$PlayEventsTableAnnotationComposer,
      $$PlayEventsTableCreateCompanionBuilder,
      $$PlayEventsTableUpdateCompanionBuilder,
      (
        DbPlayEvent,
        BaseReferences<_$AuroraDatabase, $PlayEventsTable, DbPlayEvent>,
      ),
      DbPlayEvent,
      PrefetchHooks Function()
    >;
typedef $$UserTrackStatsTableCreateCompanionBuilder =
    UserTrackStatsCompanion Function({
      required String trackId,
      Value<int?> playCount,
      Value<int?> skipCount,
      Value<int?> completeCount,
      Value<int?> replayCount,
      Value<int?> totalListenMs,
      Value<int?> lastPlayedAt,
      Value<int?> likeState,
      Value<double?> decayedScore,
      Value<int?> updatedAt,
      Value<int> rowid,
    });
typedef $$UserTrackStatsTableUpdateCompanionBuilder =
    UserTrackStatsCompanion Function({
      Value<String> trackId,
      Value<int?> playCount,
      Value<int?> skipCount,
      Value<int?> completeCount,
      Value<int?> replayCount,
      Value<int?> totalListenMs,
      Value<int?> lastPlayedAt,
      Value<int?> likeState,
      Value<double?> decayedScore,
      Value<int?> updatedAt,
      Value<int> rowid,
    });

class $$UserTrackStatsTableFilterComposer
    extends Composer<_$AuroraDatabase, $UserTrackStatsTable> {
  $$UserTrackStatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get skipCount => $composableBuilder(
    column: $table.skipCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completeCount => $composableBuilder(
    column: $table.completeCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get replayCount => $composableBuilder(
    column: $table.replayCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalListenMs => $composableBuilder(
    column: $table.totalListenMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get likeState => $composableBuilder(
    column: $table.likeState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get decayedScore => $composableBuilder(
    column: $table.decayedScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserTrackStatsTableOrderingComposer
    extends Composer<_$AuroraDatabase, $UserTrackStatsTable> {
  $$UserTrackStatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get skipCount => $composableBuilder(
    column: $table.skipCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completeCount => $composableBuilder(
    column: $table.completeCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get replayCount => $composableBuilder(
    column: $table.replayCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalListenMs => $composableBuilder(
    column: $table.totalListenMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get likeState => $composableBuilder(
    column: $table.likeState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get decayedScore => $composableBuilder(
    column: $table.decayedScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserTrackStatsTableAnnotationComposer
    extends Composer<_$AuroraDatabase, $UserTrackStatsTable> {
  $$UserTrackStatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get trackId =>
      $composableBuilder(column: $table.trackId, builder: (column) => column);

  GeneratedColumn<int> get playCount =>
      $composableBuilder(column: $table.playCount, builder: (column) => column);

  GeneratedColumn<int> get skipCount =>
      $composableBuilder(column: $table.skipCount, builder: (column) => column);

  GeneratedColumn<int> get completeCount => $composableBuilder(
    column: $table.completeCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get replayCount => $composableBuilder(
    column: $table.replayCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalListenMs => $composableBuilder(
    column: $table.totalListenMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get likeState =>
      $composableBuilder(column: $table.likeState, builder: (column) => column);

  GeneratedColumn<double> get decayedScore => $composableBuilder(
    column: $table.decayedScore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserTrackStatsTableTableManager
    extends
        RootTableManager<
          _$AuroraDatabase,
          $UserTrackStatsTable,
          DbUserTrackStat,
          $$UserTrackStatsTableFilterComposer,
          $$UserTrackStatsTableOrderingComposer,
          $$UserTrackStatsTableAnnotationComposer,
          $$UserTrackStatsTableCreateCompanionBuilder,
          $$UserTrackStatsTableUpdateCompanionBuilder,
          (
            DbUserTrackStat,
            BaseReferences<
              _$AuroraDatabase,
              $UserTrackStatsTable,
              DbUserTrackStat
            >,
          ),
          DbUserTrackStat,
          PrefetchHooks Function()
        > {
  $$UserTrackStatsTableTableManager(
    _$AuroraDatabase db,
    $UserTrackStatsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserTrackStatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserTrackStatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserTrackStatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> trackId = const Value.absent(),
                Value<int?> playCount = const Value.absent(),
                Value<int?> skipCount = const Value.absent(),
                Value<int?> completeCount = const Value.absent(),
                Value<int?> replayCount = const Value.absent(),
                Value<int?> totalListenMs = const Value.absent(),
                Value<int?> lastPlayedAt = const Value.absent(),
                Value<int?> likeState = const Value.absent(),
                Value<double?> decayedScore = const Value.absent(),
                Value<int?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserTrackStatsCompanion(
                trackId: trackId,
                playCount: playCount,
                skipCount: skipCount,
                completeCount: completeCount,
                replayCount: replayCount,
                totalListenMs: totalListenMs,
                lastPlayedAt: lastPlayedAt,
                likeState: likeState,
                decayedScore: decayedScore,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String trackId,
                Value<int?> playCount = const Value.absent(),
                Value<int?> skipCount = const Value.absent(),
                Value<int?> completeCount = const Value.absent(),
                Value<int?> replayCount = const Value.absent(),
                Value<int?> totalListenMs = const Value.absent(),
                Value<int?> lastPlayedAt = const Value.absent(),
                Value<int?> likeState = const Value.absent(),
                Value<double?> decayedScore = const Value.absent(),
                Value<int?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserTrackStatsCompanion.insert(
                trackId: trackId,
                playCount: playCount,
                skipCount: skipCount,
                completeCount: completeCount,
                replayCount: replayCount,
                totalListenMs: totalListenMs,
                lastPlayedAt: lastPlayedAt,
                likeState: likeState,
                decayedScore: decayedScore,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserTrackStatsTableProcessedTableManager =
    ProcessedTableManager<
      _$AuroraDatabase,
      $UserTrackStatsTable,
      DbUserTrackStat,
      $$UserTrackStatsTableFilterComposer,
      $$UserTrackStatsTableOrderingComposer,
      $$UserTrackStatsTableAnnotationComposer,
      $$UserTrackStatsTableCreateCompanionBuilder,
      $$UserTrackStatsTableUpdateCompanionBuilder,
      (
        DbUserTrackStat,
        BaseReferences<_$AuroraDatabase, $UserTrackStatsTable, DbUserTrackStat>,
      ),
      DbUserTrackStat,
      PrefetchHooks Function()
    >;
typedef $$PreferenceProfileTableCreateCompanionBuilder =
    PreferenceProfileCompanion Function({
      Value<int> id,
      Value<int?> version,
      required String json,
      Value<int?> updatedAt,
    });
typedef $$PreferenceProfileTableUpdateCompanionBuilder =
    PreferenceProfileCompanion Function({
      Value<int> id,
      Value<int?> version,
      Value<String> json,
      Value<int?> updatedAt,
    });

class $$PreferenceProfileTableFilterComposer
    extends Composer<_$AuroraDatabase, $PreferenceProfileTable> {
  $$PreferenceProfileTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PreferenceProfileTableOrderingComposer
    extends Composer<_$AuroraDatabase, $PreferenceProfileTable> {
  $$PreferenceProfileTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PreferenceProfileTableAnnotationComposer
    extends Composer<_$AuroraDatabase, $PreferenceProfileTable> {
  $$PreferenceProfileTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PreferenceProfileTableTableManager
    extends
        RootTableManager<
          _$AuroraDatabase,
          $PreferenceProfileTable,
          DbPreferenceProfile,
          $$PreferenceProfileTableFilterComposer,
          $$PreferenceProfileTableOrderingComposer,
          $$PreferenceProfileTableAnnotationComposer,
          $$PreferenceProfileTableCreateCompanionBuilder,
          $$PreferenceProfileTableUpdateCompanionBuilder,
          (
            DbPreferenceProfile,
            BaseReferences<
              _$AuroraDatabase,
              $PreferenceProfileTable,
              DbPreferenceProfile
            >,
          ),
          DbPreferenceProfile,
          PrefetchHooks Function()
        > {
  $$PreferenceProfileTableTableManager(
    _$AuroraDatabase db,
    $PreferenceProfileTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PreferenceProfileTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PreferenceProfileTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PreferenceProfileTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> version = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<int?> updatedAt = const Value.absent(),
              }) => PreferenceProfileCompanion(
                id: id,
                version: version,
                json: json,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> version = const Value.absent(),
                required String json,
                Value<int?> updatedAt = const Value.absent(),
              }) => PreferenceProfileCompanion.insert(
                id: id,
                version: version,
                json: json,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PreferenceProfileTableProcessedTableManager =
    ProcessedTableManager<
      _$AuroraDatabase,
      $PreferenceProfileTable,
      DbPreferenceProfile,
      $$PreferenceProfileTableFilterComposer,
      $$PreferenceProfileTableOrderingComposer,
      $$PreferenceProfileTableAnnotationComposer,
      $$PreferenceProfileTableCreateCompanionBuilder,
      $$PreferenceProfileTableUpdateCompanionBuilder,
      (
        DbPreferenceProfile,
        BaseReferences<
          _$AuroraDatabase,
          $PreferenceProfileTable,
          DbPreferenceProfile
        >,
      ),
      DbPreferenceProfile,
      PrefetchHooks Function()
    >;
typedef $$QueueItemsTableCreateCompanionBuilder =
    QueueItemsCompanion Function({
      required String id,
      Value<String?> trackId,
      Value<String?> origin,
      Value<int> position,
      Value<double?> frozenScore,
      Value<int?> addedAt,
      Value<int> rowid,
    });
typedef $$QueueItemsTableUpdateCompanionBuilder =
    QueueItemsCompanion Function({
      Value<String> id,
      Value<String?> trackId,
      Value<String?> origin,
      Value<int> position,
      Value<double?> frozenScore,
      Value<int?> addedAt,
      Value<int> rowid,
    });

class $$QueueItemsTableFilterComposer
    extends Composer<_$AuroraDatabase, $QueueItemsTable> {
  $$QueueItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get frozenScore => $composableBuilder(
    column: $table.frozenScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QueueItemsTableOrderingComposer
    extends Composer<_$AuroraDatabase, $QueueItemsTable> {
  $$QueueItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get frozenScore => $composableBuilder(
    column: $table.frozenScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QueueItemsTableAnnotationComposer
    extends Composer<_$AuroraDatabase, $QueueItemsTable> {
  $$QueueItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get trackId =>
      $composableBuilder(column: $table.trackId, builder: (column) => column);

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<double> get frozenScore => $composableBuilder(
    column: $table.frozenScore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);
}

class $$QueueItemsTableTableManager
    extends
        RootTableManager<
          _$AuroraDatabase,
          $QueueItemsTable,
          DbQueueItem,
          $$QueueItemsTableFilterComposer,
          $$QueueItemsTableOrderingComposer,
          $$QueueItemsTableAnnotationComposer,
          $$QueueItemsTableCreateCompanionBuilder,
          $$QueueItemsTableUpdateCompanionBuilder,
          (
            DbQueueItem,
            BaseReferences<_$AuroraDatabase, $QueueItemsTable, DbQueueItem>,
          ),
          DbQueueItem,
          PrefetchHooks Function()
        > {
  $$QueueItemsTableTableManager(_$AuroraDatabase db, $QueueItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QueueItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QueueItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QueueItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> trackId = const Value.absent(),
                Value<String?> origin = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<double?> frozenScore = const Value.absent(),
                Value<int?> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QueueItemsCompanion(
                id: id,
                trackId: trackId,
                origin: origin,
                position: position,
                frozenScore: frozenScore,
                addedAt: addedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> trackId = const Value.absent(),
                Value<String?> origin = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<double?> frozenScore = const Value.absent(),
                Value<int?> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QueueItemsCompanion.insert(
                id: id,
                trackId: trackId,
                origin: origin,
                position: position,
                frozenScore: frozenScore,
                addedAt: addedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QueueItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AuroraDatabase,
      $QueueItemsTable,
      DbQueueItem,
      $$QueueItemsTableFilterComposer,
      $$QueueItemsTableOrderingComposer,
      $$QueueItemsTableAnnotationComposer,
      $$QueueItemsTableCreateCompanionBuilder,
      $$QueueItemsTableUpdateCompanionBuilder,
      (
        DbQueueItem,
        BaseReferences<_$AuroraDatabase, $QueueItemsTable, DbQueueItem>,
      ),
      DbQueueItem,
      PrefetchHooks Function()
    >;
typedef $$PlaybackStateTableCreateCompanionBuilder =
    PlaybackStateCompanion Function({
      Value<int> id,
      Value<String?> trackId,
      Value<int?> positionMs,
      Value<int?> isPlaying,
      Value<int?> shuffle,
      Value<String?> repeatMode,
      Value<String?> sessionId,
      Value<int?> updatedAt,
    });
typedef $$PlaybackStateTableUpdateCompanionBuilder =
    PlaybackStateCompanion Function({
      Value<int> id,
      Value<String?> trackId,
      Value<int?> positionMs,
      Value<int?> isPlaying,
      Value<int?> shuffle,
      Value<String?> repeatMode,
      Value<String?> sessionId,
      Value<int?> updatedAt,
    });

class $$PlaybackStateTableFilterComposer
    extends Composer<_$AuroraDatabase, $PlaybackStateTable> {
  $$PlaybackStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isPlaying => $composableBuilder(
    column: $table.isPlaying,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get shuffle => $composableBuilder(
    column: $table.shuffle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repeatMode => $composableBuilder(
    column: $table.repeatMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlaybackStateTableOrderingComposer
    extends Composer<_$AuroraDatabase, $PlaybackStateTable> {
  $$PlaybackStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isPlaying => $composableBuilder(
    column: $table.isPlaying,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get shuffle => $composableBuilder(
    column: $table.shuffle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeatMode => $composableBuilder(
    column: $table.repeatMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaybackStateTableAnnotationComposer
    extends Composer<_$AuroraDatabase, $PlaybackStateTable> {
  $$PlaybackStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get trackId =>
      $composableBuilder(column: $table.trackId, builder: (column) => column);

  GeneratedColumn<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isPlaying =>
      $composableBuilder(column: $table.isPlaying, builder: (column) => column);

  GeneratedColumn<int> get shuffle =>
      $composableBuilder(column: $table.shuffle, builder: (column) => column);

  GeneratedColumn<String> get repeatMode => $composableBuilder(
    column: $table.repeatMode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PlaybackStateTableTableManager
    extends
        RootTableManager<
          _$AuroraDatabase,
          $PlaybackStateTable,
          DbPlaybackState,
          $$PlaybackStateTableFilterComposer,
          $$PlaybackStateTableOrderingComposer,
          $$PlaybackStateTableAnnotationComposer,
          $$PlaybackStateTableCreateCompanionBuilder,
          $$PlaybackStateTableUpdateCompanionBuilder,
          (
            DbPlaybackState,
            BaseReferences<
              _$AuroraDatabase,
              $PlaybackStateTable,
              DbPlaybackState
            >,
          ),
          DbPlaybackState,
          PrefetchHooks Function()
        > {
  $$PlaybackStateTableTableManager(
    _$AuroraDatabase db,
    $PlaybackStateTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaybackStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaybackStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaybackStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> trackId = const Value.absent(),
                Value<int?> positionMs = const Value.absent(),
                Value<int?> isPlaying = const Value.absent(),
                Value<int?> shuffle = const Value.absent(),
                Value<String?> repeatMode = const Value.absent(),
                Value<String?> sessionId = const Value.absent(),
                Value<int?> updatedAt = const Value.absent(),
              }) => PlaybackStateCompanion(
                id: id,
                trackId: trackId,
                positionMs: positionMs,
                isPlaying: isPlaying,
                shuffle: shuffle,
                repeatMode: repeatMode,
                sessionId: sessionId,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> trackId = const Value.absent(),
                Value<int?> positionMs = const Value.absent(),
                Value<int?> isPlaying = const Value.absent(),
                Value<int?> shuffle = const Value.absent(),
                Value<String?> repeatMode = const Value.absent(),
                Value<String?> sessionId = const Value.absent(),
                Value<int?> updatedAt = const Value.absent(),
              }) => PlaybackStateCompanion.insert(
                id: id,
                trackId: trackId,
                positionMs: positionMs,
                isPlaying: isPlaying,
                shuffle: shuffle,
                repeatMode: repeatMode,
                sessionId: sessionId,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlaybackStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AuroraDatabase,
      $PlaybackStateTable,
      DbPlaybackState,
      $$PlaybackStateTableFilterComposer,
      $$PlaybackStateTableOrderingComposer,
      $$PlaybackStateTableAnnotationComposer,
      $$PlaybackStateTableCreateCompanionBuilder,
      $$PlaybackStateTableUpdateCompanionBuilder,
      (
        DbPlaybackState,
        BaseReferences<_$AuroraDatabase, $PlaybackStateTable, DbPlaybackState>,
      ),
      DbPlaybackState,
      PrefetchHooks Function()
    >;
typedef $$DownloadJobsTableCreateCompanionBuilder =
    DownloadJobsCompanion Function({
      required String id,
      Value<String?> trackId,
      Value<String?> state,
      Value<double?> progress,
      Value<int?> bytesReceived,
      Value<int?> bytesTotal,
      Value<String?> errorCode,
      Value<String?> errorMessage,
      Value<int?> attempts,
      Value<String?> qualityLabel,
      Value<String?> filePath,
      Value<int?> createdAt,
      Value<int?> updatedAt,
      Value<int> rowid,
    });
typedef $$DownloadJobsTableUpdateCompanionBuilder =
    DownloadJobsCompanion Function({
      Value<String> id,
      Value<String?> trackId,
      Value<String?> state,
      Value<double?> progress,
      Value<int?> bytesReceived,
      Value<int?> bytesTotal,
      Value<String?> errorCode,
      Value<String?> errorMessage,
      Value<int?> attempts,
      Value<String?> qualityLabel,
      Value<String?> filePath,
      Value<int?> createdAt,
      Value<int?> updatedAt,
      Value<int> rowid,
    });

class $$DownloadJobsTableFilterComposer
    extends Composer<_$AuroraDatabase, $DownloadJobsTable> {
  $$DownloadJobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bytesReceived => $composableBuilder(
    column: $table.bytesReceived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bytesTotal => $composableBuilder(
    column: $table.bytesTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get qualityLabel => $composableBuilder(
    column: $table.qualityLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DownloadJobsTableOrderingComposer
    extends Composer<_$AuroraDatabase, $DownloadJobsTable> {
  $$DownloadJobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bytesReceived => $composableBuilder(
    column: $table.bytesReceived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bytesTotal => $composableBuilder(
    column: $table.bytesTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get qualityLabel => $composableBuilder(
    column: $table.qualityLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DownloadJobsTableAnnotationComposer
    extends Composer<_$AuroraDatabase, $DownloadJobsTable> {
  $$DownloadJobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get trackId =>
      $composableBuilder(column: $table.trackId, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<double> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<int> get bytesReceived => $composableBuilder(
    column: $table.bytesReceived,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bytesTotal => $composableBuilder(
    column: $table.bytesTotal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorCode =>
      $composableBuilder(column: $table.errorCode, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get qualityLabel => $composableBuilder(
    column: $table.qualityLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DownloadJobsTableTableManager
    extends
        RootTableManager<
          _$AuroraDatabase,
          $DownloadJobsTable,
          DbDownloadJob,
          $$DownloadJobsTableFilterComposer,
          $$DownloadJobsTableOrderingComposer,
          $$DownloadJobsTableAnnotationComposer,
          $$DownloadJobsTableCreateCompanionBuilder,
          $$DownloadJobsTableUpdateCompanionBuilder,
          (
            DbDownloadJob,
            BaseReferences<_$AuroraDatabase, $DownloadJobsTable, DbDownloadJob>,
          ),
          DbDownloadJob,
          PrefetchHooks Function()
        > {
  $$DownloadJobsTableTableManager(_$AuroraDatabase db, $DownloadJobsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadJobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadJobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadJobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> trackId = const Value.absent(),
                Value<String?> state = const Value.absent(),
                Value<double?> progress = const Value.absent(),
                Value<int?> bytesReceived = const Value.absent(),
                Value<int?> bytesTotal = const Value.absent(),
                Value<String?> errorCode = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<int?> attempts = const Value.absent(),
                Value<String?> qualityLabel = const Value.absent(),
                Value<String?> filePath = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadJobsCompanion(
                id: id,
                trackId: trackId,
                state: state,
                progress: progress,
                bytesReceived: bytesReceived,
                bytesTotal: bytesTotal,
                errorCode: errorCode,
                errorMessage: errorMessage,
                attempts: attempts,
                qualityLabel: qualityLabel,
                filePath: filePath,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> trackId = const Value.absent(),
                Value<String?> state = const Value.absent(),
                Value<double?> progress = const Value.absent(),
                Value<int?> bytesReceived = const Value.absent(),
                Value<int?> bytesTotal = const Value.absent(),
                Value<String?> errorCode = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<int?> attempts = const Value.absent(),
                Value<String?> qualityLabel = const Value.absent(),
                Value<String?> filePath = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadJobsCompanion.insert(
                id: id,
                trackId: trackId,
                state: state,
                progress: progress,
                bytesReceived: bytesReceived,
                bytesTotal: bytesTotal,
                errorCode: errorCode,
                errorMessage: errorMessage,
                attempts: attempts,
                qualityLabel: qualityLabel,
                filePath: filePath,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DownloadJobsTableProcessedTableManager =
    ProcessedTableManager<
      _$AuroraDatabase,
      $DownloadJobsTable,
      DbDownloadJob,
      $$DownloadJobsTableFilterComposer,
      $$DownloadJobsTableOrderingComposer,
      $$DownloadJobsTableAnnotationComposer,
      $$DownloadJobsTableCreateCompanionBuilder,
      $$DownloadJobsTableUpdateCompanionBuilder,
      (
        DbDownloadJob,
        BaseReferences<_$AuroraDatabase, $DownloadJobsTable, DbDownloadJob>,
      ),
      DbDownloadJob,
      PrefetchHooks Function()
    >;
typedef $$SearchHistoryTableCreateCompanionBuilder =
    SearchHistoryCompanion Function({
      required String id,
      required String query,
      Value<int?> createdAt,
      Value<int> rowid,
    });
typedef $$SearchHistoryTableUpdateCompanionBuilder =
    SearchHistoryCompanion Function({
      Value<String> id,
      Value<String> query,
      Value<int?> createdAt,
      Value<int> rowid,
    });

class $$SearchHistoryTableFilterComposer
    extends Composer<_$AuroraDatabase, $SearchHistoryTable> {
  $$SearchHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SearchHistoryTableOrderingComposer
    extends Composer<_$AuroraDatabase, $SearchHistoryTable> {
  $$SearchHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SearchHistoryTableAnnotationComposer
    extends Composer<_$AuroraDatabase, $SearchHistoryTable> {
  $$SearchHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get query =>
      $composableBuilder(column: $table.query, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SearchHistoryTableTableManager
    extends
        RootTableManager<
          _$AuroraDatabase,
          $SearchHistoryTable,
          DbSearchHistory,
          $$SearchHistoryTableFilterComposer,
          $$SearchHistoryTableOrderingComposer,
          $$SearchHistoryTableAnnotationComposer,
          $$SearchHistoryTableCreateCompanionBuilder,
          $$SearchHistoryTableUpdateCompanionBuilder,
          (
            DbSearchHistory,
            BaseReferences<
              _$AuroraDatabase,
              $SearchHistoryTable,
              DbSearchHistory
            >,
          ),
          DbSearchHistory,
          PrefetchHooks Function()
        > {
  $$SearchHistoryTableTableManager(
    _$AuroraDatabase db,
    $SearchHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SearchHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SearchHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SearchHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> query = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SearchHistoryCompanion(
                id: id,
                query: query,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String query,
                Value<int?> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SearchHistoryCompanion.insert(
                id: id,
                query: query,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SearchHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AuroraDatabase,
      $SearchHistoryTable,
      DbSearchHistory,
      $$SearchHistoryTableFilterComposer,
      $$SearchHistoryTableOrderingComposer,
      $$SearchHistoryTableAnnotationComposer,
      $$SearchHistoryTableCreateCompanionBuilder,
      $$SearchHistoryTableUpdateCompanionBuilder,
      (
        DbSearchHistory,
        BaseReferences<_$AuroraDatabase, $SearchHistoryTable, DbSearchHistory>,
      ),
      DbSearchHistory,
      PrefetchHooks Function()
    >;
typedef $$RecoSnapshotsTableCreateCompanionBuilder =
    RecoSnapshotsCompanion Function({
      required String id,
      required String surface,
      required String json,
      Value<int?> computedAt,
      Value<int?> ttlMs,
      Value<int> rowid,
    });
typedef $$RecoSnapshotsTableUpdateCompanionBuilder =
    RecoSnapshotsCompanion Function({
      Value<String> id,
      Value<String> surface,
      Value<String> json,
      Value<int?> computedAt,
      Value<int?> ttlMs,
      Value<int> rowid,
    });

class $$RecoSnapshotsTableFilterComposer
    extends Composer<_$AuroraDatabase, $RecoSnapshotsTable> {
  $$RecoSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get surface => $composableBuilder(
    column: $table.surface,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get computedAt => $composableBuilder(
    column: $table.computedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ttlMs => $composableBuilder(
    column: $table.ttlMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecoSnapshotsTableOrderingComposer
    extends Composer<_$AuroraDatabase, $RecoSnapshotsTable> {
  $$RecoSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get surface => $composableBuilder(
    column: $table.surface,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get computedAt => $composableBuilder(
    column: $table.computedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ttlMs => $composableBuilder(
    column: $table.ttlMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecoSnapshotsTableAnnotationComposer
    extends Composer<_$AuroraDatabase, $RecoSnapshotsTable> {
  $$RecoSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get surface =>
      $composableBuilder(column: $table.surface, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);

  GeneratedColumn<int> get computedAt => $composableBuilder(
    column: $table.computedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ttlMs =>
      $composableBuilder(column: $table.ttlMs, builder: (column) => column);
}

class $$RecoSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AuroraDatabase,
          $RecoSnapshotsTable,
          DbRecoSnapshot,
          $$RecoSnapshotsTableFilterComposer,
          $$RecoSnapshotsTableOrderingComposer,
          $$RecoSnapshotsTableAnnotationComposer,
          $$RecoSnapshotsTableCreateCompanionBuilder,
          $$RecoSnapshotsTableUpdateCompanionBuilder,
          (
            DbRecoSnapshot,
            BaseReferences<
              _$AuroraDatabase,
              $RecoSnapshotsTable,
              DbRecoSnapshot
            >,
          ),
          DbRecoSnapshot,
          PrefetchHooks Function()
        > {
  $$RecoSnapshotsTableTableManager(
    _$AuroraDatabase db,
    $RecoSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecoSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecoSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecoSnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> surface = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<int?> computedAt = const Value.absent(),
                Value<int?> ttlMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecoSnapshotsCompanion(
                id: id,
                surface: surface,
                json: json,
                computedAt: computedAt,
                ttlMs: ttlMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String surface,
                required String json,
                Value<int?> computedAt = const Value.absent(),
                Value<int?> ttlMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecoSnapshotsCompanion.insert(
                id: id,
                surface: surface,
                json: json,
                computedAt: computedAt,
                ttlMs: ttlMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecoSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AuroraDatabase,
      $RecoSnapshotsTable,
      DbRecoSnapshot,
      $$RecoSnapshotsTableFilterComposer,
      $$RecoSnapshotsTableOrderingComposer,
      $$RecoSnapshotsTableAnnotationComposer,
      $$RecoSnapshotsTableCreateCompanionBuilder,
      $$RecoSnapshotsTableUpdateCompanionBuilder,
      (
        DbRecoSnapshot,
        BaseReferences<_$AuroraDatabase, $RecoSnapshotsTable, DbRecoSnapshot>,
      ),
      DbRecoSnapshot,
      PrefetchHooks Function()
    >;
typedef $$MetadataCacheTableCreateCompanionBuilder =
    MetadataCacheCompanion Function({
      required String key,
      Value<String?> json,
      Value<int?> fetchedAt,
      Value<int?> ttlMs,
      Value<int> rowid,
    });
typedef $$MetadataCacheTableUpdateCompanionBuilder =
    MetadataCacheCompanion Function({
      Value<String> key,
      Value<String?> json,
      Value<int?> fetchedAt,
      Value<int?> ttlMs,
      Value<int> rowid,
    });

class $$MetadataCacheTableFilterComposer
    extends Composer<_$AuroraDatabase, $MetadataCacheTable> {
  $$MetadataCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ttlMs => $composableBuilder(
    column: $table.ttlMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MetadataCacheTableOrderingComposer
    extends Composer<_$AuroraDatabase, $MetadataCacheTable> {
  $$MetadataCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ttlMs => $composableBuilder(
    column: $table.ttlMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MetadataCacheTableAnnotationComposer
    extends Composer<_$AuroraDatabase, $MetadataCacheTable> {
  $$MetadataCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);

  GeneratedColumn<int> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<int> get ttlMs =>
      $composableBuilder(column: $table.ttlMs, builder: (column) => column);
}

class $$MetadataCacheTableTableManager
    extends
        RootTableManager<
          _$AuroraDatabase,
          $MetadataCacheTable,
          DbMetadataCache,
          $$MetadataCacheTableFilterComposer,
          $$MetadataCacheTableOrderingComposer,
          $$MetadataCacheTableAnnotationComposer,
          $$MetadataCacheTableCreateCompanionBuilder,
          $$MetadataCacheTableUpdateCompanionBuilder,
          (
            DbMetadataCache,
            BaseReferences<
              _$AuroraDatabase,
              $MetadataCacheTable,
              DbMetadataCache
            >,
          ),
          DbMetadataCache,
          PrefetchHooks Function()
        > {
  $$MetadataCacheTableTableManager(
    _$AuroraDatabase db,
    $MetadataCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetadataCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetadataCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetadataCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String?> json = const Value.absent(),
                Value<int?> fetchedAt = const Value.absent(),
                Value<int?> ttlMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MetadataCacheCompanion(
                key: key,
                json: json,
                fetchedAt: fetchedAt,
                ttlMs: ttlMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                Value<String?> json = const Value.absent(),
                Value<int?> fetchedAt = const Value.absent(),
                Value<int?> ttlMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MetadataCacheCompanion.insert(
                key: key,
                json: json,
                fetchedAt: fetchedAt,
                ttlMs: ttlMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MetadataCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AuroraDatabase,
      $MetadataCacheTable,
      DbMetadataCache,
      $$MetadataCacheTableFilterComposer,
      $$MetadataCacheTableOrderingComposer,
      $$MetadataCacheTableAnnotationComposer,
      $$MetadataCacheTableCreateCompanionBuilder,
      $$MetadataCacheTableUpdateCompanionBuilder,
      (
        DbMetadataCache,
        BaseReferences<_$AuroraDatabase, $MetadataCacheTable, DbMetadataCache>,
      ),
      DbMetadataCache,
      PrefetchHooks Function()
    >;

class $AuroraDatabaseManager {
  final _$AuroraDatabase _db;
  $AuroraDatabaseManager(this._db);
  $$TracksTableTableManager get tracks =>
      $$TracksTableTableManager(_db, _db.tracks);
  $$TrackArtistsTableTableManager get trackArtists =>
      $$TrackArtistsTableTableManager(_db, _db.trackArtists);
  $$TrackGenresTableTableManager get trackGenres =>
      $$TrackGenresTableTableManager(_db, _db.trackGenres);
  $$ArtistsTableTableManager get artists =>
      $$ArtistsTableTableManager(_db, _db.artists);
  $$AlbumsTableTableManager get albums =>
      $$AlbumsTableTableManager(_db, _db.albums);
  $$GenresTableTableManager get genres =>
      $$GenresTableTableManager(_db, _db.genres);
  $$ArtworksTableTableManager get artworks =>
      $$ArtworksTableTableManager(_db, _db.artworks);
  $$PlaylistsTableTableManager get playlists =>
      $$PlaylistsTableTableManager(_db, _db.playlists);
  $$PlaylistEntriesTableTableManager get playlistEntries =>
      $$PlaylistEntriesTableTableManager(_db, _db.playlistEntries);
  $$PlayEventsTableTableManager get playEvents =>
      $$PlayEventsTableTableManager(_db, _db.playEvents);
  $$UserTrackStatsTableTableManager get userTrackStats =>
      $$UserTrackStatsTableTableManager(_db, _db.userTrackStats);
  $$PreferenceProfileTableTableManager get preferenceProfile =>
      $$PreferenceProfileTableTableManager(_db, _db.preferenceProfile);
  $$QueueItemsTableTableManager get queueItems =>
      $$QueueItemsTableTableManager(_db, _db.queueItems);
  $$PlaybackStateTableTableManager get playbackState =>
      $$PlaybackStateTableTableManager(_db, _db.playbackState);
  $$DownloadJobsTableTableManager get downloadJobs =>
      $$DownloadJobsTableTableManager(_db, _db.downloadJobs);
  $$SearchHistoryTableTableManager get searchHistory =>
      $$SearchHistoryTableTableManager(_db, _db.searchHistory);
  $$RecoSnapshotsTableTableManager get recoSnapshots =>
      $$RecoSnapshotsTableTableManager(_db, _db.recoSnapshots);
  $$MetadataCacheTableTableManager get metadataCache =>
      $$MetadataCacheTableTableManager(_db, _db.metadataCache);
}

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalEntryRecord {
  const LocalEntryRecord({
    required this.id,
    required this.familyId,
    required this.type,
    required this.title,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
    this.happensAt,
    this.deletedAt,
    this.version = 1,
  });

  final String id;
  final String familyId;
  final String type;
  final String title;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? happensAt;
  final DateTime? deletedAt;
  final int version;

  bool get isDeleted => deletedAt != null;
  DateTime get effectiveDate => (happensAt ?? createdAt).toLocal();

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'familyId': familyId,
        'type': type,
        'title': title,
        'note': note,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'updatedAt': updatedAt.toUtc().toIso8601String(),
        'happensAt': happensAt?.toUtc().toIso8601String(),
        'deletedAt': deletedAt?.toUtc().toIso8601String(),
        'version': version,
      };

  factory LocalEntryRecord.fromJson(Map<String, Object?> json) {
    final String id = _requiredString(json, 'id');
    final String familyId = _requiredString(json, 'familyId');
    final String type = _requiredString(json, 'type');
    final String title = _requiredString(json, 'title');
    final String note = json['note'] as String? ?? '';
    return LocalEntryRecord(
      id: id,
      familyId: familyId,
      type: type,
      title: title,
      note: note,
      createdAt: DateTime.parse(_requiredString(json, 'createdAt')).toUtc(),
      updatedAt: DateTime.parse(_requiredString(json, 'updatedAt')).toUtc(),
      happensAt: _optionalDate(json['happensAt']),
      deletedAt: _optionalDate(json['deletedAt']),
      version: json['version'] is int ? json['version']! as int : 1,
    );
  }

  static String _requiredString(Map<String, Object?> json, String key) {
    final Object? value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Missing or invalid $key');
    }
    return value;
  }

  static DateTime? _optionalDate(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.parse(value).toUtc();
  }
}

class LocalEntryStore {
  LocalEntryStore({SharedPreferences? preferences}) : _providedPreferences = preferences;

  static const int schemaVersion = 2;
  static const int maxRecords = 5000;
  static const Set<int> _supportedSchemaVersions = <int>{1, 2};
  static const Set<String> _supportedTypes = <String>{
    'memory',
    'event',
    'project',
    'tradition',
    'child',
  };
  static const String _dataKey = 'familyiq.local.entries.v1';
  static const String _backupKey = 'familyiq.local.entries.backup.v1';

  final SharedPreferences? _providedPreferences;

  Future<SharedPreferences> get _preferences async =>
      _providedPreferences ?? SharedPreferences.getInstance();

  Future<List<LocalEntryRecord>> read({
    required String familyId,
    bool includeDeleted = false,
  }) async {
    final SharedPreferences preferences = await _preferences;
    final String? encoded = preferences.getString(_dataKey);
    if (encoded == null || encoded.isEmpty) return <LocalEntryRecord>[];

    try {
      return _decode(encoded, familyId: familyId, includeDeleted: includeDeleted);
    } on FormatException {
      final String? backup = preferences.getString(_backupKey);
      if (backup == null || backup.isEmpty) rethrow;
      return _decode(backup, familyId: familyId, includeDeleted: includeDeleted);
    }
  }

  Future<void> upsert(LocalEntryRecord record) async {
    _validate(record);
    final List<LocalEntryRecord> all = await _readAll();
    final int existingIndex = all.indexWhere((LocalEntryRecord item) => item.id == record.id);
    if (existingIndex >= 0) {
      final LocalEntryRecord current = all[existingIndex];
      if (record.familyId != current.familyId) {
        throw const LocalStoreException('family_mismatch');
      }
      if (record.version < current.version) {
        throw const LocalStoreException('stale_record');
      }
      all[existingIndex] = record;
    } else {
      all.add(record);
    }
    if (all.length > maxRecords) throw const LocalStoreException('record_limit_reached');
    await _writeAll(all);
  }

  Future<void> softDelete({required String id, required String familyId}) async {
    final List<LocalEntryRecord> all = await _readAll();
    final int index = all.indexWhere(
      (LocalEntryRecord item) => item.id == id && item.familyId == familyId,
    );
    if (index < 0) return;
    final LocalEntryRecord current = all[index];
    final DateTime now = DateTime.now().toUtc();
    all[index] = LocalEntryRecord(
      id: current.id,
      familyId: current.familyId,
      type: current.type,
      title: current.title,
      note: current.note,
      createdAt: current.createdAt,
      updatedAt: now,
      happensAt: current.happensAt,
      deletedAt: now,
      version: current.version + 1,
    );
    await _writeAll(all);
  }

  Future<void> replaceAll(List<LocalEntryRecord> records) async {
    if (records.length > maxRecords) throw const LocalStoreException('record_limit_reached');
    final Set<String> ids = <String>{};
    for (final LocalEntryRecord record in records) {
      _validate(record);
      if (!ids.add(record.id)) throw const LocalStoreException('duplicate_id');
    }
    await _writeAll(records);
  }

  Future<void> clearFamily(String familyId) async {
    final List<LocalEntryRecord> all = await _readAll();
    all.removeWhere((LocalEntryRecord item) => item.familyId == familyId);
    await _writeAll(all);
  }

  Future<List<LocalEntryRecord>> _readAll() async {
    final SharedPreferences preferences = await _preferences;
    final String? encoded = preferences.getString(_dataKey);
    if (encoded == null || encoded.isEmpty) return <LocalEntryRecord>[];
    return _decodeAll(encoded);
  }

  List<LocalEntryRecord> _decode(
    String encoded, {
    required String familyId,
    required bool includeDeleted,
  }) {
    final List<LocalEntryRecord> records = _decodeAll(encoded)
        .where(
          (LocalEntryRecord item) =>
              item.familyId == familyId && (includeDeleted || !item.isDeleted),
        )
        .toList(growable: false)
      ..sort((LocalEntryRecord a, LocalEntryRecord b) => b.updatedAt.compareTo(a.updatedAt));
    return records;
  }

  List<LocalEntryRecord> _decodeAll(String encoded) {
    final Object? decoded = jsonDecode(encoded);
    if (decoded is! Map<Object?, Object?>) {
      throw const FormatException('Invalid local data envelope');
    }
    final Map<String, Object?> envelope = decoded.cast<String, Object?>();
    _validateEnvelope(envelope);
    return (envelope['records']! as List<Object?>)
        .map((Object? value) {
          if (value is! Map<Object?, Object?>) {
            throw const FormatException('Invalid local data record');
          }
          return LocalEntryRecord.fromJson(value.cast<String, Object?>());
        })
        .toList(growable: true);
  }

  Future<void> _writeAll(List<LocalEntryRecord> records) async {
    final SharedPreferences preferences = await _preferences;
    final String? current = preferences.getString(_dataKey);
    if (current != null && current.isNotEmpty) {
      await preferences.setString(_backupKey, current);
    }
    final String encoded = jsonEncode(<String, Object?>{
      'schemaVersion': schemaVersion,
      'writtenAt': DateTime.now().toUtc().toIso8601String(),
      'records': records.map((LocalEntryRecord item) => item.toJson()).toList(growable: false),
    });
    final bool saved = await preferences.setString(_dataKey, encoded);
    if (!saved) throw const LocalStoreException('write_failed');
  }

  void _validate(LocalEntryRecord record) {
    if (record.id.trim().isEmpty || record.familyId.trim().isEmpty) {
      throw const LocalStoreException('invalid_identity');
    }
    if (!_supportedTypes.contains(record.type)) {
      throw const LocalStoreException('invalid_type');
    }
    if (record.title.trim().isEmpty || record.title.length > 160) {
      throw const LocalStoreException('invalid_title');
    }
    if (record.note.length > 20000) throw const LocalStoreException('note_too_large');
    if (record.version < 1) throw const LocalStoreException('invalid_version');
    if (record.updatedAt.isBefore(record.createdAt)) {
      throw const LocalStoreException('invalid_timestamps');
    }
  }

  void _validateEnvelope(Map<String, Object?> envelope) {
    final Object? version = envelope['schemaVersion'];
    if (version is! int || !_supportedSchemaVersions.contains(version)) {
      throw const FormatException('Unsupported local data schema');
    }
    if (envelope['records'] is! List<Object?>) {
      throw const FormatException('Invalid local data records');
    }
  }
}

class LocalStoreException implements Exception {
  const LocalStoreException(this.code);

  final String code;

  @override
  String toString() => 'LocalStoreException($code)';
}

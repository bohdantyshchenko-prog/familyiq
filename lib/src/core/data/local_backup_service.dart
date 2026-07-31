import 'dart:convert';

import 'local_entry_store.dart';

class LocalBackupService {
  const LocalBackupService();

  static const int exportSchemaVersion = 1;

  String exportEntries({required String familyId, required List<LocalEntryRecord> entries}) {
    final List<LocalEntryRecord> familyEntries = entries
        .where((LocalEntryRecord entry) => entry.familyId == familyId)
        .toList(growable: false);
    return const JsonEncoder.withIndent('  ').convert(<String, Object?>{
      'product': 'FamilyIQ',
      'schemaVersion': exportSchemaVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'familyId': familyId,
      'records': familyEntries.map((LocalEntryRecord entry) => entry.toJson()).toList(growable: false),
    });
  }

  List<LocalEntryRecord> importEntries({required String encoded, required String expectedFamilyId}) {
    if (encoded.length > 10 * 1024 * 1024) throw const BackupException('backup_too_large');
    final Object? decoded;
    try {
      decoded = jsonDecode(encoded);
    } on FormatException catch (error) {
      throw BackupException('invalid_json', error);
    }
    if (decoded is! Map<Object?, Object?>) throw const BackupException('invalid_backup');
    final Map<String, Object?> root = decoded.cast<String, Object?>();
    if (root['product'] != 'FamilyIQ' || root['schemaVersion'] != exportSchemaVersion) {
      throw const BackupException('unsupported_backup');
    }
    if (root['familyId'] != expectedFamilyId) throw const BackupException('family_mismatch');
    final Object? rawRecords = root['records'];
    if (rawRecords is! List<Object?> || rawRecords.length > LocalEntryStore.maxRecords) {
      throw const BackupException('invalid_records');
    }
    final Set<String> ids = <String>{};
    final List<LocalEntryRecord> records = <LocalEntryRecord>[];
    for (final Object? raw in rawRecords) {
      if (raw is! Map<Object?, Object?>) throw const BackupException('invalid_record');
      final LocalEntryRecord record;
      try {
        record = LocalEntryRecord.fromJson(raw.cast<String, Object?>());
      } on Object catch (error) {
        throw BackupException('invalid_record', error);
      }
      if (record.familyId != expectedFamilyId) throw const BackupException('family_mismatch');
      if (!ids.add(record.id)) throw const BackupException('duplicate_record');
      records.add(record);
    }
    return records;
  }
}

class BackupException implements Exception {
  const BackupException(this.code, [this.cause]);
  final String code;
  final Object? cause;
  @override
  String toString() => 'BackupException($code)';
}

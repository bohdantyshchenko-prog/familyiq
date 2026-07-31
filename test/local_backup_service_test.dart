import 'package:familyiq/src/core/data/local_backup_service.dart';
import 'package:familyiq/src/core/data/local_entry_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const LocalBackupService service = LocalBackupService();
  final DateTime now = DateTime.utc(2026, 7, 31, 12);
  final LocalEntryRecord record = LocalEntryRecord(
    id: 'entry-1',
    familyId: 'family-1',
    type: 'memory',
    title: 'Test memory',
    note: 'Safe local data',
    createdAt: now,
    updatedAt: now,
  );

  test('round trips a valid family backup', () {
    final String encoded = service.exportEntries(familyId: 'family-1', entries: <LocalEntryRecord>[record]);
    final List<LocalEntryRecord> imported = service.importEntries(encoded: encoded, expectedFamilyId: 'family-1');
    expect(imported, hasLength(1));
    expect(imported.single.id, 'entry-1');
    expect(imported.single.title, 'Test memory');
  });

  test('rejects importing a backup for another family', () {
    final String encoded = service.exportEntries(familyId: 'family-1', entries: <LocalEntryRecord>[record]);
    expect(
      () => service.importEntries(encoded: encoded, expectedFamilyId: 'family-2'),
      throwsA(isA<BackupException>().having((BackupException error) => error.code, 'code', 'family_mismatch')),
    );
  });

  test('rejects duplicate record identifiers', () {
    final String encoded = service.exportEntries(familyId: 'family-1', entries: <LocalEntryRecord>[record, record]);
    expect(
      () => service.importEntries(encoded: encoded, expectedFamilyId: 'family-1'),
      throwsA(isA<BackupException>().having((BackupException error) => error.code, 'code', 'duplicate_record')),
    );
  });
}

import 'dart:convert';

import 'package:familyiq/src/core/data/local_entry_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const String dataKey = 'familyiq.local.entries.v1';
  const String backupKey = 'familyiq.local.entries.backup.v1';

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  LocalEntryRecord record({
    required String id,
    required String familyId,
    String type = 'memory',
    DateTime? happensAt,
  }) {
    final DateTime now = DateTime.utc(2026, 8, 13, 10);
    return LocalEntryRecord(
      id: id,
      familyId: familyId,
      type: type,
      title: 'Test $id',
      note: 'Note',
      createdAt: now,
      updatedAt: now,
      happensAt: happensAt,
    );
  }

  test('keeps families isolated and persists event dates', () async {
    final LocalEntryStore store = LocalEntryStore();
    final DateTime eventDate = DateTime.utc(2026, 9, 2, 18, 30);

    await store.upsert(record(id: 'a', familyId: 'family-a'));
    await store.upsert(
      record(id: 'b', familyId: 'family-b', type: 'event', happensAt: eventDate),
    );

    final List<LocalEntryRecord> familyA = await store.read(familyId: 'family-a');
    final List<LocalEntryRecord> familyB = await store.read(familyId: 'family-b');

    expect(familyA.map((LocalEntryRecord item) => item.id), <String>['a']);
    expect(familyB.map((LocalEntryRecord item) => item.id), <String>['b']);
    expect(familyB.single.happensAt, eventDate);
  });

  test('soft delete hides records without destroying them', () async {
    final LocalEntryStore store = LocalEntryStore();
    await store.upsert(record(id: 'delete-me', familyId: 'family-a'));

    await store.softDelete(id: 'delete-me', familyId: 'family-a');

    expect(await store.read(familyId: 'family-a'), isEmpty);
    final List<LocalEntryRecord> deleted = await store.read(
      familyId: 'family-a',
      includeDeleted: true,
    );
    expect(deleted.single.isDeleted, isTrue);
    expect(deleted.single.version, 2);
  });

  test('reads schema v1 data and upgrades on next write', () async {
    final Map<String, Object?> legacyRecord = <String, Object?>{
      'id': 'legacy',
      'familyId': 'Legacy Family',
      'type': 'memory',
      'title': 'Legacy memory',
      'note': '',
      'createdAt': '2026-08-01T10:00:00.000Z',
      'updatedAt': '2026-08-01T10:00:00.000Z',
      'deletedAt': null,
      'version': 1,
    };
    SharedPreferences.setMockInitialValues(<String, Object>{
      dataKey: jsonEncode(<String, Object?>{
        'schemaVersion': 1,
        'writtenAt': '2026-08-01T10:00:00.000Z',
        'records': <Object?>[legacyRecord],
      }),
    });

    final LocalEntryStore store = LocalEntryStore();
    final List<LocalEntryRecord> records = await store.read(familyId: 'Legacy Family');
    expect(records.single.id, 'legacy');
    expect(records.single.happensAt, isNull);

    await store.upsert(record(id: 'new', familyId: 'Legacy Family'));
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map<String, Object?> envelope =
        (jsonDecode(prefs.getString(dataKey)!) as Map<Object?, Object?>).cast<String, Object?>();
    expect(envelope['schemaVersion'], LocalEntryStore.schemaVersion);
  });

  test('falls back to backup when current envelope is corrupt', () async {
    final Map<String, Object?> validRecord = record(id: 'safe', familyId: 'family-a').toJson();
    SharedPreferences.setMockInitialValues(<String, Object>{
      dataKey: '{broken-json',
      backupKey: jsonEncode(<String, Object?>{
        'schemaVersion': 2,
        'writtenAt': '2026-08-13T10:00:00.000Z',
        'records': <Object?>[validRecord],
      }),
    });

    final List<LocalEntryRecord> restored =
        await LocalEntryStore().read(familyId: 'family-a');
    expect(restored.single.id, 'safe');
  });
}

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/data/local_entry_store.dart';

class LocalFamilyController extends ChangeNotifier {
  LocalFamilyController({required this.familyId, LocalEntryStore? store})
      : _store = store ?? LocalEntryStore();

  final String familyId;
  final LocalEntryStore _store;
  final Uuid _uuid = const Uuid();

  bool loading = true;
  String? errorCode;
  List<LocalEntryRecord> records = <LocalEntryRecord>[];

  List<LocalEntryRecord> get memories => _ofType('memory');
  List<LocalEntryRecord> get events => _ofType('event');
  List<LocalEntryRecord> get projects => _ofType('project');
  List<LocalEntryRecord> get traditions => _ofType('tradition');

  Future<void> initialize() async {
    loading = true;
    notifyListeners();
    try {
      records = await _store.read(familyId: familyId);
      if (records.isEmpty) await _seedDemo();
      errorCode = null;
    } catch (_) {
      errorCode = 'local_load_failed';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> create({
    required String type,
    required String title,
    required String note,
  }) async {
    final DateTime now = DateTime.now().toUtc();
    final LocalEntryRecord record = LocalEntryRecord(
      id: _uuid.v4(),
      familyId: familyId,
      type: type,
      title: title.trim(),
      note: note.trim(),
      createdAt: now,
      updatedAt: now,
    );
    await _store.upsert(record);
    await refresh();
  }

  Future<void> delete(String id) async {
    await _store.softDelete(id: id, familyId: familyId);
    await refresh();
  }

  Future<void> refresh() async {
    records = await _store.read(familyId: familyId);
    notifyListeners();
  }

  List<LocalEntryRecord> _ofType(String type) =>
      records.where((LocalEntryRecord item) => item.type == type).toList(growable: false);

  Future<void> _seedDemo() async {
    final DateTime now = DateTime.now().toUtc();
    final List<LocalEntryRecord> demo = <LocalEntryRecord>[
      _record('memory', 'Летняя прогулка', '8 фотографий и короткая заметка.', now.subtract(const Duration(hours: 3))),
      _record('memory', 'Семейный ужин', 'Спокойный вечер без телефонов.', now.subtract(const Duration(days: 1))),
      _record('event', 'Вечерняя прогулка', 'Сегодня в 19:30.', now.add(const Duration(hours: 2))),
      _record('project', 'Дом мечты', 'Следующий шаг: бюджет участка.', now.subtract(const Duration(days: 2))),
      _record('project', 'Семейная книга', 'Добавить историю родителей.', now.subtract(const Duration(days: 4))),
      _record('tradition', 'Воскресный завтрак', 'Один общий завтрак каждое воскресенье.', now.subtract(const Duration(days: 8))),
    ];
    for (final LocalEntryRecord item in demo) {
      await _store.upsert(item);
    }
    records = await _store.read(familyId: familyId);
  }

  LocalEntryRecord _record(String type, String title, String note, DateTime time) => LocalEntryRecord(
        id: _uuid.v4(),
        familyId: familyId,
        type: type,
        title: title,
        note: note,
        createdAt: time,
        updatedAt: time,
      );
}

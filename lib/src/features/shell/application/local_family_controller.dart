import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/data/local_entry_store.dart';
import '../../deep_local/application/deep_local_engine.dart';
import '../../deep_local/domain/deep_local_models.dart';

class LocalFamilyController extends ChangeNotifier {
  LocalFamilyController({
    required this.familyId,
    LocalEntryStore? store,
    DeepLocalEngine? engine,
  })  : _store = store ?? LocalEntryStore(),
        _engine = engine ?? const DeepLocalEngine();

  final String familyId;
  final LocalEntryStore _store;
  final DeepLocalEngine _engine;
  final Uuid _uuid = const Uuid();

  bool loading = true;
  bool writing = false;
  String? errorCode;
  List<LocalEntryRecord> records = <LocalEntryRecord>[];
  String query = '';
  String? selectedType;
  int? selectedYear;

  List<LocalEntryRecord> get memories => _ofType('memory');
  List<LocalEntryRecord> get events => _ofType('event');
  List<LocalEntryRecord> get projects => _ofType('project');
  List<LocalEntryRecord> get traditions => _ofType('tradition');
  List<LocalEntryRecord> get children => _ofType('child');
  List<LocalEntryRecord> get filteredRecords => _engine.search(
        records,
        query: query,
        type: selectedType,
        year: selectedYear,
      );
  List<LocalInsight> get insights => _engine.insights(records, DateTime.now());
  List<LocalEntryRecord> get onThisDay => _engine.onThisDay(records, DateTime.now());
  MemorySummary get seasonalSummary => _engine.seasonalSummary(records, DateTime.now());
  List<CalendarOccurrence> month(DateTime value) => _engine.monthOccurrences(records, value);

  Future<void> initialize() async {
    loading = true;
    errorCode = null;
    notifyListeners();
    try {
      records = await _store.read(familyId: familyId);
    } catch (_) {
      errorCode = 'local_load_failed';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<String?> create({
    required String type,
    required String title,
    required String note,
    DateTime? happensAt,
  }) async {
    if (writing) return 'write_in_progress';
    writing = true;
    errorCode = null;
    notifyListeners();
    try {
      final DateTime now = DateTime.now().toUtc();
      final LocalEntryRecord record = LocalEntryRecord(
        id: _uuid.v4(),
        familyId: familyId,
        type: type,
        title: title.trim(),
        note: note.trim(),
        createdAt: now,
        updatedAt: now,
        happensAt: happensAt?.toUtc(),
      );
      await _store.upsert(record);
      records = await _store.read(familyId: familyId);
      return null;
    } on LocalStoreException catch (error) {
      errorCode = error.code;
      return error.code;
    } catch (_) {
      errorCode = 'write_failed';
      return 'write_failed';
    } finally {
      writing = false;
      notifyListeners();
    }
  }

  Future<String?> delete(String id) async {
    if (writing) return 'write_in_progress';
    writing = true;
    errorCode = null;
    notifyListeners();
    try {
      await _store.softDelete(id: id, familyId: familyId);
      records = await _store.read(familyId: familyId);
      return null;
    } on LocalStoreException catch (error) {
      errorCode = error.code;
      return error.code;
    } catch (_) {
      errorCode = 'write_failed';
      return 'write_failed';
    } finally {
      writing = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    try {
      records = await _store.read(familyId: familyId);
      errorCode = null;
    } catch (_) {
      errorCode = 'local_load_failed';
    }
    notifyListeners();
  }

  void setSearch({
    String? value,
    String? type,
    int? year,
    bool clearType = false,
    bool clearYear = false,
  }) {
    if (value != null) query = value;
    if (clearType) {
      selectedType = null;
    } else if (type != null) {
      selectedType = type;
    }
    if (clearYear) {
      selectedYear = null;
    } else if (year != null) {
      selectedYear = year;
    }
    notifyListeners();
  }

  List<LocalEntryRecord> _ofType(String type) => records
      .where((LocalEntryRecord item) => item.type == type)
      .toList(growable: false);
}

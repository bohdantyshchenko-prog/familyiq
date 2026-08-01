import 'dart:convert';

import '../../../core/data/local_entry_store.dart';

class JournalChapter {
  const JournalChapter({required this.title, required this.period, required this.highlights, required this.openLoops});
  final String title;
  final String period;
  final List<String> highlights;
  final List<String> openLoops;
}

class FamilyJournalService {
  const FamilyJournalService();

  JournalChapter buildMonthly(List<LocalEntryRecord> records, DateTime month) {
    final List<LocalEntryRecord> selected = records.where((LocalEntryRecord item) {
      final DateTime date = item.createdAt.toLocal();
      return date.year == month.year && date.month == month.month && !item.isDeleted;
    }).toList(growable: false);
    final List<String> highlights = selected
        .where((LocalEntryRecord item) => item.type == 'memory' || item.type == 'event')
        .take(8)
        .map((LocalEntryRecord item) => item.title)
        .toList(growable: false);
    final List<String> openLoops = selected
        .where((LocalEntryRecord item) => item.type == 'project')
        .take(6)
        .map((LocalEntryRecord item) => item.title)
        .toList(growable: false);
    return JournalChapter(
      title: 'Семейный журнал',
      period: '${month.year}-${month.month.toString().padLeft(2, '0')}',
      highlights: highlights,
      openLoops: openLoops,
    );
  }
}

class PhotoMoment {
  const PhotoMoment({required this.id, required this.capturedAt, required this.localPath, this.personIds = const <String>[], this.place});
  final String id;
  final DateTime capturedAt;
  final String localPath;
  final List<String> personIds;
  final String? place;
}

class PhotoCollection {
  const PhotoCollection({required this.key, required this.title, required this.items});
  final String key;
  final String title;
  final List<PhotoMoment> items;
}

class LocalPhotoGroupingService {
  const LocalPhotoGroupingService();

  List<PhotoCollection> groupByMonth(List<PhotoMoment> moments) {
    final Map<String, List<PhotoMoment>> buckets = <String, List<PhotoMoment>>{};
    for (final PhotoMoment moment in moments) {
      final DateTime date = moment.capturedAt.toLocal();
      final String key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      buckets.putIfAbsent(key, () => <PhotoMoment>[]).add(moment);
    }
    final List<PhotoCollection> collections = buckets.entries
        .map((entry) => PhotoCollection(key: entry.key, title: entry.key, items: entry.value..sort((a, b) => a.capturedAt.compareTo(b.capturedAt))))
        .toList(growable: false)
      ..sort((a, b) => b.key.compareTo(a.key));
    return collections;
  }
}

class FamilyArchiveService {
  const FamilyArchiveService();

  String exportJson({required String familyId, required List<LocalEntryRecord> records}) {
    final List<LocalEntryRecord> familyRecords = records.where((item) => item.familyId == familyId).toList(growable: false);
    return const JsonEncoder.withIndent('  ').convert(<String, Object?>{
      'schemaVersion': 1,
      'familyId': familyId,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'records': familyRecords.map((item) => item.toJson()).toList(growable: false),
    });
  }
}

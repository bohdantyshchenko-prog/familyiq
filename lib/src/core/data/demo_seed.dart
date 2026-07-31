import 'local_entry_store.dart';

abstract final class DemoSeed {
  static List<LocalEntryRecord> build({required String familyId, DateTime? now}) {
    final DateTime anchor = (now ?? DateTime.now()).toUtc();
    LocalEntryRecord record({
      required String id,
      required String type,
      required String title,
      required String note,
      required Duration age,
    }) {
      final DateTime timestamp = anchor.subtract(age);
      return LocalEntryRecord(
        id: id,
        familyId: familyId,
        type: type,
        title: title,
        note: note,
        createdAt: timestamp,
        updatedAt: timestamp,
      );
    }

    return <LocalEntryRecord>[
      record(
        id: 'demo-memory-lake',
        type: 'memory',
        title: 'Первая поездка к озеру',
        note: 'Спокойный день, прогулка и восемь фотографий для семейной истории.',
        age: const Duration(days: 1),
      ),
      record(
        id: 'demo-event-evening',
        type: 'event',
        title: 'Семейный вечер',
        note: 'Ужин без телефонов и обсуждение планов на выходные.',
        age: const Duration(days: 2),
      ),
      record(
        id: 'demo-project-home',
        type: 'project',
        title: 'Дом мечты',
        note: 'Следующий шаг: определить реалистичный месячный бюджет накоплений.',
        age: const Duration(days: 4),
      ),
      record(
        id: 'demo-note-tradition',
        type: 'note',
        title: 'Новая семейная традиция',
        note: 'Раз в месяц выбирать одно место для совместной прогулки.',
        age: const Duration(days: 7),
      ),
    ];
  }
}

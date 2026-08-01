import '../../../core/data/local_entry_store.dart';
import '../domain/deep_local_models.dart';

class DeepLocalEngine {
  const DeepLocalEngine();

  List<LocalEntryRecord> search(
    List<LocalEntryRecord> records, {
    String query = '',
    String? type,
    int? year,
  }) {
    final String normalized = query.trim().toLowerCase();
    return records.where((LocalEntryRecord record) {
      if (type != null && record.type != type) return false;
      if (year != null && record.createdAt.toLocal().year != year) return false;
      if (normalized.isEmpty) return true;
      return record.title.toLowerCase().contains(normalized) ||
          record.note.toLowerCase().contains(normalized);
    }).toList(growable: false)
      ..sort((LocalEntryRecord a, LocalEntryRecord b) => b.updatedAt.compareTo(a.updatedAt));
  }

  List<LocalEntryRecord> onThisDay(List<LocalEntryRecord> records, DateTime now) {
    return records.where((LocalEntryRecord record) {
      final DateTime local = record.createdAt.toLocal();
      return record.type == 'memory' && local.month == now.month && local.day == now.day;
    }).toList(growable: false);
  }

  MemorySummary seasonalSummary(List<LocalEntryRecord> records, DateTime now) {
    final int seasonStartMonth = switch (now.month) {
      12 || 1 || 2 => 12,
      3 || 4 || 5 => 3,
      6 || 7 || 8 => 6,
      _ => 9,
    };
    final int startYear = seasonStartMonth == 12 && now.month < 3 ? now.year - 1 : now.year;
    final DateTime start = DateTime(startYear, seasonStartMonth);
    final List<LocalEntryRecord> period = records
        .where((LocalEntryRecord item) => !item.createdAt.toLocal().isBefore(start))
        .toList(growable: false);
    final List<String> highlights = period
        .where((LocalEntryRecord item) => item.type == 'memory' || item.type == 'event')
        .take(5)
        .map((LocalEntryRecord item) => item.title)
        .toList(growable: false);
    final List<String> unfinished = period
        .where((LocalEntryRecord item) => item.type == 'project')
        .take(5)
        .map((LocalEntryRecord item) => item.title)
        .toList(growable: false);
    return MemorySummary(
      periodLabel: _seasonLabel(now.month),
      highlights: highlights,
      unfinished: unfinished,
      nextSuggestions: <String>[
        if (highlights.isEmpty) 'Сохранить хотя бы один общий момент',
        if (unfinished.isNotEmpty) 'Выбрать один проект и определить следующий шаг',
        if (period.where((LocalEntryRecord item) => item.type == 'event').length < 2)
          'Запланировать одно семейное событие',
      ],
    );
  }

  List<LocalInsight> insights(List<LocalEntryRecord> records, DateTime now) {
    final DateTime sevenDaysAgo = now.subtract(const Duration(days: 7));
    final int recentEvents = records
        .where((LocalEntryRecord item) =>
            item.type == 'event' && item.createdAt.toLocal().isAfter(sevenDaysAgo))
        .length;
    final int staleProjects = records
        .where((LocalEntryRecord item) =>
            item.type == 'project' && item.updatedAt.toLocal().isBefore(now.subtract(const Duration(days: 14))))
        .length;
    final int recentMemories = records
        .where((LocalEntryRecord item) =>
            item.type == 'memory' && item.createdAt.toLocal().isAfter(sevenDaysAgo))
        .length;

    return <LocalInsight>[
      if (recentEvents == 0)
        const LocalInsight(
          title: 'Добавьте совместное событие',
          reason: 'За последние семь дней нет общих событий.',
          action: 'Запланировать прогулку или семейный вечер.',
        ),
      if (staleProjects > 0)
        LocalInsight(
          title: 'Вернитесь к семейному проекту',
          reason: '$staleProjects проектов не обновлялись больше двух недель.',
          action: 'Определить один небольшой следующий шаг.',
        ),
      if (recentMemories == 0)
        const LocalInsight(
          title: 'Сохраните момент недели',
          reason: 'За последнюю неделю не добавлено воспоминаний.',
          action: 'Добавить фото, заметку или короткую историю.',
        ),
    ];
  }

  List<CalendarOccurrence> monthOccurrences(List<LocalEntryRecord> records, DateTime month) {
    return records
        .where((LocalEntryRecord item) => item.type == 'event')
        .where((LocalEntryRecord item) {
          final DateTime date = item.createdAt.toLocal();
          return date.year == month.year && date.month == month.month;
        })
        .map((LocalEntryRecord item) => CalendarOccurrence(
              id: item.id,
              title: item.title,
              startsAt: item.createdAt.toLocal(),
            ))
        .toList(growable: false)
      ..sort((CalendarOccurrence a, CalendarOccurrence b) => a.startsAt.compareTo(b.startsAt));
  }

  String _seasonLabel(int month) => switch (month) {
        12 || 1 || 2 => 'Зима',
        3 || 4 || 5 => 'Весна',
        6 || 7 || 8 => 'Лето',
        _ => 'Осень',
      };
}

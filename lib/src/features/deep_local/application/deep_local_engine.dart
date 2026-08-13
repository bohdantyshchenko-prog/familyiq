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
      if (year != null && record.effectiveDate.year != year) return false;
      if (normalized.isEmpty) return true;
      return record.title.toLowerCase().contains(normalized) ||
          record.note.toLowerCase().contains(normalized);
    }).toList(growable: false)
      ..sort((LocalEntryRecord a, LocalEntryRecord b) => b.updatedAt.compareTo(a.updatedAt));
  }

  List<LocalEntryRecord> onThisDay(List<LocalEntryRecord> records, DateTime now) {
    final DateTime localNow = now.toLocal();
    return records.where((LocalEntryRecord record) {
      final DateTime local = record.effectiveDate;
      return record.type == 'memory' &&
          local.year < localNow.year &&
          local.month == localNow.month &&
          local.day == localNow.day;
    }).toList(growable: false)
      ..sort((LocalEntryRecord a, LocalEntryRecord b) => b.effectiveDate.compareTo(a.effectiveDate));
  }

  MemorySummary seasonalSummary(List<LocalEntryRecord> records, DateTime now) {
    final DateTime localNow = now.toLocal();
    final int seasonStartMonth = switch (localNow.month) {
      12 || 1 || 2 => 12,
      3 || 4 || 5 => 3,
      6 || 7 || 8 => 6,
      _ => 9,
    };
    final int startYear = seasonStartMonth == 12 && localNow.month < 3
        ? localNow.year - 1
        : localNow.year;
    final DateTime start = DateTime(startYear, seasonStartMonth);
    final List<LocalEntryRecord> period = records
        .where((LocalEntryRecord item) => !item.effectiveDate.isBefore(start))
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
      periodLabel: _seasonLabel(localNow.month),
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
    final DateTime localNow = now.toLocal();
    final DateTime sevenDaysAgo = localNow.subtract(const Duration(days: 7));
    final DateTime nextSevenDays = localNow.add(const Duration(days: 7));
    final int upcomingEvents = records
        .where((LocalEntryRecord item) => item.type == 'event')
        .where((LocalEntryRecord item) {
          final DateTime date = item.effectiveDate;
          return !date.isBefore(localNow) && !date.isAfter(nextSevenDays);
        })
        .length;
    final int staleProjects = records
        .where((LocalEntryRecord item) =>
            item.type == 'project' &&
            item.updatedAt.toLocal().isBefore(localNow.subtract(const Duration(days: 14))))
        .length;
    final int recentMemories = records
        .where((LocalEntryRecord item) =>
            item.type == 'memory' && item.effectiveDate.isAfter(sevenDaysAgo))
        .length;

    return <LocalInsight>[
      if (upcomingEvents == 0)
        const LocalInsight(
          title: 'Добавьте совместное событие',
          reason: 'На ближайшие семь дней нет семейных событий.',
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
          action: 'Добавить короткую заметку о важном моменте.',
        ),
    ];
  }

  List<CalendarOccurrence> monthOccurrences(List<LocalEntryRecord> records, DateTime month) {
    return records
        .where((LocalEntryRecord item) => item.type == 'event')
        .where((LocalEntryRecord item) {
          final DateTime date = item.effectiveDate;
          return date.year == month.year && date.month == month.month;
        })
        .map(
          (LocalEntryRecord item) => CalendarOccurrence(
            id: item.id,
            title: item.title,
            startsAt: item.effectiveDate,
          ),
        )
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

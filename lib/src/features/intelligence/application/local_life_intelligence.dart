import '../../shell/application/local_family_controller.dart';

class LifeInsight {
  const LifeInsight({required this.title, required this.reason, required this.action, required this.priority});
  final String title;
  final String reason;
  final String action;
  final int priority;
}

class LocalLifeIntelligence {
  const LocalLifeIntelligence();

  List<LifeInsight> build(LocalFamilyController controller, {DateTime? now}) {
    final DateTime point = (now ?? DateTime.now()).toUtc();
    final List<LifeInsight> insights = <LifeInsight>[];
    final bool hasRecentMemory = controller.memories.any(
      (item) => point.difference(item.createdAt.toUtc()).inDays <= 7,
    );
    final bool hasUpcomingEvent = controller.events.any(
      (item) => item.createdAt.toUtc().isAfter(point) && item.createdAt.toUtc().isBefore(point.add(const Duration(days: 7))),
    );
    final bool staleProject = controller.projects.any(
      (item) => point.difference(item.updatedAt.toUtc()).inDays >= 14,
    );

    if (!hasRecentMemory) {
      insights.add(const LifeInsight(
        title: 'Сохраните один момент недели',
        reason: 'За последние семь дней нет новых воспоминаний.',
        action: 'Добавить короткую заметку или фотографию.',
        priority: 90,
      ));
    }
    if (!hasUpcomingEvent) {
      insights.add(const LifeInsight(
        title: 'Запланируйте общее время',
        reason: 'На ближайшие семь дней нет семейных событий.',
        action: 'Добавить прогулку, ужин или семейный звонок.',
        priority: 80,
      ));
    }
    if (staleProject) {
      insights.add(const LifeInsight(
        title: 'Вернитесь к отложенному проекту',
        reason: 'Один из семейных проектов не обновлялся две недели.',
        action: 'Выбрать один следующий шаг до 20 минут.',
        priority: 70,
      ));
    }
    if (insights.isEmpty) {
      insights.add(const LifeInsight(
        title: 'Семейный ритм выглядит устойчиво',
        reason: 'Есть свежие воспоминания, планы и активные проекты.',
        action: 'Сохранить лучший момент сегодняшнего дня.',
        priority: 40,
      ));
    }
    insights.sort((LifeInsight a, LifeInsight b) => b.priority.compareTo(a.priority));
    return insights;
  }
}

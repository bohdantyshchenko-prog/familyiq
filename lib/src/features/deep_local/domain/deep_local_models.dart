import 'dart:convert';

enum ProjectStageStatus { planned, active, blocked, done }

class ProjectStage {
  const ProjectStage({
    required this.id,
    required this.title,
    required this.status,
    this.owner,
    this.dueAt,
    this.budget,
  });

  final String id;
  final String title;
  final ProjectStageStatus status;
  final String? owner;
  final DateTime? dueAt;
  final double? budget;

  bool get completed => status == ProjectStageStatus.done;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'title': title,
        'status': status.name,
        'owner': owner,
        'dueAt': dueAt?.toUtc().toIso8601String(),
        'budget': budget,
      };
}

class FamilyProjectPlan {
  const FamilyProjectPlan({
    required this.id,
    required this.title,
    required this.stages,
    this.description = '',
  });

  final String id;
  final String title;
  final String description;
  final List<ProjectStage> stages;

  double get progress => stages.isEmpty
      ? 0
      : stages.where((ProjectStage stage) => stage.completed).length / stages.length;

  double get budget => stages.fold<double>(0, (double sum, ProjectStage stage) => sum + (stage.budget ?? 0));
}

class CalendarOccurrence {
  const CalendarOccurrence({
    required this.id,
    required this.title,
    required this.startsAt,
    this.endsAt,
    this.personId,
    this.recurrence,
    this.category = 'family',
  });

  final String id;
  final String title;
  final DateTime startsAt;
  final DateTime? endsAt;
  final String? personId;
  final String? recurrence;
  final String category;
}

class ChildProfile {
  const ChildProfile({
    required this.id,
    required this.displayName,
    required this.birthDate,
    this.heightCm,
    this.weightKg,
    this.notes = const <String>[],
  });

  final String id;
  final String displayName;
  final DateTime birthDate;
  final double? heightCm;
  final double? weightKg;
  final List<String> notes;

  int ageInMonths(DateTime now) {
    int months = (now.year - birthDate.year) * 12 + now.month - birthDate.month;
    if (now.day < birthDate.day) months--;
    return months < 0 ? 0 : months;
  }
}

class MemorySummary {
  const MemorySummary({
    required this.periodLabel,
    required this.highlights,
    required this.unfinished,
    required this.nextSuggestions,
  });

  final String periodLabel;
  final List<String> highlights;
  final List<String> unfinished;
  final List<String> nextSuggestions;

  String toPrettyJson() => const JsonEncoder.withIndent('  ').convert(<String, Object?>{
        'period': periodLabel,
        'highlights': highlights,
        'unfinished': unfinished,
        'nextSuggestions': nextSuggestions,
      });
}

class LocalInsight {
  const LocalInsight({required this.title, required this.reason, required this.action});

  final String title;
  final String reason;
  final String action;
}

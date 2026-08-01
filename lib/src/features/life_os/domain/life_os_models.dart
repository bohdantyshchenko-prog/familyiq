enum FamilyRole { owner, adult, child, relative }

enum PrivacyLevel { private, guardians, family, selected }

class FamilyPerson {
  const FamilyPerson({
    required this.id,
    required this.displayName,
    required this.role,
    required this.privacy,
    this.birthDate,
  });

  final String id;
  final String displayName;
  final FamilyRole role;
  final PrivacyLevel privacy;
  final DateTime? birthDate;
}

class ChildProfile {
  const ChildProfile({
    required this.personId,
    required this.guardianIds,
    this.heightCm,
    this.weightKg,
    this.parentalConsentForSensitiveInsights = false,
  });

  final String personId;
  final List<String> guardianIds;
  final double? heightCm;
  final double? weightKg;
  final bool parentalConsentForSensitiveInsights;

  bool get canAnalyzeSensitiveData => guardianIds.isNotEmpty && parentalConsentForSensitiveInsights;
}

class ProjectStage {
  const ProjectStage({required this.id, required this.title, required this.completed, this.deadline});
  final String id;
  final String title;
  final bool completed;
  final DateTime? deadline;
}

class LifeProject {
  const LifeProject({
    required this.id,
    required this.title,
    required this.ownerIds,
    required this.stages,
    this.budgetMinor,
    this.currency = 'UAH',
  });

  final String id;
  final String title;
  final List<String> ownerIds;
  final List<ProjectStage> stages;
  final int? budgetMinor;
  final String currency;

  double get progress => stages.isEmpty ? 0 : stages.where((ProjectStage stage) => stage.completed).length / stages.length;
}

class FamilyCalendarEntry {
  const FamilyCalendarEntry({
    required this.id,
    required this.title,
    required this.startsAt,
    required this.memberIds,
    this.endsAt,
    this.recurrenceRule,
    this.category = 'family',
  });

  final String id;
  final String title;
  final DateTime startsAt;
  final DateTime? endsAt;
  final List<String> memberIds;
  final String? recurrenceRule;
  final String category;
}

class FinanceGoal {
  const FinanceGoal({
    required this.id,
    required this.title,
    required this.targetMinor,
    required this.savedMinor,
    this.currency = 'UAH',
  });

  final String id;
  final String title;
  final int targetMinor;
  final int savedMinor;
  final String currency;

  double get progress => targetMinor <= 0 ? 0 : (savedMinor / targetMinor).clamp(0, 1);
}

class FamilyGraphEdge {
  const FamilyGraphEdge({required this.fromId, required this.toId, required this.relationship});
  final String fromId;
  final String toId;
  final String relationship;
}

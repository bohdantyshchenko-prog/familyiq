enum FamilyRole { owner, adult, child, relative }

enum MemoryType { photo, video, voice, story, milestone }

class FamilyMember {
  const FamilyMember({
    required this.id,
    required this.name,
    required this.role,
    this.relationship,
  });

  final String id;
  final String name;
  final FamilyRole role;
  final String? relationship;
}

class FamilyMemory {
  const FamilyMemory({
    required this.id,
    required this.title,
    required this.occurredAt,
    required this.type,
    required this.memberIds,
    this.summary,
    this.place,
  });

  final String id;
  final String title;
  final DateTime occurredAt;
  final MemoryType type;
  final List<String> memberIds;
  final String? summary;
  final String? place;
}

class LifeProject {
  const LifeProject({
    required this.id,
    required this.title,
    required this.progress,
    required this.nextAction,
  });

  final String id;
  final String title;
  final double progress;
  final String nextAction;
}

class FamilyGraphEdge {
  const FamilyGraphEdge({
    required this.fromId,
    required this.toId,
    required this.label,
  });

  final String fromId;
  final String toId;
  final String label;
}

enum FamilyRole { owner, adult, child, relative }

enum ChildDataKind { profile, growth, school, health, photo, note, mood }

class ChildPrivacyPolicy {
  const ChildPrivacyPolicy();

  bool canRead({required FamilyRole role, required ChildDataKind kind}) {
    return switch (role) {
      FamilyRole.owner => true,
      FamilyRole.adult => kind != ChildDataKind.health && kind != ChildDataKind.mood,
      FamilyRole.child => kind == ChildDataKind.profile || kind == ChildDataKind.school,
      FamilyRole.relative => kind == ChildDataKind.profile || kind == ChildDataKind.photo,
    };
  }

  bool canWrite({required FamilyRole role, required ChildDataKind kind}) {
    if (role == FamilyRole.owner) return true;
    if (role == FamilyRole.adult) {
      return kind == ChildDataKind.growth ||
          kind == ChildDataKind.school ||
          kind == ChildDataKind.photo ||
          kind == ChildDataKind.note;
    }
    return false;
  }

  bool requiresExplicitConsent(ChildDataKind kind) =>
      kind == ChildDataKind.health || kind == ChildDataKind.mood;

  bool canUseForAutomatedInsight(ChildDataKind kind, {required bool parentalConsent}) {
    if (kind == ChildDataKind.mood || kind == ChildDataKind.health) return parentalConsent;
    return kind != ChildDataKind.photo;
  }
}

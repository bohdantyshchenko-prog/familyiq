import 'package:flutter_test/flutter_test.dart';
import 'package:familyiq/src/features/life_os/domain/life_os_models.dart';
import 'package:familyiq/src/features/storytelling/application/storytelling_services.dart';

void main() {
  test('project progress is derived from completed stages', () {
    final LifeProject project = LifeProject(
      id: 'p1',
      title: 'Дом',
      ownerIds: const <String>['u1'],
      stages: const <ProjectStage>[
        ProjectStage(id: 's1', title: 'Бюджет', completed: true),
        ProjectStage(id: 's2', title: 'Участок', completed: false),
      ],
    );
    expect(project.progress, .5);
  });

  test('child sensitive analysis requires guardian and consent', () {
    const ChildProfile blocked = ChildProfile(personId: 'c1', guardianIds: <String>[]);
    const ChildProfile allowed = ChildProfile(
      personId: 'c1',
      guardianIds: <String>['p1'],
      parentalConsentForSensitiveInsights: true,
    );
    expect(blocked.canAnalyzeSensitiveData, isFalse);
    expect(allowed.canAnalyzeSensitiveData, isTrue);
  });

  test('finance progress is bounded', () {
    const FinanceGoal goal = FinanceGoal(id: 'f1', title: 'Отпуск', targetMinor: 100, savedMinor: 140);
    expect(goal.progress, 1);
  });

  test('photo moments group by month newest first', () {
    const LocalPhotoGroupingService service = LocalPhotoGroupingService();
    final List<PhotoCollection> result = service.groupByMonth(<PhotoMoment>[
      PhotoMoment(id: '1', capturedAt: DateTime(2026, 7, 1), localPath: '/a.jpg'),
      PhotoMoment(id: '2', capturedAt: DateTime(2026, 8, 1), localPath: '/b.jpg'),
    ]);
    expect(result.map((item) => item.key), <String>['2026-08', '2026-07']);
  });
}

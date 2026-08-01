import 'package:flutter_test/flutter_test.dart';
import 'package:familyiq/src/core/data/local_entry_store.dart';
import 'package:familyiq/src/features/deep_local/application/deep_local_engine.dart';

void main() {
  const DeepLocalEngine engine = DeepLocalEngine();
  final DateTime now = DateTime(2026, 8, 1, 12);

  LocalEntryRecord record(String id, String type, String title, DateTime date) => LocalEntryRecord(
        id: id,
        familyId: 'family',
        type: type,
        title: title,
        note: 'note $title',
        createdAt: date.toUtc(),
        updatedAt: date.toUtc(),
      );

  test('search filters by query type and year', () {
    final List<LocalEntryRecord> values = <LocalEntryRecord>[
      record('1', 'memory', 'Карпаты', DateTime(2026, 5, 1)),
      record('2', 'project', 'Дом', DateTime(2025, 5, 1)),
    ];
    final result = engine.search(values, query: 'карп', type: 'memory', year: 2026);
    expect(result.single.id, '1');
  });

  test('on this day only returns matching memories', () {
    final values = <LocalEntryRecord>[
      record('1', 'memory', 'Лето', DateTime(2025, 8, 1)),
      record('2', 'event', 'Событие', DateTime(2025, 8, 1)),
      record('3', 'memory', 'Другой день', DateTime(2025, 8, 2)),
    ];
    expect(engine.onThisDay(values, now).map((e) => e.id), <String>['1']);
  });

  test('offline insights explain missing weekly activity', () {
    final insights = engine.insights(<LocalEntryRecord>[], now);
    expect(insights, isNotEmpty);
    expect(insights.every((item) => item.reason.isNotEmpty), isTrue);
    expect(insights.every((item) => item.action.isNotEmpty), isTrue);
  });

  test('season summary separates highlights and unfinished projects', () {
    final values = <LocalEntryRecord>[
      record('1', 'memory', 'Озеро', DateTime(2026, 7, 10)),
      record('2', 'project', 'Дом', DateTime(2026, 7, 11)),
    ];
    final summary = engine.seasonalSummary(values, now);
    expect(summary.periodLabel, 'Лето');
    expect(summary.highlights, contains('Озеро'));
    expect(summary.unfinished, contains('Дом'));
  });
}

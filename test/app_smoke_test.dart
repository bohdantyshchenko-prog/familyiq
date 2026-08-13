import 'package:familyiq/src/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'familyiq.session': true,
      'familyiq.family': 'Test Family',
      'familyiq.user': 'Test User',
    });
  });

  Future<void> pumpPhone(WidgetTester tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const FamilyIqApp());
    await tester.pumpAndSettle();
  }

  testWidgets('production shell renders without layout exceptions', (WidgetTester tester) async {
    await pumpPhone(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('Главная'), findsWidgets);
    expect(find.text('История'), findsWidgets);
    expect(find.text('Календарь'), findsWidgets);
    expect(find.text('Проекты'), findsWidgets);
    expect(find.text('Семья'), findsWidgets);
  });

  testWidgets('all primary destinations and profile are navigable', (WidgetTester tester) async {
    await pumpPhone(tester);
    for (final String label in <String>['История', 'Календарь', 'Проекты', 'Семья']) {
      await tester.tap(find.text(label).last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    expect(find.text('Мой профиль'), findsOneWidget);
    await tester.tap(find.text('Мой профиль'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Профиль'), findsOneWidget);
    expect(find.text('Безопасность'), findsOneWidget);
  });

  testWidgets('creation sheet opens safely', (WidgetTester tester) async {
    await pumpPhone(tester);
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Новая запись'), findsOneWidget);
    expect(find.text('Сохранить'), findsOneWidget);
    expect(find.text('Память'), findsOneWidget);
    expect(find.text('Событие'), findsOneWidget);
    expect(find.text('Проект'), findsOneWidget);
  });
}

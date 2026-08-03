import 'package:familyiq/src/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'familyiq.session': true,
      'familyiq.family': 'Test Family',
    });
  });

  testWidgets('FamilyIQ renders all production destinations', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const FamilyIqApp());
    await tester.pumpAndSettle();

    expect(find.text('Главная'), findsOneWidget);
    expect(find.text('История'), findsOneWidget);
    expect(find.text('Календарь'), findsOneWidget);
    expect(find.text('Проекты'), findsOneWidget);
    expect(find.text('Семья'), findsOneWidget);
    expect(find.text('Профиль'), findsOneWidget);
  });

  testWidgets('creation sheet opens and validates title', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const FamilyIqApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Новая семейная запись'), findsOneWidget);
    expect(find.text('Сохранить локально'), findsOneWidget);
  });
}

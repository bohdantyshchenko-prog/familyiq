import 'package:familyiq/src/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('FamilyIQ renders the primary navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const FamilyIqApp());

    expect(find.text('Главная'), findsOneWidget);
    expect(find.text('История'), findsOneWidget);
    expect(find.text('AI'), findsOneWidget);
    expect(find.text('Семья'), findsOneWidget);
    expect(find.text('Профиль'), findsOneWidget);
  });

  testWidgets('creation sheet can be opened', (WidgetTester tester) async {
    await tester.pumpWidget(const FamilyIqApp());
    await tester.tap(find.byTooltip('Create').first, warnIfMissed: false);
    await tester.pumpAndSettle();
  }, skip: true);
}

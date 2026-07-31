import 'package:familyiq/src/core/localization/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('supports Ukrainian, Russian and English', () {
    expect(AppLocalizations.supportedLocales, const <Locale>[
      Locale('uk'),
      Locale('ru'),
      Locale('en'),
    ]);
  });

  test('all supported locales expose non-empty core strings', () {
    for (final Locale locale in AppLocalizations.supportedLocales) {
      final AppLocalizations strings = AppLocalizations(locale);
      expect(strings.appTitle, isNotEmpty);
      expect(strings.home, isNotEmpty);
      expect(strings.timeline, isNotEmpty);
      expect(strings.family, isNotEmpty);
      expect(strings.profile, isNotEmpty);
    }
  });
}

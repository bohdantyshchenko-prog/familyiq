import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = <Locale>[
    Locale('uk'),
    Locale('ru'),
    Locale('en'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const Map<String, Map<String, String>> _values = {
    'uk': {
      'appTitle': 'FamilyIQ',
      'home': 'Головна',
      'timeline': 'Історія',
      'ai': 'AI',
      'family': 'Сімʼя',
      'profile': 'Профіль',
      'createSpace': 'Створити простір',
      'privacyFirst': 'Приватність за замовчуванням',
    },
    'ru': {
      'appTitle': 'FamilyIQ',
      'home': 'Главная',
      'timeline': 'История',
      'ai': 'AI',
      'family': 'Семья',
      'profile': 'Профиль',
      'createSpace': 'Создать пространство',
      'privacyFirst': 'Приватность по умолчанию',
    },
    'en': {
      'appTitle': 'FamilyIQ',
      'home': 'Home',
      'timeline': 'Timeline',
      'ai': 'AI',
      'family': 'Family',
      'profile': 'Profile',
      'createSpace': 'Create space',
      'privacyFirst': 'Privacy by default',
    },
  };

  String _text(String key) => _values[locale.languageCode]?[key] ?? _values['en']![key]!;

  String get appTitle => _text('appTitle');
  String get home => _text('home');
  String get timeline => _text('timeline');
  String get ai => _text('ai');
  String get family => _text('family');
  String get profile => _text('profile');
  String get createSpace => _text('createSpace');
  String get privacyFirst => _text('privacyFirst');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.any((item) => item.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => SynchronousFuture(AppLocalizations(locale));

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  static const String _key = 'familyiq.locale';

  Locale? _locale;

  Locale? get locale => _locale;

  Future<void> initialize() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? code = preferences.getString(_key);
    if (code != null && code.isNotEmpty) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    if (locale == null) {
      await preferences.remove(_key);
    } else {
      await preferences.setString(_key, locale.languageCode);
    }
    notifyListeners();
  }
}

class LocaleScope extends InheritedNotifier<LocaleController> {
  const LocaleScope({required LocaleController controller, required super.child, super.key}) : super(notifier: controller);

  static LocaleController of(BuildContext context) {
    final LocaleScope? scope = context.dependOnInheritedWidgetOfExactType<LocaleScope>();
    assert(scope != null, 'LocaleScope is missing above this context');
    return scope!.notifier!;
  }
}

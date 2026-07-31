import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const String _key = 'familyiq.theme_mode';

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  Future<void> initialize() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    _mode = switch (preferences.getString(_key)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    notifyListeners();
  }

  Future<void> setMode(ThemeMode value) async {
    if (_mode == value) return;
    _mode = value;
    notifyListeners();
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(_key, value.name);
  }
}

class ThemeScope extends InheritedNotifier<ThemeController> {
  const ThemeScope({required ThemeController controller, required super.child, super.key})
      : super(notifier: controller);

  static ThemeController of(BuildContext context) {
    final ThemeScope? scope = context.dependOnInheritedWidgetOfExactType<ThemeScope>();
    assert(scope != null, 'ThemeScope is missing');
    return scope!.notifier!;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/localization/app_localizations.dart';
import 'core/localization/locale_controller.dart';
import 'core/theme/family_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/presentation/auth_gate.dart';

class FamilyIqApp extends StatefulWidget {
  const FamilyIqApp({super.key});

  @override
  State<FamilyIqApp> createState() => _FamilyIqAppState();
}

class _FamilyIqAppState extends State<FamilyIqApp> {
  final ThemeController themeController = ThemeController();
  final LocaleController localeController = LocaleController();

  @override
  void initState() {
    super.initState();
    themeController.initialize();
    localeController.initialize();
  }

  @override
  void dispose() {
    themeController.dispose();
    localeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeScope(
      controller: themeController,
      child: LocaleScope(
        controller: localeController,
        child: ListenableBuilder(
          listenable: Listenable.merge(<Listenable>[themeController, localeController]),
          builder: (BuildContext context, Widget? child) => MaterialApp(
            debugShowCheckedModeBanner: false,
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            theme: FamilyTheme.light,
            darkTheme: FamilyTheme.dark,
            themeMode: themeController.mode,
            locale: localeController.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localeListResolutionCallback: (locales, supportedLocales) {
              for (final Locale locale in locales ?? const <Locale>[]) {
                for (final Locale supported in supportedLocales) {
                  if (locale.languageCode == supported.languageCode) return supported;
                }
              }
              return const Locale('uk');
            },
            localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) => MediaQuery.withClampedTextScaling(
              minScaleFactor: 0.9,
              maxScaleFactor: 1.6,
              child: child ?? const SizedBox.shrink(),
            ),
            home: const AuthGate(),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'core/theme/family_theme.dart';
import 'features/shell/presentation/family_shell.dart';

class FamilyIqApp extends StatelessWidget {
  const FamilyIqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FamilyIQ',
      theme: FamilyTheme.light,
      darkTheme: FamilyTheme.dark,
      themeMode: ThemeMode.system,
      home: const FamilyShell(),
    );
  }
}

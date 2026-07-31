import 'package:flutter/material.dart';

abstract final class FamilyTheme {
  static const Color seed = Color(0xFF6F51E8);
  static const Color warmCanvas = Color(0xFFFAF7F2);
  static const Color warmSurface = Color(0xFFFFFCF8);

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final bool isLight = brightness == Brightness.light;
    final ColorScheme generated = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );
    final ColorScheme colors = generated.copyWith(
      surface: isLight ? warmSurface : const Color(0xFF15121B),
      surfaceContainerLowest: isLight ? Colors.white : const Color(0xFF100D15),
      surfaceContainerLow: isLight ? const Color(0xFFF7F1EB) : const Color(0xFF1A1621),
      outlineVariant: isLight ? const Color(0xFFE4DCD4) : const Color(0xFF3B3445),
    );

    final BorderRadius cardRadius = BorderRadius.circular(26);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colors,
      scaffoldBackgroundColor: isLight ? warmCanvas : const Color(0xFF0D0B12),
      canvasColor: isLight ? warmCanvas : const Color(0xFF0D0B12),
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      textTheme: ThemeData(brightness: brightness).textTheme.apply(
            bodyColor: colors.onSurface,
            displayColor: colors.onSurface,
          ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colors.onSurface,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: colors.surface,
        shadowColor: isLight ? const Color(0x140D0718) : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: cardRadius,
          side: BorderSide(color: colors.outlineVariant.withValues(alpha: isLight ? .85 : .65)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colors.primary, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 78,
        elevation: 0,
        backgroundColor: colors.surface.withValues(alpha: .96),
        surfaceTintColor: Colors.transparent,
        indicatorColor: colors.primaryContainer,
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
              fontSize: 11,
              fontWeight: states.contains(WidgetState.selected) ? FontWeight.w800 : FontWeight.w600,
            )),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      ),
      dividerTheme: DividerThemeData(color: colors.outlineVariant, thickness: 1),
    );
  }
}

import 'package:flutter/material.dart';

final ValueNotifier<ThemeMode> modoTemaNotifier = ValueNotifier(ThemeMode.light);

class AppTemas {
  static const Color colorPrimario = Colors.deepOrange;

  // TEMA CLARO
  static final ThemeData temaClaro = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: colorPrimario,
      brightness: Brightness.light,
      primary: colorPrimario,
      secondary: Colors.blue.shade700,
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    appBarTheme: const AppBarTheme(
      backgroundColor: colorPrimario,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  // TEMA OSCURO
  static final ThemeData temaOscuro = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: colorPrimario,
      brightness: Brightness.dark,
      primary: Colors.deepOrangeAccent,
      secondary: Colors.blueAccent,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1F1F1F),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
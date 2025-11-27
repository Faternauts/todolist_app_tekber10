import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  int _themeIndex = 0;

  ThemeMode get themeMode => _themeMode;
  int get themeIndex => _themeIndex;

  // Available themes
  final List<ThemeData> lightThemes = [
    // Default Light Theme
    ThemeData(
      useMaterial3: true,
      fontFamily: 'SFProDisplay',
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'SFProDisplay'),
        displayMedium: TextStyle(fontFamily: 'SFProDisplay'),
        displaySmall: TextStyle(fontFamily: 'SFProDisplay'),
        headlineLarge: TextStyle(fontFamily: 'SFProDisplay'),
        headlineMedium: TextStyle(fontFamily: 'SFProDisplay'),
        headlineSmall: TextStyle(fontFamily: 'SFProDisplay'),
        titleLarge: TextStyle(fontFamily: 'SFProDisplay'),
        titleMedium: TextStyle(fontFamily: 'SFProDisplay'),
        titleSmall: TextStyle(fontFamily: 'SFProDisplay'),
        bodyLarge: TextStyle(fontFamily: 'SFProDisplay'),
        bodyMedium: TextStyle(fontFamily: 'SFProDisplay'),
        bodySmall: TextStyle(fontFamily: 'SFProDisplay'),
        labelLarge: TextStyle(fontFamily: 'SFProDisplay'),
        labelMedium: TextStyle(fontFamily: 'SFProDisplay'),
        labelSmall: TextStyle(fontFamily: 'SFProDisplay'),
      ),
    ),
    // Purple Theme
    ThemeData(
      useMaterial3: true,
      fontFamily: 'SFProDisplay',
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.purple,
        brightness: Brightness.light,
      ),
    ),
    // Green Theme
    ThemeData(
      useMaterial3: true,
      fontFamily: 'SFProDisplay',
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.green,
        brightness: Brightness.light,
      ),
    ),
    // Orange Theme
    ThemeData(
      useMaterial3: true,
      fontFamily: 'SFProDisplay',
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.orange,
        brightness: Brightness.light,
      ),
    ),
  ];

  final List<ThemeData> darkThemes = [
    // Default Dark Theme
    ThemeData(
      useMaterial3: true,
      fontFamily: 'SFProDisplay',
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
    ),
    // Purple Dark Theme
    ThemeData(
      useMaterial3: true,
      fontFamily: 'SFProDisplay',
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.purple,
        brightness: Brightness.dark,
      ),
    ),
    // Green Dark Theme
    ThemeData(
      useMaterial3: true,
      fontFamily: 'SFProDisplay',
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.green,
        brightness: Brightness.dark,
      ),
    ),
    // Orange Dark Theme
    ThemeData(
      useMaterial3: true,
      fontFamily: 'SFProDisplay',
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.orange,
        brightness: Brightness.dark,
      ),
    ),
  ];

  final List<String> themeNames = ['Blue', 'Purple', 'Green', 'Orange'];

  ThemeData get lightTheme => lightThemes[_themeIndex];
  ThemeData get darkTheme => darkThemes[_themeIndex];

  // Change theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _saveTheme();
    notifyListeners();
  }

  // Change theme color
  Future<void> setThemeIndex(int index) async {
    _themeIndex = index;
    await _saveTheme();
    notifyListeners();
  }

  // Save theme to SharedPreferences
  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', _themeMode.index);
    await prefs.setInt('themeIndex', _themeIndex);
  }

  // Load theme from SharedPreferences
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt('themeMode') ?? 0;
    final themeColorIndex = prefs.getInt('themeIndex') ?? 0;

    _themeMode = ThemeMode.values[themeModeIndex];
    _themeIndex = themeColorIndex;
    notifyListeners();
  }
}

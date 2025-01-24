import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart' as sp;

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  final sp.SharedPreferences _prefs;
  late ThemeMode _themeMode;

  ThemeProvider(this._prefs) {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;

  void _loadTheme() {
    final isDark = _prefs.getBool(_themeKey) ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _prefs.setBool(_themeKey, _themeMode == ThemeMode.dark);
    notifyListeners();
  }
}

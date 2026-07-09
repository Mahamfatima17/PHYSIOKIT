import 'package:flutter/material.dart';
import '../core/storage/storage_helper.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeProvider() {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void _loadTheme() {
    final dark = StorageHelper.isDarkMode;
    _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
      StorageHelper.isDarkMode = true;
    } else {
      _themeMode = ThemeMode.light;
      StorageHelper.isDarkMode = false;
    }
    notifyListeners();
  }
}

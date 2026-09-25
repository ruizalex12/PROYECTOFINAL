import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  PreferencesService(this._preferences);

  static const _themeKey = 'theme_mode';
  final SharedPreferences _preferences;

  ThemeMode readThemeMode() {
    return switch (_preferences.getString(_themeKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> saveThemeMode(ThemeMode mode) {
    return _preferences.setString(_themeKey, mode.name);
  }
}

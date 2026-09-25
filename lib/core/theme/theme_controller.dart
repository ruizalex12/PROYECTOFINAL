import 'package:flutter/material.dart';

import '../services/preferences_service.dart';

class ThemeController extends ChangeNotifier {
  ThemeController(this._service) : _themeMode = _service.readThemeMode();

  final PreferencesService _service;
  ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  Future<void> setThemeMode(ThemeMode value) async {
    if (_themeMode == value) return;
    _themeMode = value;
    notifyListeners();
    await _service.saveThemeMode(value);
  }
}

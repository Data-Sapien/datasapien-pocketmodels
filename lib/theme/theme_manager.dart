import 'package:flutter/material.dart';

import 'package:datasapien_sdk/datasapien_sdk.dart';

import '../utils/app_constants.dart';
import 'app_font.dart';

/// Manages app theme (light/dark) and chat text scale, mirroring iOS ThemeManager.
/// Loads from MeData when available; notifies listeners so the app can rebuild.
class ThemeManager extends ChangeNotifier {
  ThemeManager._();

  static final ThemeManager shared = ThemeManager._();

  static const Map<String, double> _chatScaleValues = {
    'small': 0.85,
    'default': 1.0,
    'large': 1.15,
    'huge': 1.3,
  };

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  set themeMode(ThemeMode value) {
    if (_themeMode == value) return;
    _themeMode = value;
    notifyListeners();
  }

  /// Apply theme from string ("lightmode" | "darkmode").
  void applyTheme(String theme) {
    themeMode = theme == 'darkmode' ? ThemeMode.dark : ThemeMode.light;
  }

  /// Set theme and persist to MeData. Call from App Settings.
  Future<void> setThemeAndPersist(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    try {
      final meDataService = DataSapien.getMeDataService();
      final value = mode == ThemeMode.dark ? 'darkmode' : 'lightmode';
      await meDataService.saveMeDataRecord(AppConstants.meDataKeys.appTheme,value);
    } catch (_) {}
  }

  /// Set chat text size and persist to MeData. [sizeName] is 'small' | 'default' | 'large' | 'huge'.
  Future<void> setChatTextSizeAndPersist(String sizeName) async {
    final scale = _chatScaleValues[sizeName] ?? 1.0;
    if (AppFont.chatScale == scale) return;
    AppFont.chatScale = scale;
    notifyListeners();
    try {
      final meDataService = DataSapien.getMeDataService();
      await meDataService.saveMeDataRecord(AppConstants.meDataKeys.chatTextSize, sizeName);
    } catch (_) {}
  }

  /// Load theme and chat text size from MeData and apply. Call after SDK is initialized.
  Future<void> applyInitialSettings() async {
    try {
      final meDataService = DataSapien.getMeDataService();

      // Load theme
      final themeRecord = await meDataService.getLastMeDataRecord(
        AppConstants.meDataKeys.appTheme,
      );
      final theme = themeRecord?.values.isNotEmpty == true
          ? themeRecord!.values.first.value
          : 'lightmode';
      applyTheme(theme);

      // Load chat text size
      final sizeRecord = await meDataService.getLastMeDataRecord(
        AppConstants.meDataKeys.chatTextSize,
      );
      final sizeName = sizeRecord?.values.isNotEmpty == true
          ? sizeRecord!.values.first.value
          : 'default';
      final scale = _chatScaleValues[sizeName] ?? 1.0;
      if (AppFont.chatScale != scale) {
        AppFont.chatScale = scale;
        notifyListeners();
      }
    } catch (_) {
      // Use defaults if MeData not available (e.g. before login)
    }
  }
}

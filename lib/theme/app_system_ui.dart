import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/sheets/system_ui_sheet_scope.dart';

/// Re-applies status bar style for the Flutter host (e.g. after native Journey UI).
void applyAppSystemUiOverlayStyle(ThemeMode themeMode) {
  if (kIsWeb) return;
  if (defaultTargetPlatform != TargetPlatform.android &&
      defaultTargetPlatform != TargetPlatform.iOS) {
    return;
  }
  final brightness = switch (themeMode) {
    ThemeMode.light => Brightness.light,
    ThemeMode.dark => Brightness.dark,
    ThemeMode.system => PlatformDispatcher.instance.platformBrightness,
  };
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiSheetScope.overlayForBrightness(brightness),
  );
}

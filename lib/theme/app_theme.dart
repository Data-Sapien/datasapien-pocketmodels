import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_color.dart';
import 'app_font.dart';

/// Builds light and dark [ThemeData] using [AppColor] and [AppFont].
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColor.primaryTint,
        brightness: Brightness.light,
      ),
      textTheme: _textTheme(Brightness.light),
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColor.primaryTint,
        brightness: Brightness.dark,
      ),
      textTheme: _textTheme(Brightness.dark),
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    );
  }

  static TextTheme _textTheme(Brightness brightness) {
    return TextTheme(
      displayLarge: AppFont.h1,
      headlineMedium: AppFont.h2,
      titleMedium: AppFont.h3,
      bodyMedium: AppFont.body,
      bodyLarge: AppFont.bodyBold,
      bodySmall: AppFont.caption,
      labelSmall: AppFont.captionBold,
      labelLarge: AppFont.button,
    );
  }
}

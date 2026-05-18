import 'package:flutter/material.dart';

/// App typography mirroring iOS AppFont.
/// [chatScale] affects body and bodyBold for chat text scaling.
class AppFont {
  AppFont._();

  /// Scale factor for chat text specifically (e.g. from MeData "small" / "default" / "large" / "huge").
  static double chatScale = 1.0;

  /// Huge title, appropriate for Welcome.
  static TextStyle get h1 => const TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.bold,
      );

  /// Section titles.
  static TextStyle get h2 => const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      );

  /// Feature headlines.
  static TextStyle get h3 => const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
      );

  /// Body text (scaled by [chatScale] for chat content).
  static TextStyle get body => TextStyle(
        fontSize: 15 * chatScale,
        fontWeight: FontWeight.normal,
      );

  /// Body bold.
  static TextStyle get bodyBold => TextStyle(
        fontSize: 15 * chatScale,
        fontWeight: FontWeight.w600,
      );

  /// Small sub-text.
  static const TextStyle caption = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
  );

  /// Small sub-text bold.
  static const TextStyle captionBold = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  /// Button font.
  static const TextStyle button = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.bold,
  );
}

import 'package:flutter/material.dart';

/// App color palette mirroring iOS AppColor.
/// Use semantic colors (e.g. from ThemeData.colorScheme) for light/dark support
/// where appropriate.
class AppColor {
  AppColor._();

  /// The primary tinted accent color (deep intuitive blue).
  /// RGB: 20, 100, 250
  static const Color primaryTint = Color(0xFF1464FA);

  /// Used for primary backgrounds. Maps to system background in light/dark.
  static Color primaryBackground(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  /// Used for grouped/card backgrounds.
  static Color secondaryBackground(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerHighest;

  /// Main text color.
  static Color textPrimary(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  /// Subtitle or unhighlighted text color.
  static Color textSecondary(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  /// Button foreground color (often white on primaryTint).
  static const Color buttonText = Colors.white;
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Pins [SystemUiOverlayStyle] for modal bottom sheets so a dark barrier does
/// not flip Android status bar icons away from the active app theme.
class SystemUiSheetScope extends StatelessWidget {
  const SystemUiSheetScope({super.key, required this.child});

  final Widget child;

  static SystemUiOverlayStyle overlayForBrightness(Brightness brightness) {
    return brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayForBrightness(Theme.of(context).brightness),
      child: child,
    );
  }
}

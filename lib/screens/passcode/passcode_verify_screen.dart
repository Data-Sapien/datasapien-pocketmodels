import 'package:flutter/material.dart';

import 'passcode_screen.dart';

/// Verify-only passcode screen used at app gate (e.g. after Splash).
/// No cancel button; on success calls [onSuccess].
class PasscodeVerifyScreen extends StatelessWidget {
  const PasscodeVerifyScreen({
    super.key,
    required this.onSuccess,
  });

  final VoidCallback onSuccess;

  @override
  Widget build(BuildContext context) {
    return PasscodeScreen(
      mode: PasscodeMode.verify,
      onSuccess: onSuccess,
      showCancelButton: false,
    );
  }
}

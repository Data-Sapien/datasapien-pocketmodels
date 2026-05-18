import 'package:flutter/cupertino.dart';

import 'onboarding_welcome_screen.dart';
import 'onboarding_features_screen.dart';
import 'onboarding_models_screen.dart';

/// Wraps the onboarding stack (Welcome → Features → Models) in a Navigator.
/// When the user completes onboarding on the Models screen, [onComplete] is called
/// so the app can replace the root with main chat.
class OnboardingFlow extends StatelessWidget {
  const OnboardingFlow({
    super.key,
    required this.onComplete,
  });

  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return CupertinoPageRoute<void>(
              builder: (_) => const OnboardingWelcomeScreen(),
            );
          case '/features':
            return CupertinoPageRoute<void>(
              builder: (_) => const OnboardingFeaturesScreen(),
            );
          case '/models':
            return CupertinoPageRoute<void>(
              builder: (_) => OnboardingModelsScreen(onComplete: onComplete),
            );
          default:
            return CupertinoPageRoute<void>(
              builder: (_) => const OnboardingWelcomeScreen(),
            );
        }
      },
    );
  }
}

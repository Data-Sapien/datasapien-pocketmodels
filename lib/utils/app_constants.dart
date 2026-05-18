/// App-wide constants mirroring iOS AppConstants.
class AppConstants {
  AppConstants._();

  /// Must match [DataSapien.initialize] `setMediaUrl` in `main.dart`.
  /// Replace with the media base URL provided with your DataSapien credentials.
  static const String mediaBaseUrl = 'YOUR_MEDIA_URL';

  static const MeDataKeys meDataKeys = MeDataKeys();
  static const SecurityKeys securityKeys = SecurityKeys();
  static const PersonalizationKeys personalizationKeys = PersonalizationKeys();
  static const OnboardingStatus onboardingStatus = OnboardingStatus();
  static const SettingsKeys settingsKeys = SettingsKeys();
}

class MeDataKeys {
  const MeDataKeys();

  final String onboardingStatus = 'onboarding_status';
  final String chosenModel = 'choosen_model';
  final String useMemories = 'use_memories';
  final String autoLearn = 'auto_learn_from_conversations';
  /// "lightmode" | "darkmode"
  final String appTheme = 'appearance';
  /// "small" | "default" | "large" | "huge"
  final String chatTextSize = 'font_size';
}

class SecurityKeys {
  const SecurityKeys();

  final String passcodeEnabled = 'passcode_enabled';
  final String passcodeValue = 'passcode_value';
}

class PersonalizationKeys {
  const PersonalizationKeys();

  final String customPrompts = 'custom_prompts';
}

class OnboardingStatus {
  const OnboardingStatus();

  final String started = 'started';
  final String finished = 'finished';
}

class SettingsKeys {
  const SettingsKeys();

  final String systemPrompt = 'system_prompt';
  final String temperature = 'temperature';
  final String topP = 'topp';
  final String nCtx = 'nctx';
}

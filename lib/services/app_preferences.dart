import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_constants.dart';

/// Reads/writes app preferences (e.g. passcode). Mirrors iOS UserDefaults usage.
/// Step 10 will write passcode state; Step 02 only reads.
class AppPreferences {
  AppPreferences._();

  static SharedPreferences? _prefs;
  static Future<SharedPreferences> get _instance async =>
      _prefs ??= await SharedPreferences.getInstance();

  /// Whether passcode lock is enabled. Step 10 sets this when user enables passcode.
  static Future<bool> getPasscodeEnabled() async {
    final prefs = await _instance;
    return prefs.getBool(AppConstants.securityKeys.passcodeEnabled) ?? false;
  }

  /// Set whether passcode lock is enabled. Used by PasscodeService when saving/clearing passcode.
  static Future<void> setPasscodeEnabled(bool value) async {
    final prefs = await _instance;
    await prefs.setBool(AppConstants.securityKeys.passcodeEnabled, value);
  }
}

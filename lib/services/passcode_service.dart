import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../utils/app_constants.dart';
import 'app_preferences.dart';

/// Stores and verifies passcode using a SHA-256 hash in secure storage.
/// Never stores plain passcode.
class PasscodeService {
  PasscodeService._();

  static const _passcodeLength = 6;

  static final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static String _hash(String code) {
    final bytes = utf8.encode(code);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Saves the passcode (hashed) to secure storage and enables passcode in preferences.
  static Future<void> setPasscode(String code) async {
    if (code.length != _passcodeLength) return;
    final hashed = _hash(code);
    await _storage.write(
      key: AppConstants.securityKeys.passcodeValue,
      value: hashed,
    );
    await AppPreferences.setPasscodeEnabled(true);
  }

  /// Returns true if [code] matches the stored passcode.
  static Future<bool> verifyPasscode(String code) async {
    if (code.length != _passcodeLength) return false;
    final stored = await _storage.read(
      key: AppConstants.securityKeys.passcodeValue,
    );
    if (stored == null) return false;
    return _hash(code) == stored;
  }

  /// Removes stored passcode and disables passcode in preferences.
  static Future<void> clearPasscode() async {
    await _storage.delete(key: AppConstants.securityKeys.passcodeValue);
    await AppPreferences.setPasscodeEnabled(false);
  }

  static int get passcodeLength => _passcodeLength;
}

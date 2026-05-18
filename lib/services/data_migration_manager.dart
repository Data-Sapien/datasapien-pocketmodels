import 'dart:convert';

import 'package:datasapien_sdk/datasapien_sdk.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Runs data migrations on app upgrade. Mirrors iOS DataMigrationManager.
class DataMigrationManager {
  DataMigrationManager._();

  static final DataMigrationManager shared = DataMigrationManager._();

  static const String _lastVersionKey = 'last_launched_app_version';
  static const String _userInferredDataKey = 'user_inferred_data';

  /// Call early after SDK init (e.g. from splash). Runs version-based migrations then completes.
  Future<void> runMigrationsIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    final lastVersion = prefs.getString(_lastVersionKey) ?? '0.0.0';

    if (_compareVersions(currentVersion, lastVersion) == 0) {
      return;
    }

    if (_compareVersions(lastVersion, '1.0.1') < 0) {
      await _migrateToV1_0_1_MemoryFormat();
    }

    await prefs.setString(_lastVersionKey, currentVersion);
  }

  static int _compareVersions(String a, String b) {
    final aParts = a.split('.').map(int.tryParse).toList();
    final bParts = b.split('.').map(int.tryParse).toList();
    for (var i = 0; i < 3; i++) {
      final av = i < aParts.length ? (aParts[i] ?? 0) : 0;
      final bv = i < bParts.length ? (bParts[i] ?? 0) : 0;
      if (av != bv) return av.compareTo(bv);
    }
    return 0;
  }

  /// Migration 1.0.1: Convert legacy user_inferred_data from [{"name": "Arda"}] to [{"key": "name", "value": "Arda"}].
  Future<void> _migrateToV1_0_1_MemoryFormat() async {
    try {
      final meDataService = DataSapien.getMeDataService();
      final record = await meDataService.getLastMeDataRecord(_userInferredDataKey);
      final jsonString = record?.values.isNotEmpty == true
          ? record!.values.first.value?.toString()
          : null;
      if (jsonString == null || jsonString.trim().isEmpty) return;

      final decoded = jsonDecode(jsonString);
      if (decoded is! List || decoded.isEmpty) return;

      var didModifyAny = false;
      final migratedArray = <Map<String, String>>[];

      for (final item in decoded) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        final stringMap = map.map((k, v) => MapEntry(k as String, v?.toString() ?? ''));
        if (stringMap.containsKey('key') && stringMap.containsKey('value')) {
          migratedArray.add(stringMap);
        } else {
          for (final entry in stringMap.entries) {
            migratedArray.add({'key': entry.key, 'value': entry.value});
            didModifyAny = true;
          }
        }
      }

      if (!didModifyAny) return;

      final newJsonString = jsonEncode(migratedArray);
      await meDataService.saveMeDataRecord(_userInferredDataKey, newJsonString);
    } catch (_) {
      // Ignore migration errors (e.g. no MeData yet)
    }
  }
}

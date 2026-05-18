import 'package:datasapien_sdk/datasapien_sdk.dart';
import 'package:flutter/foundation.dart';

import '../utils/app_constants.dart';
import '../utils/app_prompts.dart';

/// In-memory cache of app settings persisted via MeData. Mirrors iOS SettingsManager.
class SettingsManager extends ChangeNotifier {
  SettingsManager._();
  static final SettingsManager shared = SettingsManager._();

  String _systemPrompt = AppPrompts.systemHelpfulAssistant;
  double _temperature = 0.7;
  double _topP = 0.95;
  int _nCtx = 10000;

  bool isLoaded = false;

  String get systemPrompt => _systemPrompt;
  double get temperature => _temperature;
  double get topP => _topP;
  int get nCtx => _nCtx;

  set systemPrompt(String value) {
    if (_systemPrompt == value) return;
    _systemPrompt = value;
    notifyListeners();
  }

  set temperature(double value) {
    if (_temperature == value) return;
    _temperature = value;
    notifyListeners();
  }

  set topP(double value) {
    if (_topP == value) return;
    _topP = value;
    notifyListeners();
  }

  set nCtx(int value) {
    if (_nCtx == value) return;
    _nCtx = value;
    notifyListeners();
  }

  final _keys = [
    AppConstants.settingsKeys.systemPrompt,
    AppConstants.settingsKeys.temperature,
    AppConstants.settingsKeys.topP,
    AppConstants.settingsKeys.nCtx,
  ];

  /// Load all settings from MeData. Call after SDK is ready.
  Future<void> loadSettings() async {
    final meDataService = DataSapien.getMeDataService();
    for (final key in _keys) {
      try {
        final record = await meDataService.getLastMeDataRecord(key);
        final value = record?.values.isNotEmpty == true
            ? record!.values.first.value.toString()
            : null;
        if (value == null || value.isEmpty) continue;
        if (key == AppConstants.settingsKeys.systemPrompt) {
          _systemPrompt = value;
        } else if (key == AppConstants.settingsKeys.temperature) {
          _temperature = double.tryParse(value) ?? _temperature;
        } else if (key == AppConstants.settingsKeys.topP) {
          _topP = double.tryParse(value) ?? _topP;
        } else if (key == AppConstants.settingsKeys.nCtx) {
          _nCtx = int.tryParse(value) ?? _nCtx;
        }
      } catch (_) {}
    }
    isLoaded = true;
    notifyListeners();
  }

  /// Persist current in-memory settings to MeData (best-effort per key; iOS SettingsManager parity).
  Future<void> saveSettings() async {
    final meDataService = DataSapien.getMeDataService();
    await Future.wait([
      _saveMeDataField(
        meDataService,
        AppConstants.settingsKeys.systemPrompt,
        _systemPrompt,
      ),
      _saveMeDataField(
        meDataService,
        AppConstants.settingsKeys.temperature,
        _temperature.toString(),
      ),
      _saveMeDataField(
        meDataService,
        AppConstants.settingsKeys.topP,
        _topP.toString(),
      ),
      _saveMeDataField(
        meDataService,
        AppConstants.settingsKeys.nCtx,
        _nCtx.toString(),
      ),
    ]);
  }

  Future<void> _saveMeDataField(
    MeDataService meDataService,
    String key,
    Object? value,
  ) async {
    try {
      await meDataService.saveMeDataRecord(key, value);
    } catch (e, st) {
      debugPrint('SettingsManager: failed to save $key: $e\n$st');
    }
  }

  /// Model params for SDK loadModel.
  ModelParams getModelParams() => ModelParams(
        nCtx: _nCtx,
        nBatchSize: 256,
      );

  /// Inference params for SDK invokeModel.
  InferenceParams getInferenceParams() => InferenceParams(
        temperature: _temperature,
        maxTokens: _nCtx,
      );

  /// Deterministic params for memory extraction and app-opener JSON (iOS parity).
  InferenceParams getInferenceParamsForMemoryExtraction() =>
      const InferenceParams(
        temperature: 0,
        topP: 1,
        maxTokens: 512,
      );
}

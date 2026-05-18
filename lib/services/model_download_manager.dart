import 'dart:async';

import 'package:datasapien_sdk/datasapien_sdk.dart';
import 'package:flutter/foundation.dart';

import '../utils/app_constants.dart';
import 'model_selector_source.dart';

/// Manages model list, download queue, and progress. Notifies listeners on state change.
class ModelDownloadManager extends ChangeNotifier {
  ModelDownloadManager._();
  static final ModelDownloadManager instance = ModelDownloadManager._();

  List<ManagedModelItem> _models = [];
  final Set<String> _downloaded = {};
  final List<String> _downloadQueue = [];
  String? _activeDownload;
  final Map<String, double> _progress = {};
  String? _lastDownloadError;

  /// Fired once after [downloadModelFiles] succeeds for [modelName]. Used to refresh chat readiness.
  void Function(String modelName)? onDownloadSucceeded;

  /// Fired when [downloadModelFiles] throws for [modelName] (user-visible diagnostics).
  void Function(String modelName, Object error)? onDownloadFailed;

  /// Cleared on the next successful download or when a new download starts.
  String? get lastDownloadError => _lastDownloadError;

  List<ManagedModelItem> get models => List.unmodifiable(_models);
  Set<String> get downloadedModelNames => Set.unmodifiable(_downloaded);
  double? progressFor(String modelName) => _progress[modelName];
  bool isDownloading(String modelName) => _activeDownload == modelName;
  bool isQueued(String modelName) => _downloadQueue.contains(modelName);
  bool isPending(String modelName) => isDownloading(modelName) || isQueued(modelName);

  /// Load model list from SDK and refresh downloaded set.
  Future<void> load() async {
    try {
      final service = DataSapien.getIntelligenceService();
      final managed = await service.getManagedAIModels();
      final filtered = managed
          .where((m) => m.imageUrl != null && m.imageUrl!.isNotEmpty)
          .toList()
        ..sort((a, b) => a.text.compareTo(b.text));
      _models = filtered
          .map(
            (m) => ManagedModelItem(
              id: m.id,
              name: m.name,
              displayTitle: m.text.isNotEmpty ? m.text : m.name,
              subtitle: m.description,
              imageUrl: m.imageUrl,
              sizeLabel: m.description,
              multimodal: m.multimodal,
            ),
          )
          .toList();
      final list = await service.getDownloadedModelsList();
      _downloaded.clear();
      _downloaded.addAll(list);
      // Native getDownloadedModelsList may return on-disk filenames while rows
      // use managed model `name`; align with enqueueDownload / isModelFilesDownloaded.
      for (final m in _models) {
        if (m.name.isEmpty) continue;
        try {
          if (await service.isModelFilesDownloaded(m.name)) {
            _downloaded.add(m.name);
          }
        } catch (_) {}
      }
      notifyListeners();
    } catch (_) {
      _models = [
        const ManagedModelItem(
          id: 'default',
          name: 'Default model',
          displayTitle: 'Default model',
          sizeLabel: '—',
          multimodal: false,
        ),
      ];
      notifyListeners();
    }
  }

  /// Enqueue a model for download; starts immediately if no active download.
  Future<void> enqueueDownload(String modelName) async {
    if (_activeDownload == modelName || _downloadQueue.contains(modelName)) return;
    if (_downloaded.contains(modelName)) {
      notifyListeners();
      return;
    }
    try {
      final service = DataSapien.getIntelligenceService();
      if (await service.isModelFilesDownloaded(modelName)) {
        _downloaded.add(modelName);
        notifyListeners();
        return;
      }
    } catch (_) {}

    _downloadQueue.add(modelName);
    notifyListeners();
    if (_activeDownload == null) _processNext();
  }

  Future<void> _processNext() async {
    if (_activeDownload != null || _downloadQueue.isEmpty) return;
    final next = _downloadQueue.removeAt(0);
    _activeDownload = next;
    _lastDownloadError = null;
    notifyListeners();

    try {
      final service = DataSapien.getIntelligenceService();
      await service.downloadModelFiles(
        next,
        onProgress: (p) {
          _progress[next] = p;
          notifyListeners();
        },
      );
      _progress.remove(next);
      _downloaded.add(next);
      _lastDownloadError = null;
      onDownloadSucceeded?.call(next);
    } catch (e, st) {
      _progress.remove(next);
      _lastDownloadError = e.toString();
      debugPrint('ModelDownloadManager: download failed for $next: $e\n$st');
      onDownloadFailed?.call(next, e);
    }
    _activeDownload = null;
    notifyListeners();
    _processNext();
  }

  /// Removes on-device model files via the SDK and updates local state.
  /// Throws if the native layer fails (caller should show an error).
  Future<void> deleteDownloadedModel(String modelName) async {
    final service = DataSapien.getIntelligenceService();
    await service.deleteModelFiles(modelName);
    _downloaded.remove(modelName);
    _downloadQueue.remove(modelName);
    _progress.remove(modelName);
    notifyListeners();
  }

  /// Deletes every on-device model reported by the SDK; clears queue/progress state.
  /// Swallows per-model failures so the rest still run.
  Future<void> deleteAllDownloadedModels() async {
    final service = DataSapien.getIntelligenceService();
    List<String> names;
    try {
      names = await service.getDownloadedModelsList();
    } catch (_) {
      names = const [];
    }
    _downloadQueue.clear();
    _activeDownload = null;
    _progress.clear();
    for (final name in names) {
      try {
        await service.deleteModelFiles(name);
      } catch (_) {}
    }
    _downloaded.clear();
    notifyListeners();
  }
}

/// Data source that combines ModelDownloadManager with MeData for current selection.
class ModelDownloadManagerDataSource with ChangeNotifier implements ModelSelectorDataSource {
  ModelDownloadManagerDataSource({
    ModelDownloadManager? manager,
    bool registerAsPrimary = false,
  })  : _manager = manager ?? ModelDownloadManager.instance,
        _registerAsPrimary = registerAsPrimary {
    _manager.addListener(_onManagerChanged);
    if (_registerAsPrimary) {
      _primaryInstance = this;
    }
  }

  final ModelDownloadManager _manager;
  final bool _registerAsPrimary;
  static ModelDownloadManagerDataSource? _primaryInstance;

  /// Reloads MeData chosen-model into the main chat data source after bulk delete or similar.
  static Future<void> refreshRegisteredPrimary() async {
    await _primaryInstance?.load();
  }

  String? _currentSelectedModelName;

  void _onManagerChanged() => notifyListeners();

  @override
  void dispose() {
    if (_registerAsPrimary && identical(_primaryInstance, this)) {
      _primaryInstance = null;
    }
    _manager.removeListener(_onManagerChanged);
    super.dispose();
  }

  @override
  List<ManagedModelItem> get models => _manager.models;

  @override
  Set<String> get downloadedModelNames => _manager.downloadedModelNames;

  @override
  String? get currentSelectedModelName => _currentSelectedModelName;

  @override
  double? progressFor(String modelName) => _manager.progressFor(modelName);

  @override
  bool isDownloading(String modelName) => _manager.isDownloading(modelName);

  @override
  bool isQueued(String modelName) => _manager.isQueued(modelName);

  @override
  Future<void> load() async {
    await _manager.load();
    try {
      final meDataService = DataSapien.getMeDataService();
      final record = await meDataService.getLastMeDataRecord(
        AppConstants.meDataKeys.chosenModel,
      );
      if (record?.values.isNotEmpty == true) {
        final value = record!.values.first.value;
        if (value.toString().trim().isNotEmpty) {
          _currentSelectedModelName = value.toString().trim();
          if (!_manager.downloadedModelNames.contains(_currentSelectedModelName)) {
            // Don't mutate _manager's set; selection is still valid
          }
        } else {
          _currentSelectedModelName = null;
        }
      } else {
        _currentSelectedModelName = null;
      }
    } catch (_) {}
    notifyListeners();
  }

  @override
  Future<void> setCurrentModel(String modelName) async {
    DataSapienDiagnostics.instance
        .logModelPickerSelected(displayName: modelName);
    final meDataService = DataSapien.getMeDataService();
    await meDataService.saveMeDataRecord(AppConstants.meDataKeys.chosenModel, modelName);
    _currentSelectedModelName = modelName;
    notifyListeners();
  }

  @override
  Future<void> startDownload(String modelName) async {
    await _manager.enqueueDownload(modelName);
  }

  @override
  Future<void> deleteDownloadedModel(String modelName) async {
    await _manager.deleteDownloadedModel(modelName);
  }

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
  }
}

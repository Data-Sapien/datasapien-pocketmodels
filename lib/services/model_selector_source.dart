import 'package:datasapien_sdk/datasapien_sdk.dart';
import 'package:flutter/foundation.dart';

import '../utils/app_constants.dart';

/// Item representing one model in the selector list.
/// Used by [ModelSelectorDataSource] and [ModelDownloadManagerDataSource].
class ManagedModelItem {
  const ManagedModelItem({
    required this.id,
    required this.name,
    this.sizeBytes,
    this.sizeLabel,
    this.displayTitle,
    this.subtitle,
    this.imageUrl,
    this.multimodal = false,
  });

  final String id;
  final String name;
  final int? sizeBytes;
  final String? sizeLabel;

  /// UI title (SDK `text` when set, else [name]). Matches iOS `text ?? name`.
  final String? displayTitle;

  /// Secondary line (e.g. model description or size).
  final String? subtitle;

  /// Raw image path or URL from API; resolved with [AppConstants.mediaBaseUrl].
  final String? imageUrl;

  /// Whether the model supports multimodal (vision) prompts.
  final bool multimodal;

  String resolvedDisplayTitle(String defaultModelLabel) =>
      id == 'default' ? defaultModelLabel : (displayTitle ?? name);
}

/// Contract for model list + download state + current selection.
/// Primary implementation: [ModelDownloadManagerDataSource]; optional fallback: [StubModelSelectorSource].
abstract class ModelSelectorDataSource {
  List<ManagedModelItem> get models;
  Set<String> get downloadedModelNames;
  String? get currentSelectedModelName;
  double? progressFor(String modelName);
  bool isDownloading(String modelName);
  bool isQueued(String modelName);
  Future<void> load();
  Future<void> setCurrentModel(String modelName);
  Future<void> startDownload(String modelName);
  Future<void> deleteDownloadedModel(String modelName);
  void addListener(VoidCallback listener);
  void removeListener(VoidCallback listener);
}

/// Optional fallback when no source is provided to [ModelSelectorSheet] (e.g. tests).
/// Main chat uses [ModelDownloadManagerDataSource]. Uses MeDataService for chosen model;
/// fixed model list and in-memory "downloaded" set; no real download.
class StubModelSelectorSource with ChangeNotifier implements ModelSelectorDataSource {
  StubModelSelectorSource() {
    _models = [
      const ManagedModelItem(
        id: 'default',
        name: 'Default model',
        sizeLabel: '—',
        multimodal: false,
      ),
    ];
  }

  late List<ManagedModelItem> _models;
  final Set<String> _downloaded = {'default'};
  String? _currentSelectedModelName;
  final Map<String, double> _progress = {};
  final Set<String> _downloading = {};

  @override
  List<ManagedModelItem> get models => List.unmodifiable(_models);

  @override
  Set<String> get downloadedModelNames => Set.unmodifiable(_downloaded);

  @override
  String? get currentSelectedModelName => _currentSelectedModelName;

  @override
  double? progressFor(String modelName) => _progress[modelName];

  @override
  bool isDownloading(String modelName) => _downloading.contains(modelName);

  @override
  bool isQueued(String modelName) => false;

  @override
  Future<void> load() async {
    try {
      final meDataService = DataSapien.getMeDataService();
      final record = await meDataService.getLastMeDataRecord(
        AppConstants.meDataKeys.chosenModel,
      );
      if (record?.values.isNotEmpty == true) {
        final value = record!.values.first.value;
        if (value.toString().trim().isNotEmpty) {
          _currentSelectedModelName = value.toString().trim();
          if (!_downloaded.contains(_currentSelectedModelName)) {
            _downloaded.add(_currentSelectedModelName!);
          }
        }
      }
    } catch (_) {
      // Keep default selection
    }
    notifyListeners();
  }

  @override
  Future<void> setCurrentModel(String modelName) async {
    DataSapienDiagnostics.instance
        .logModelPickerSelected(displayName: modelName);
    final meDataService = DataSapien.getMeDataService();
    await meDataService.saveMeDataRecord(AppConstants.meDataKeys.chosenModel, modelName);
    _currentSelectedModelName = modelName;
    if (!_downloaded.contains(modelName)) {
      _downloaded.add(modelName);
    }
    notifyListeners();
  }

  @override
  Future<void> startDownload(String modelName) async {
    if (_downloading.contains(modelName) || _downloaded.contains(modelName)) {
      return;
    }
    _downloading.add(modelName);
    _progress[modelName] = 0;
    notifyListeners();

    // Stub: simulate progress then "complete"
    for (var p = 0.0; p <= 1.0; p += 0.2) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      if (!_downloading.contains(modelName)) return;
      _progress[modelName] = p;
      notifyListeners();
    }
    _progress.remove(modelName);
    _downloading.remove(modelName);
    _downloaded.add(modelName);
    notifyListeners();
  }

  @override
  Future<void> deleteDownloadedModel(String modelName) async {
    _downloaded.remove(modelName);
    notifyListeners();
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

import 'dart:convert';

import 'package:datasapien_sdk/datasapien_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../models/search_result.dart';
import '../utils/app_constants.dart';
import '../utils/app_prompts.dart';
import '../utils/inference_metrics.dart';
import '../services/history_manager.dart';
import '../services/me_data_category_loader.dart';
import '../services/model_download_manager.dart';
import '../services/settings_manager.dart';
import '../services/web_search_service.dart';

/// Holds main chat state: session, messages, model, streaming. Integrates with HistoryManager and SDK.
class MainChatViewModel extends ChangeNotifier {
  MainChatViewModel._();
  static final MainChatViewModel instance = MainChatViewModel._();

  final HistoryManager _history = HistoryManager.instance;
  final SettingsManager _settings = SettingsManager.shared;
  static const String _modelKey = 'primary';

  ChatSession? _currentSession;
  final List<ChatMessage> _messages = [];
  final List<Prompt> _promptHistory = [];
  bool _isGenerating = false;
  String _currentModelName = '';
  String _modelState =
      'unknown'; // 'unknown' | 'loading' | 'ready' | 'error' | 'downloading'
  bool _isCurrentModelMultimodal = false;

  ChatSession? get currentSession => _currentSession;
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isGenerating => _isGenerating;
  String get currentModelName => _currentModelName;
  String get modelState => _modelState;
  bool get isModelReady => _modelState == 'ready';
  bool get isCurrentModelMultimodal => _isCurrentModelMultimodal;
  final List<PendingInference> _pendingInferences = [];

  /// Shown as a vertical stack above the input (iOS InferenceToastManager).
  List<PendingInference> get pendingInferences =>
      List<PendingInference>.unmodifiable(_pendingInferences);

  void removePendingInference(PendingInference pending) {
    _pendingInferences.removeWhere((e) => e.id == pending.id);
    notifyListeners();
  }

  Future<String> _extractSearchQuery(String text) async {
    final historyLimit = _promptHistory.length < 5 ? _promptHistory.length : 5;
    final recentHistory =
        _promptHistory.sublist(_promptHistory.length - historyLimit);
    final historyLines = recentHistory
        .map((msg) =>
            '${msg.role == PromptRole.user ? 'User' : 'AI'}: ${msg.content}')
        .join('\n');
    final queryPrompt = Prompt(
      role: PromptRole.user,
      content:
          '${AppPrompts.webSearchQueryExtraction}\n\nRecent Conversation:\n$historyLines\n\nLatest Message:\n"$text"\n\nSearch Query:',
    );
    try {
      final intelligence = DataSapien.getIntelligenceService();
      final output = await intelligence.invokeModel(
        _modelKey,
        [queryPrompt],
        inferenceParams: _settings.getInferenceParams(),
      );
      final cleaned = output.trim().replaceAll('"', '');
      return cleaned.isEmpty ? text : cleaned;
    } catch (_) {
      return text;
    }
  }

  /// Load chosen model from MeData and sync with downloaded/loading state.
  Future<void> loadAndSyncModel() async {
    if (!_settings.isLoaded) await _settings.loadSettings();
    _modelState = 'loading';
    _isCurrentModelMultimodal = false;
    notifyListeners();
    try {
      final meDataService = DataSapien.getMeDataService();
      final record = await meDataService.getLastMeDataRecord(
        AppConstants.meDataKeys.chosenModel,
      );
      final modelValue = record?.values.isNotEmpty == true
          ? record!.values.first.value.toString().trim()
          : null;
      if (modelValue == null || modelValue.isEmpty) {
        _currentModelName = '';
        _modelState = 'unknown';
        _isCurrentModelMultimodal = false;
        notifyListeners();
        return;
      }
      _currentModelName = modelValue;
      final intelligence = DataSapien.getIntelligenceService();

      try {
        final managed = await intelligence.getManagedAIModels();
        final match = managed.where((m) => m.name == modelValue).toList();
        _isCurrentModelMultimodal = match.isNotEmpty ? match.first.multimodal : false;
      } catch (_) {
        _isCurrentModelMultimodal = false;
      }

      final downloaded = await intelligence.getDownloadedModelsList();
      var onDisk = downloaded.contains(modelValue);
      if (!onDisk) {
        try {
          onDisk = await intelligence.isModelFilesDownloaded(modelValue);
        } catch (_) {}
      }
      if (!onDisk) {
        if (ModelDownloadManager.instance.isPending(modelValue)) {
          _modelState = 'downloading';
          notifyListeners();
          return;
        }
        _modelState = 'unknown';
        notifyListeners();
        return;
      }
      await intelligence.unloadModel(key: _modelKey);
      await intelligence.loadModel(
        modelValue,
        _modelKey,
        modelParams: _settings.getModelParams(),
      );
      _modelState = 'ready';
    } catch (_) {
      _modelState = 'error';
      _isCurrentModelMultimodal = false;
    }
    notifyListeners();
  }

  /// Load a session from history and set messages.
  Future<void> loadSession(ChatSession session) async {
    _currentSession = session;
    _messages.clear();
    _promptHistory.clear();
    final list = await _history.getMessagesForSession(session.id);
    _messages.addAll(list);
    for (final msg in list) {
      if (msg.type is UserMessageType) {
        _promptHistory.add(Prompt(role: PromptRole.user, content: msg.text));
      } else if (msg.type is AiMessageType) {
        _promptHistory
            .add(Prompt(role: PromptRole.assistant, content: msg.text));
      }
    }
    notifyListeners();
  }

  /// Clear current session and messages.
  void clearSession() {
    _currentSession = null;
    _messages.clear();
    _promptHistory.clear();
    _pendingInferences.clear();
    notifyListeners();
  }

  /// Send user message, then invoke model and stream AI response. When an
  /// attachment is supplied (from the attachment sheet) the document is added
  /// as its own bubble and the prompt content is wrapped with
  /// [AppPrompts.attachedDocumentContext], matching iOS parity.
  Future<void> sendMessage(
    String text, {
    bool isWebSearchEnabled = false,
    String? attachmentName,
    String? attachmentContent,
    String? imagePath,
  }) async {
    final trimmedText = text.trim();
    final hasText = trimmedText.isNotEmpty;
    final hasAttachment =
        attachmentContent != null && attachmentContent.isNotEmpty;
    final hasImage = imagePath != null && imagePath.isNotEmpty;
    if (!hasText && !hasAttachment && !hasImage) return;
    if (_modelState != 'ready') return;
    if (_isGenerating) return;

    await HistoryManager.instance.ensureInitialized();

    _currentSession ??= await _history.createSession();
    final session = _currentSession!;

    var combinedPromptContent = trimmedText;
    String? imageAttachmentPath;

    if (hasImage) {
      final imgMessage = ChatMessage(
        id: 'msg_img_${DateTime.now().millisecondsSinceEpoch}',
        type: ImageMessageType(imagePath),
        text: '',
      );
      _messages.add(imgMessage);
      notifyListeners();

      imageAttachmentPath = imagePath;
      await _history.saveMessage(
        session.id,
        ChatMessage(
          id: 'msg_img_stub_${DateTime.now().millisecondsSinceEpoch}',
          type: const UserMessageType(),
          text: '[Attached Image]',
        ),
      );
    }

    if (hasAttachment) {
      final docName = (attachmentName == null || attachmentName.isEmpty)
          ? 'Document'
          : attachmentName;
      final docMessage = ChatMessage(
        id: 'msg_doc_${DateTime.now().millisecondsSinceEpoch}',
        type: DocumentMessageType(docName),
        text: attachmentContent,
      );
      _messages.add(docMessage);
      notifyListeners();

      // iOS parity: persist only "[Attached Document: <name>]" under role=user
      // (HistoryManager.saveMessage role: "user",
      //  text: "[Attached Document: \(attName)]") — full content is
      // intentionally not persisted. See MainChatViewModel.swift:165.
      await _history.saveMessage(
        session.id,
        ChatMessage(
          id: 'msg_doc_stub_${DateTime.now().millisecondsSinceEpoch}',
          type: const UserMessageType(),
          text: '[Attached Document: $docName]',
        ),
      );

      combinedPromptContent = AppPrompts.attachedDocumentContext(
        docName,
        attachmentContent,
        trimmedText,
      );
    }

    if (hasText) {
      final userMessage = ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        type: const UserMessageType(),
        text: trimmedText,
      );
      _messages.add(userMessage);
      notifyListeners();
      await _history.saveMessage(session.id, userMessage);
    }

    _promptHistory
        .add(Prompt(role: PromptRole.user, content: combinedPromptContent, attachment: imageAttachmentPath));

    await _inferUserData(text.trim());
    await _handleAppOpener(text.trim());

    String? injectedSearchContext;
    if (isWebSearchEnabled) {
      final loadingSearchMessage = ChatMessage(
        id: 'msg_search_${DateTime.now().millisecondsSinceEpoch}',
        type: const WebSearchMessageType('', null),
        text: '',
      );
      _messages.add(loadingSearchMessage);
      notifyListeners();
      try {
        final query = await _extractSearchQuery(text.trim());
        final results = await WebSearchService.instance.performSearch(
          query,
          maxResults: 2,
        );
        final readySearchMessage = ChatMessage(
          id: loadingSearchMessage.id,
          type: WebSearchMessageType(query, results),
          text: '',
          timestamp: loadingSearchMessage.timestamp,
        );
        final idx =
            _messages.indexWhere((m) => m.id == loadingSearchMessage.id);
        if (idx >= 0) {
          _messages[idx] = readySearchMessage;
        }
        await _history.saveMessage(session.id, readySearchMessage);
        if (results.isNotEmpty) {
          injectedSearchContext = await _buildSearchContext(results);
        }
        notifyListeners();
      } catch (_) {
        final failedSearchMessage = ChatMessage(
          id: loadingSearchMessage.id,
          type: const WebSearchMessageType('', <SearchResult>[]),
          text: '',
          timestamp: loadingSearchMessage.timestamp,
        );
        final idx =
            _messages.indexWhere((m) => m.id == loadingSearchMessage.id);
        if (idx >= 0) {
          _messages[idx] = failedSearchMessage;
        }
        notifyListeners();
      }
    }

    final aiMessage = ChatMessage(
      id: 'msg_ai_${DateTime.now().millisecondsSinceEpoch}',
      type: const AiMessageType(),
      text: '',
      isStreaming: true,
    );
    _messages.add(aiMessage);
    _isGenerating = true;
    notifyListeners();

    try {
      final intelligence = DataSapien.getIntelligenceService();
      var systemContent = _settings.systemPrompt;
      if (systemContent.trim().isEmpty) {
        systemContent = AppPrompts.systemHelpfulAssistant;
      }
      final myDataContext = await _fetchMyDataContext();
      if (myDataContext != null && myDataContext.isNotEmpty) {
        systemContent = '$systemContent\n\n$myDataContext';
      }
      final prompts = <Prompt>[
        Prompt(role: PromptRole.system, content: systemContent),
        ..._promptHistory,
      ];
      if (injectedSearchContext != null && injectedSearchContext.isNotEmpty) {
        final lastUserIndex =
            prompts.lastIndexWhere((prompt) => prompt.role == PromptRole.user);
        if (lastUserIndex >= 0) {
          final originalQuery = prompts[lastUserIndex].content;
          prompts[lastUserIndex] = Prompt(
            role: PromptRole.user,
            content:
                '${AppPrompts.webSearchRealtimeOverride}\n\n$injectedSearchContext\n\nMY QUESTION: $originalQuery',
          );
        }
      }
      var generatedChunkCount = 0;
      DateTime? firstChunkTime;
      final fullText = await intelligence.invokeModel(
        _modelKey,
        prompts,
        inferenceParams: _settings.getInferenceParams(),
        onStream: (chunk) {
          firstChunkTime ??= DateTime.now();
          generatedChunkCount++;
          aiMessage.text += chunk;
          notifyListeners();
        },
      );
      final completedTime = DateTime.now();
      aiMessage.text = fullText;
      aiMessage.isStreaming = false;
      aiMessage.metrics = performanceFromStreamStats(
        generatedChunkCount: generatedChunkCount,
        firstChunkTime: firstChunkTime,
        completedTime: completedTime,
        prompts: prompts,
        nCtx: _settings.getModelParams().nCtx,
      );
      _promptHistory.add(Prompt(role: PromptRole.assistant, content: fullText));
      await _history.saveMessage(
        session.id,
        ChatMessage(
          id: aiMessage.id,
          type: const AiMessageType(),
          text: fullText,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      aiMessage.isStreaming = false;
      aiMessage.isError = true;
      aiMessage.text = _mapModelError(e);
      notifyListeners();
    }
    _isGenerating = false;
    notifyListeners();
  }

  /// Call when model download completes so we can load and set ready.
  void onModelDownloadComplete(String modelName) {
    if (modelName == _currentModelName) {
      loadAndSyncModel();
    }
  }

  Future<void> stopInference() async {
    try {
      await DataSapien.getIntelligenceService().stopModelInference(_modelKey);
    } catch (_) {}
    for (final message in _messages.reversed) {
      if (message.type is AiMessageType && message.isStreaming) {
        message.isStreaming = false;
        break;
      }
    }
    _isGenerating = false;
    notifyListeners();
  }

  Future<String> _buildSearchContext(List<SearchResult> results) async {
    if (results.isEmpty) return '';
    final contexts = <String>[];
    for (final result in results) {
      try {
        final chunks = await WebSearchService.instance.extractContent(
          result.url,
          maxChunks: 1,
        );
        if (chunks.isNotEmpty) {
          contexts.add(
            'Source: ${result.title} (${result.url})\nContent: ${chunks.join(' ... ')}',
          );
        }
      } catch (_) {
        contexts.add(
          'Source: ${result.title} (${result.url})\nSnippet: ${result.snippet}',
        );
      }
    }
    if (contexts.isEmpty) return '';
    return '${AppPrompts.webSearchRAGInjection}\n\n${contexts.join('\n\n---\n\n')}';
  }

  String _mapModelError(Object error) {
    if (error is DataSapienException) {
      switch (error.message) {
        case 'contextSizeLimitExeeded':
          return 'Message length limit exceeded. Please start a new chat.';
        case 'couldNotInitializeContext':
          return 'Could not initialize model context. Please retry.';
        case 'decodingError':
          return 'Could not decode model output. Please retry.';
        case 'emptyMessageArray':
          return 'Message array was empty.';
        default:
          return error.message;
      }
    }
    return error.toString();
  }

  Future<void> _inferUserData(String text) async {
    if (!await _shouldAutoLearn()) return;
    final regex = RegExp(AppPrompts.memoryTriggerRegex, caseSensitive: false);
    if (!regex.hasMatch(text)) return;

    final memoryMessage = ChatMessage(
      id: 'msg_memory_${DateTime.now().millisecondsSinceEpoch}',
      type: const MemoryUpdateMessageType(),
      text: 'Thinking...',
    );
    _messages.add(memoryMessage);
    notifyListeners();

    try {
      final definitions = await DataSapien.getMeDataService()
          .getMeDataDefinitionsByCategory('inference');
      var definitionsContext = '';
      if (definitions != null && definitions.isNotEmpty) {
        final buffer = StringBuffer(
          '\nIf the user fact matches any of these exact categories, use its name as the JSON key:\n',
        );
        for (final def in definitions) {
          buffer.writeln(
            '- Name: ${def.name}\n  Description: ${def.description ?? "No description available"}\n',
          );
        }
        definitionsContext = buffer.toString();
      }

      final prompts = [
        Prompt(role: PromptRole.system, content: AppPrompts.memoryExtraction),
        Prompt(
          role: PromptRole.user,
          content: '$definitionsContext\nMessage: "$text" ->',
        ),
      ];

      final raw = await DataSapien.getIntelligenceService().invokeModel(
        _modelKey,
        prompts,
        inferenceParams: _settings.getInferenceParamsForMemoryExtraction(),
      );
      final pairs = _parseInferencePairs(raw);
      if (pairs.isEmpty) return;

      var inferenceIndex = 0;
      for (final pair in pairs) {
        final isPredefined = await _isInferenceKeyPredefined(pair.key);
        _pendingInferences.add(
          PendingInference(
            id:
                'inf_${DateTime.now().microsecondsSinceEpoch}_$inferenceIndex',
            key: pair.key,
            value: pair.value,
            isPredefined: isPredefined,
          ),
        );
        inferenceIndex++;
      }
      notifyListeners();
    } catch (_) {
      // Ignore inference failures and continue the main response.
    } finally {
      _messages.removeWhere((m) => m.id == memoryMessage.id);
      notifyListeners();
    }
  }

  Future<void> _handleAppOpener(String text) async {
    final lower = text.toLowerCase();
    const keywords = ['open', 'launch'];
    if (!keywords.any((k) => lower.contains(k))) return;

    final appsContext = await _fetchInstalledAppsContext();
    if (appsContext.isEmpty) return;

    final memoryMessage = ChatMessage(
      id: 'msg_appopener_${DateTime.now().millisecondsSinceEpoch}',
      type: const MemoryUpdateMessageType(),
      text: 'Thinking...',
    );
    _messages.add(memoryMessage);
    notifyListeners();

    try {
      final prompts = [
        Prompt(role: PromptRole.system, content: AppPrompts.appOpenerDecision),
        Prompt(
          role: PromptRole.user,
          content: 'Message: "$text"\nInstalled Apps:\n$appsContext',
        ),
      ];
      final response = await DataSapien.getIntelligenceService().invokeModel(
        _modelKey,
        prompts,
        inferenceParams: _settings.getInferenceParamsForMemoryExtraction(),
      );
      final app = _parseAppOpenerResponse(response);
      if (app != null) {
        await _tryLaunchAppScheme(app.scheme);
      }
    } catch (_) {
      // Continue to main response if opener LLM fails.
    } finally {
      _messages.removeWhere((m) => m.id == memoryMessage.id);
      notifyListeners();
    }
  }

  Future<String> _fetchInstalledAppsContext() async {
    try {
      final record = await DataSapien.getMeDataService()
          .getLastMeDataRecord('installed_apps');
      if (record == null || record.values.isEmpty) return '';
      return record.values.map((e) => '- ${e.value}').join('\n');
    } catch (_) {
      return '';
    }
  }

  _AppOpenerResult? _parseAppOpenerResponse(String response) {
    var cleanJson = response.trim();
    if (cleanJson.startsWith('```')) {
      final lines = cleanJson.split('\n');
      if (lines.length >= 2) {
        final endTrimmed = lines.last.trim();
        final middle = lines.sublist(
          1,
          endTrimmed == '```' ? lines.length - 1 : lines.length,
        );
        cleanJson = middle.join('\n').trim();
      }
    }
    try {
      final decoded = jsonDecode(cleanJson);
      if (decoded is! Map) return null;
      final shouldOpen = decoded['shouldOpen'];
      if (shouldOpen is! bool || !shouldOpen) return null;
      final appName = decoded['appName'] is String
          ? decoded['appName'] as String
          : '';
      final schemeRaw = decoded['scheme'];
      var scheme = schemeRaw != null ? '$schemeRaw' : appName;
      if (scheme == 'null' || scheme.isEmpty) return null;
      return _AppOpenerResult(scheme: scheme, appName: appName);
    } catch (_) {
      return null;
    }
  }

  Future<void> _tryLaunchAppScheme(String scheme) async {
    final trimmed = scheme.trim();
    if (trimmed.isEmpty) return;

    Future<bool> tryOpen(String urlStr) async {
      final uri = Uri.tryParse(urlStr);
      if (uri == null) return false;
      try {
        return await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } catch (_) {
        return false;
      }
    }

    if (await tryOpen(trimmed)) return;
    final withProto = trimmed.contains('://') ? trimmed : '$trimmed://';
    await tryOpen(withProto);
  }

  Future<bool> _isInferenceKeyPredefined(String key) async {
    try {
      final definition =
          await DataSapien.getMeDataService().getMeDataDefinition(key);
      return definition != null;
    } catch (_) {
      return false;
    }
  }

  List<_InferencePair> _parseInferencePairs(String raw) {
    var clean = raw.trim();
    if (clean.startsWith('```')) {
      final lines = clean.split('\n');
      if (lines.length >= 2) {
        final endTrimmed = lines.last.trim();
        final middle = lines.sublist(
            1, endTrimmed == '```' ? lines.length - 1 : lines.length);
        clean = middle.join('\n').trim();
      }
    }
    if (clean == '[]' || clean == '{}') return const [];
    final decoded = jsonDecode(clean);
    if (decoded is! List) return const [];
    final pairs = <_InferencePair>[];
    for (final item in decoded) {
      if (item is! Map) continue;
      final key = '${item['key'] ?? ''}'.trim();
      final valueRaw = item['value'];
      if (key.isEmpty || valueRaw == null) continue;
      void addValue(String value) {
        final cleaned = value
            .trim()
            .trimLeft()
            .trim()
            .replaceAll(RegExp("^[()\\[\\]{}\"']+|[()\\[\\]{}\"']+\$"), '')
            .trim();
        if (cleaned.isNotEmpty &&
            cleaned.toLowerCase() != 'null' &&
            cleaned.toLowerCase() != 'nil') {
          pairs.add(_InferencePair(key: key, value: cleaned));
        }
      }

      if (valueRaw is List) {
        for (final each in valueRaw) {
          addValue('$each');
        }
      } else if (valueRaw is String && valueRaw.contains(',')) {
        for (final each in valueRaw.split(',')) {
          addValue(each);
        }
      } else {
        addValue('$valueRaw');
      }
    }
    return pairs;
  }

  Future<void> approveInference(PendingInference pending) async {
    final meDataService = DataSapien.getMeDataService();
    if (pending.isPredefined) {
      await meDataService.saveMeDataRecord(pending.key, pending.value);
    } else {
      var current = <Map<String, String>>[];
      try {
        final record =
            await meDataService.getLastMeDataRecord('user_inferred_data');
        final jsonString = record?.values.isNotEmpty == true
            ? record!.values.first.value.toString()
            : '';
        if (jsonString.isNotEmpty) {
          final decoded = jsonDecode(jsonString);
          if (decoded is List) {
            current = decoded
                .whereType<Map>()
                .map(
                  (e) => {
                    'key': '${e['key'] ?? ''}',
                    'value': '${e['value'] ?? ''}',
                  },
                )
                .where((e) => e['key']!.isNotEmpty && e['value']!.isNotEmpty)
                .toList();
          }
        }
      } catch (_) {}

      final duplicate = current.any(
        (item) => item['key'] == pending.key && item['value'] == pending.value,
      );
      if (!duplicate) {
        current.add({'key': pending.key, 'value': pending.value});
        await meDataService.saveMeDataRecord(
          'user_inferred_data',
          jsonEncode(current),
        );
      }
    }
    try {
      await DataSapien.getJourneyService().syncJourneys();
    } catch (_) {}
  }

  void rejectInference(PendingInference pending) {
    // Intentionally no-op; user rejected saving this inference.
  }

  Future<String?> _fetchMyDataContext() async {
    if (!await _shouldUseMemories()) return null;
    final meDataService = DataSapien.getMeDataService();
    final lines = <String>[];

    try {
      final custom =
          await meDataService.getLastMeDataRecord('user_inferred_data');
      if (custom?.values.isNotEmpty == true) {
        final decoded = jsonDecode(custom!.values.first.value.toString());
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map && item['key'] != null && item['value'] != null) {
              final k = item['key'].toString();
              final cap = k.isEmpty
                  ? k
                  : '${k[0].toUpperCase()}${k.substring(1)}';
              lines.add('- $cap: ${item['value']}');
            }
          }
        }
      }
    } catch (_) {}

    try {
      final sections =
          await MeDataCategoryLoader.loadProfileSections(meDataService);
      final block = MeDataCategoryLoader.formatSectionsForPrompt(sections);
      if (block.isNotEmpty) {
        lines.add(block);
      }
    } catch (_) {}

    if (lines.isEmpty) return null;
    return '${AppPrompts.myDataInjection}\n\n${lines.join('\n')}';
  }

  Future<bool> _shouldUseMemories() async {
    try {
      final record = await DataSapien.getMeDataService().getLastMeDataRecord(
        AppConstants.meDataKeys.useMemories,
      );
      final rawValue =
          record?.values.isNotEmpty == true ? record!.values.first.value : '';
      return bool.tryParse(rawValue) ?? true;
    } catch (_) {
      return true;
    }
  }

  Future<bool> _shouldAutoLearn() async {
    try {
      final record = await DataSapien.getMeDataService().getLastMeDataRecord(
        AppConstants.meDataKeys.autoLearn,
      );
      final rawValue =
          record?.values.isNotEmpty == true ? record!.values.first.value : '';
      return bool.tryParse(rawValue) ?? true;
    } catch (_) {
      return true;
    }
  }
}

class PendingInference {
  PendingInference({
    required this.id,
    required this.key,
    required this.value,
    required this.isPredefined,
  });

  final String id;
  final String key;
  final String value;
  final bool isPredefined;
}

class _AppOpenerResult {
  const _AppOpenerResult({required this.scheme, required this.appName});

  final String scheme;
  final String appName;
}

class _InferencePair {
  const _InferencePair({required this.key, required this.value});
  final String key;
  final String value;
}

import 'package:datasapien_sdk/datasapien_sdk.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../l10n/app_localizations.dart';
import '../../models/chat_session.dart';
import '../../services/badge_manager.dart';
import '../../services/document_parser.dart';
import '../../services/document_scanner_service.dart';
import '../../services/history_manager.dart';
import '../../services/model_download_manager.dart';
import '../../theme/app_color.dart';
import '../../viewmodels/main_chat_view_model.dart';
import '../../widgets/chat/cells/chat_message_cell.dart';
import '../../widgets/chat/chat_bottom_input.dart';
import '../../widgets/chat/inference_pending_toast.dart';
import '../../widgets/chat/chat_top_bar.dart';
import '../../widgets/chat/empty_chat_state.dart';
import '../../widgets/sheets/attachment_sheet.dart';
import '../../widgets/sheets/model_selector_sheet.dart';
import '../../widgets/sheets/system_ui_sheet_scope.dart';
import 'chat_history_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';

/// Main chat screen shell: top bar, message area (or empty state), bottom input.
/// History opens ChatHistoryScreen; session selection loads that session's messages.
class MainChatScreen extends StatefulWidget {
  const MainChatScreen({super.key});

  @override
  State<MainChatScreen> createState() => _MainChatScreenState();
}

class _MainChatScreenState extends State<MainChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final MainChatViewModel _viewModel = MainChatViewModel.instance;
  final ModelDownloadManagerDataSource _modelSource =
      ModelDownloadManagerDataSource(registerAsPrimary: true);
  int _profileBadgeCount = 0;
  bool _isWebSearchEnabled = false;
  bool _shouldAutoFollow = true;
  bool _showJumpToLatest = false;
  int _lastMessageCount = 0;
  int _lastStreamingSignature = 0;
  String? _draftAttachmentName;
  String? _draftAttachmentContent;
  String? _draftImagePath;
  ImageProvider? _draftImageThumbnail;
  bool _isProcessingAttachment = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelChanged);
    _scrollController.addListener(_onScrollChanged);
    _modelSource.addListener(_onModelSourceChanged);
    ModelDownloadManager.instance.onDownloadSucceeded =
        _onModelDownloadSucceeded;
    ModelDownloadManager.instance.onDownloadFailed = _onModelDownloadFailed;
    _initHistory();
    _modelSource.load();
    _viewModel.loadAndSyncModel();
    BadgeManager.instance.addListener(_onBadgeManagerChanged);
    _updateProfileBadge();
  }

  void _onBadgeManagerChanged() {
    _updateProfileBadge();
  }

  void _onModelDownloadSucceeded(String modelName) {
    MainChatViewModel.instance.onModelDownloadComplete(modelName);
  }

  void _onModelDownloadFailed(String modelName, Object error) {
    if (!mounted) return;
    final loc = AppLocalizations.of(context)!;
    final detail =
        error is DataSapienException ? error.message : error.toString();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${loc.model_download_failed} ($modelName): $detail'),
      ),
    );
  }

  @override
  void dispose() {
    BadgeManager.instance.removeListener(_onBadgeManagerChanged);
    ModelDownloadManager.instance.onDownloadSucceeded = null;
    ModelDownloadManager.instance.onDownloadFailed = null;
    _viewModel.removeListener(_onViewModelChanged);
    _scrollController.removeListener(_onScrollChanged);
    _modelSource.removeListener(_onModelSourceChanged);
    _modelSource.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (!mounted) return;
    final currentMessageCount = _viewModel.messages.length;
    final currentStreamingSignature = _computeStreamingSignature();
    final hasNewMessage = currentMessageCount > _lastMessageCount;
    final hasStreamingProgress =
        currentStreamingSignature != _lastStreamingSignature;
    final shouldFollowNow = _shouldAutoFollow || hasNewMessage;

    setState(() {});
    if ((hasNewMessage || hasStreamingProgress) && shouldFollowNow) {
      _scrollToBottom(animated: !hasStreamingProgress);
    }
    _lastMessageCount = currentMessageCount;
    _lastStreamingSignature = currentStreamingSignature;
  }

  void _onScrollChanged() {
    if (!_scrollController.hasClients) return;
    final nearBottom = _isNearBottom();
    if (_shouldAutoFollow != nearBottom ||
        _showJumpToLatest != (!nearBottom && _viewModel.messages.isNotEmpty)) {
      setState(() {
        _shouldAutoFollow = nearBottom;
        _showJumpToLatest = !nearBottom && _viewModel.messages.isNotEmpty;
      });
    }
  }

  int _computeStreamingSignature() {
    var signature = 0;
    for (final message in _viewModel.messages) {
      if (message.isStreaming) {
        signature += message.text.length;
      }
    }
    return signature;
  }

  bool _isNearBottom() {
    if (!_scrollController.hasClients) return true;
    final position = _scrollController.position;
    return (position.maxScrollExtent - position.pixels) <= 120;
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void _onModelSourceChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _initHistory() async {
    await HistoryManager.instance.ensureInitialized();
    // No session creation or loading on launch — matches iOS: empty state until user sends or picks from history
  }

  Future<void> _updateProfileBadge() async {
    try {
      final journeyService = DataSapien.getJourneyService();
      final list = await journeyService.getJourneys(
        tags: ['ai'],
        statuses: [
          JourneyStatus.notStarted,
          JourneyStatus.completed,
        ],
        onlyInAudience: true,
      );
      final count =
          await BadgeManager.instance.calculateUnreadJourneysCount(list);
      if (mounted) setState(() => _profileBadgeCount = count);
    } catch (_) {}
  }

  Future<void> _openHistory() async {
    final session = await showModalBottomSheet<ChatSession?>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      showDragHandle: true,
      builder: (_) => const SystemUiSheetScope(
        child: _ChatHistoryDraggableSheet(),
      ),
    );
    if (!mounted || session == null) return;
    await _viewModel.loadSession(session);
    _scrollToBottom(animated: false);
  }

  Future<void> _openSettings() async {
    final didChangeModelParams = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      showDragHandle: true,
      builder: (sheetContext) {
        final height = MediaQuery.sizeOf(sheetContext).height * 0.93;
        return SystemUiSheetScope(
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: SizedBox(
              height: height,
              child: Material(
                color: AppColor.primaryBackground(sheetContext),
                child: Navigator(
                  initialRoute: '/',
                  onGenerateRoute: (routeSettings) {
                    return MaterialPageRoute<bool>(
                      settings: routeSettings,
                      builder: (_) => const SettingsScreen(),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
    if (didChangeModelParams == true && mounted) {
      _viewModel.loadAndSyncModel();
    }
  }

  Future<void> _openProfileSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      showDragHandle: true,
      builder: (_) {
        return SystemUiSheetScope(
          child: DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.5,
            maxChildSize: 0.98,
            expand: false,
            builder: (context, scrollController) {
              return ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                child: Material(
                  color: AppColor.primaryBackground(context),
                  child: ProfileScreen(
                    initialJourneyUnreadCount: _profileBadgeCount,
                    isSheetMode: true,
                    scrollController: scrollController,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
    if (mounted) {
      await _updateProfileBadge();
    }
  }

  void _openModelSelectorSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SystemUiSheetScope(
        child: ModelSelectorSheet(
          source: _modelSource,
          onSelect: (name, state) {
            _viewModel.loadAndSyncModel();
          },
        ),
      ),
    );
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final target = _scrollController.position.maxScrollExtent;
        if (animated) {
          _scrollController.animateTo(
            target,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(target);
        }
      }
    });
  }

  Future<void> _onSend(String text) async {
    _dismissKeyboard();
    if (!_shouldAutoFollow || _showJumpToLatest) {
      setState(() {
        _shouldAutoFollow = true;
        _showJumpToLatest = false;
      });
    }
    final attachmentName = _draftAttachmentName;
    final attachmentContent = _draftAttachmentContent;
    final imagePath = _draftImagePath;
    if (attachmentName != null || attachmentContent != null || imagePath != null) {
      setState(() {
        _draftAttachmentName = null;
        _draftAttachmentContent = null;
        _draftImagePath = null;
        _draftImageThumbnail = null;
      });
    }
    await _viewModel.sendMessage(
      text,
      isWebSearchEnabled: _isWebSearchEnabled,
      attachmentName: attachmentName,
      attachmentContent: attachmentContent,
      imagePath: imagePath,
    );
    _scrollToBottom();
  }

  void _onRemoveDraftAttachment() {
    if (_draftAttachmentName == null &&
        _draftAttachmentContent == null &&
        _draftImagePath == null) {
      return;
    }
    setState(() {
      _draftAttachmentName = null;
      _draftAttachmentContent = null;
      _draftImagePath = null;
      _draftImageThumbnail = null;
    });
  }

  Future<void> _onAttach() async {
    if (_isProcessingAttachment) return;
    _dismissKeyboard();
    final action = await AttachmentSheet.showWithImageOption(
      context,
      showImageOption: _viewModel.isCurrentModelMultimodal,
    );
    if (!mounted || action == null) return;
    switch (action) {
      case AttachmentAction.documents:
        await _handleDocumentPick();
      case AttachmentAction.scanText:
        await _handleScanText();
      case AttachmentAction.image:
        await _handleImagePick();
    }
  }

  Future<void> _handleDocumentPick() async {
    final loc = AppLocalizations.of(context)!;
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withData: false,
      );
      if (!mounted) return;
      final path = result?.files.single.path;
      if (path == null) return;
      final filename = result!.files.single.name;
      setState(() => _isProcessingAttachment = true);
      try {
        final parsed = await DocumentParser.extractText(path);
        if (!mounted) return;
        setState(() {
          _draftAttachmentName = filename;
          _draftAttachmentContent = parsed;
        });
      } on DocumentParserException {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.attachment_document_parse_failed)),
        );
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.attachment_document_parse_failed)),
        );
      } finally {
        if (mounted) setState(() => _isProcessingAttachment = false);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.attachment_document_parse_failed)),
      );
    }
  }

  Future<void> _handleScanText() async {
    final loc = AppLocalizations.of(context)!;
    if (!DocumentScannerService.isSupported) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.attachment_scanner_unsupported)),
      );
      return;
    }
    setState(() => _isProcessingAttachment = true);
    try {
      final extracted = await DocumentScannerService.scanAndRecognize();
      if (!mounted) return;
      if (extracted == null || extracted.isEmpty) return;
      setState(() {
        _draftAttachmentName = 'Scanned Document.txt';
        _draftAttachmentContent = extracted;
      });
    } on DocumentScannerException catch (e) {
      if (!mounted) return;
      final msg = switch (e.reason) {
        DocumentScannerError.permissionDenied =>
          loc.attachment_scanner_permission_denied,
        DocumentScannerError.unsupported => loc.attachment_scanner_unsupported,
        DocumentScannerError.failed => loc.attachment_scanner_failed,
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.attachment_scanner_failed)),
      );
    } finally {
      if (mounted) setState(() => _isProcessingAttachment = false);
    }
  }

  Future<void> _handleImagePick() async {
    final loc = AppLocalizations.of(context)!;
    setState(() => _isProcessingAttachment = true);
    try {
      final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (!mounted) return;
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.attachment_document_parse_failed)),
        );
        return;
      }

      const maxDimension = 768;
      final longest = decoded.width > decoded.height ? decoded.width : decoded.height;
      final resized = longest > maxDimension
          ? img.copyResize(
              decoded,
              width: decoded.width >= decoded.height ? maxDimension : null,
              height: decoded.height > decoded.width ? maxDimension : null,
              interpolation: img.Interpolation.average,
            )
          : decoded;

      final jpg = img.encodeJpg(resized, quality: 80);
      final tempDir = await getTemporaryDirectory();
      final filename = 'image_${DateTime.now().microsecondsSinceEpoch}.jpg';
      final outPath = p.join(tempDir.path, filename);
      await File(outPath).writeAsBytes(jpg, flush: true);

      final thumb = img.copyResize(resized, width: 32, height: 32, interpolation: img.Interpolation.average);
      final thumbJpg = img.encodeJpg(thumb, quality: 70);

      setState(() {
        _draftAttachmentName = null;
        _draftAttachmentContent = null;
        _draftImagePath = outPath;
        _draftImageThumbnail = MemoryImage(thumbJpg);
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.attachment_document_parse_failed)),
      );
    } finally {
      if (mounted) setState(() => _isProcessingAttachment = false);
    }
  }

  void _onStop() {
    _viewModel.stopInference();
  }

  void _onSendWithoutModel() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.model_not_ready_warning),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onCopyAi(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.copied_to_clipboard),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _modelNameLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = _viewModel.modelState.toLowerCase();
    if (state == 'loading') return l10n.chat_model_loading;
    if (state == 'downloading') return l10n.chat_model_downloading;
    if (_viewModel.currentModelName.isEmpty) return l10n.select_model;
    return _viewModel.currentModelName;
  }

  String _effectiveModelState() {
    final name = _viewModel.currentModelName;
    if (name.isNotEmpty && _modelSource.isDownloading(name)) {
      return 'downloading';
    }
    return _viewModel.modelState;
  }

  double? _effectiveModelProgress() {
    final name = _viewModel.currentModelName;
    if (name.isEmpty) return null;
    return _modelSource.progressFor(name);
  }

  Future<void> _onInferenceResolved(
    PendingInference pending,
    bool approved,
  ) async {
    if (!mounted) return;
    if (approved) {
      await _viewModel.approveInference(pending);
    } else {
      _viewModel.rejectInference(pending);
    }
    _viewModel.removePendingInference(pending);
    if (mounted) await _updateProfileBadge();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            ChatTopBar(
              onHistory: _openHistory,
              onNewChat: _viewModel.clearSession,
              onModel: _openModelSelectorSheet,
              onSettings: _openSettings,
              onProfile: _openProfileSheet,
              badgeCount: _profileBadgeCount,
              modelName: _modelNameLabel(context),
              modelState: _effectiveModelState(),
              modelProgress: _effectiveModelProgress(),
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _dismissKeyboard,
                child: Stack(
                  children: [
                    _viewModel.messages.isEmpty
                        ? const EmptyChatState()
                        : ListView.builder(
                            controller: _scrollController,
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            itemCount: _viewModel.messages.length,
                            itemBuilder: (context, index) {
                              final message = _viewModel.messages[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: buildChatMessageCell(
                                  context,
                                  message: message,
                                  onCopyAi: _onCopyAi,
                                  onShareAi: (text) => SharePlus.instance.share(
                                    ShareParams(text: text),
                                  ),
                                ),
                              );
                            },
                          ),
                    if (_showJumpToLatest)
                      Positioned(
                        right: 16,
                        bottom: 12,
                        child: FloatingActionButton.small(
                          onPressed: () {
                            setState(() {
                              _shouldAutoFollow = true;
                              _showJumpToLatest = false;
                            });
                            _scrollToBottom();
                          },
                          backgroundColor: AppColor.primaryTint,
                          foregroundColor: Colors.white,
                          child: const Icon(Icons.keyboard_arrow_down_rounded),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: InferencePendingToastStack(
                pending: _viewModel.pendingInferences,
                onResolved: _onInferenceResolved,
              ),
            ),
            ChatBottomInput(
              onSend: _onSend,
              onStop: _onStop,
              onToggleWebSearch: (enabled) {
                setState(() => _isWebSearchEnabled = enabled);
              },
              onAttach: _isProcessingAttachment ? null : _onAttach,
              onRemoveDraftAttachment: _onRemoveDraftAttachment,
              draftAttachmentName: _draftAttachmentName,
              draftImageThumbnail: _draftImageThumbnail,
              isWebSearchEnabled: _isWebSearchEnabled,
              isGenerating: _viewModel.isGenerating,
              isModelReady: _viewModel.isModelReady,
              onSendWhenModelNotReady: _onSendWithoutModel,
            ),
          ],
        ),
      ),
    );
  }
}

/// Owns [DraggableScrollableController] so the history sheet can expand to full
/// height while searching (keyboard no longer covers the list).
class _ChatHistoryDraggableSheet extends StatefulWidget {
  const _ChatHistoryDraggableSheet();

  @override
  State<_ChatHistoryDraggableSheet> createState() =>
      _ChatHistoryDraggableSheetState();
}

class _ChatHistoryDraggableSheetState
    extends State<_ChatHistoryDraggableSheet> {
  final DraggableScrollableController _extent = DraggableScrollableController();

  @override
  void dispose() {
    _extent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _extent,
      initialChildSize: 0.5,
      minChildSize: 0.5,
      maxChildSize: 1.0,
      expand: false,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: ChatHistoryScreen(
            scrollController: scrollController,
            sheetExtentController: _extent,
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/chat_session.dart';
import '../../services/history_manager.dart';
import '../../theme/app_color.dart';
import '../../theme/app_icons.dart';
import '../../widgets/chat/cells/chat_history_cell.dart';

/// Chat history screen: list of sessions (title + date), tap to open in main chat, delete sessions.
class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({
    super.key,
    this.scrollController,
    this.sheetExtentController,
  });

  final ScrollController? scrollController;

  /// When set, the parent sheet expands to full height while search is focused
  /// or the query is non-empty so the keyboard does not cover the list.
  final DraggableScrollableController? sheetExtentController;

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  List<ChatSession> _sessions = [];
  List<ChatSession> _filteredSessions = [];
  final HistoryManager _history = HistoryManager.instance;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  int _filterEpoch = 0;
  bool _searchFocused = false;

  static const Duration _sheetExtentDuration = Duration(milliseconds: 280);
  static const Curve _sheetExtentCurve = Curves.easeOutCubic;

  void _syncHistorySheetExtent() {
    final c = widget.sheetExtentController;
    if (c == null) return;

    void apply() {
      if (!c.isAttached) return;
      final expand = _searchFocused || _query.trim().isNotEmpty;
      final target = expand ? 1.0 : 0.5;
      c.animateTo(
        target,
        duration: _sheetExtentDuration,
        curve: _sheetExtentCurve,
      );
    }

    if (c.isAttached) {
      apply();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) apply();
      });
    }
  }

  Future<void> _loadSessions() async {
    await HistoryManager.instance.ensureInitialized();
    final list = await _history.fetchAllSessions();
    if (!mounted) return;
    setState(() => _sessions = list);
    await _applyFilter();
  }

  @override
  void initState() {
    super.initState();
    _loadSessions();
    _history.addListener(_onHistoryChanged);
  }

  @override
  void dispose() {
    _history.removeListener(_onHistoryChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onHistoryChanged() {
    _loadSessions();
  }

  Future<void> _applyFilter() async {
    final epoch = ++_filterEpoch;
    final normalized = _query.trim().toLowerCase();
    if (normalized.isEmpty) {
      if (!mounted || epoch != _filterEpoch) return;
      setState(() => _filteredSessions = _sessions);
      return;
    }

    final messageMatchedIds = await _history.searchSessionIdsByMessageText(
      normalized,
    );
    if (!mounted || epoch != _filterEpoch) return;
    setState(() {
      _filteredSessions = _sessions.where((session) {
        final titleMatch = session.title.toLowerCase().contains(normalized);
        return titleMatch || messageMatchedIds.contains(session.id);
      }).toList();
    });
  }

  void _onSearchChanged(String value) {
    _query = value;
    _syncHistorySheetExtent();
    _applyFilter();
  }

  void _onSessionTap(ChatSession session) {
    Navigator.of(context).pop<ChatSession>(session);
  }

  Future<void> _onDelete(ChatSession session) async {
    await _history.deleteSession(session);
    if (!mounted) return;
    setState(() {
      _sessions.removeWhere((s) => s.id == session.id);
      _filteredSessions.removeWhere((s) => s.id == session.id);
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.chat_deleted),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasQuery = _query.trim().isNotEmpty;
    final isEmpty = _sessions.isEmpty;
    final noMatches = !isEmpty && hasQuery && _filteredSessions.isEmpty;
    final visibleSessions = hasQuery ? _filteredSessions : _sessions;

    final keyboardBottom = MediaQuery.viewInsetsOf(context).bottom;

    return Material(
      color: AppColor.primaryBackground(context),
      child: Padding(
        padding: EdgeInsets.only(bottom: keyboardBottom),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      AppIcons.xmark,
                      color: AppColor.textSecondary(context),
                    ),
                    onPressed: () =>
                        Navigator.of(context).pop<ChatSession?>(null),
                  ),
                  Expanded(
                    child: Text(
                      l10n.history_title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColor.textPrimary(context),
                          ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            if (!isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Focus(
                  onFocusChange: (hasFocus) {
                    _searchFocused = hasFocus;
                    _syncHistorySheetExtent();
                  },
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => FocusScope.of(context).unfocus(),
                    decoration: InputDecoration(
                      hintText: l10n.history_search_placeholder,
                      prefixIcon: const Icon(AppIcons.search),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                              icon: const Icon(AppIcons.xmark),
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
            Expanded(
              child: isEmpty || noMatches
                  ? Center(
                      child: Text(
                        isEmpty
                            ? l10n.history_no_chats
                            : l10n.history_no_matching_chats,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColor.textSecondary(context),
                            ),
                      ),
                    )
                  : ListView.builder(
                      controller: widget.scrollController,
                      padding: const EdgeInsets.only(top: 8, bottom: 20),
                      itemCount: visibleSessions.length,
                      itemBuilder: (context, index) {
                        final session = visibleSessions[index];
                        return Dismissible(
                          key: ValueKey(session.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              AppIcons.trash,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            return true;
                          },
                          onDismissed: (direction) {
                            _onDelete(session);
                          },
                          child: ChatHistoryCell(
                            session: session,
                            onTap: () => _onSessionTap(session),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

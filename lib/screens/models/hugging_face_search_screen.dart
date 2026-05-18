import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/hugging_face_service.dart';
import '../../theme/app_color.dart';
import '../../theme/app_font.dart';
import '../../widgets/sheets/system_ui_sheet_scope.dart';

class HuggingFaceSearchScreen extends StatefulWidget {
  const HuggingFaceSearchScreen({super.key});

  static const int _pageSize = 20;

  @override
  State<HuggingFaceSearchScreen> createState() => _HuggingFaceSearchScreenState();
}

class _HuggingFaceSearchScreenState extends State<HuggingFaceSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _loading = false;
  bool _loadingMore = false;
  bool _hasSearched = false;
  bool _searchFailed = false;
  bool _hasMore = true;
  int _apiOffset = 0;
  String _currentQuery = '';
  List<HuggingFaceModelSummary> _results = const [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _loading || _loadingMore || _currentQuery.isEmpty) return;
    if (_results.isEmpty) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _search({bool reset = true}) async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;
    if (_loading || _loadingMore) return;

    if (reset) {
      setState(() {
        _loading = true;
        _loadingMore = false;
        _currentQuery = query;
        _hasSearched = true;
        _searchFailed = false;
        _results = const [];
        _apiOffset = 0;
        _hasMore = true;
      });
    }

    final page = await HuggingFaceService.instance.searchModels(
      query,
      offset: _apiOffset,
      limit: HuggingFaceSearchScreen._pageSize,
    );
    if (!mounted) return;

    if (page.failed) {
      if (reset) {
        setState(() {
          _loading = false;
          _searchFailed = true;
          _results = const [];
        });
      } else {
        setState(() => _loadingMore = false);
        final loc = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.hfSearchError)),
        );
      }
      return;
    }

    setState(() {
      if (reset) {
        _loading = false;
        _results = List<HuggingFaceModelSummary>.from(page.models);
      } else {
        _loadingMore = false;
        _results = [..._results, ...page.models];
      }
      _apiOffset += page.rawResultCount;
      _hasMore = page.rawResultCount >= HuggingFaceSearchScreen._pageSize;
    });
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _loading || _loadingMore || _currentQuery.isEmpty) return;
    setState(() => _loadingMore = true);
    await _search(reset: false);
  }

  Future<void> _openModelFiles(HuggingFaceModelSummary model) async {
    final loc = AppLocalizations.of(context)!;
    final list = await HuggingFaceService.instance.fetchGgufFiles(model.id);
    if (!mounted) return;
    if (list.requestFailed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.hfFileLoadError)),
      );
      return;
    }
    if (list.files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.hfNoGgufFiles)),
      );
      return;
    }
    final picked = await showModalBottomSheet<HuggingFaceModelFile>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SystemUiSheetScope(
          child: ListView(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  loc.hfSelectFile,
                  style: AppFont.h3
                      .copyWith(color: AppColor.textPrimary(sheetContext)),
                ),
              ),
              for (var i = 0; i < list.files.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                ListTile(
                  title: Text(list.files[i].path),
                  subtitle: Text(_sizeLabel(list.files[i].sizeBytes)),
                  trailing: FilledButton(
                    onPressed: () =>
                        Navigator.of(sheetContext).pop(list.files[i]),
                    child: Text(loc.hfAddButton),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
    if (picked == null || !mounted) return;

    setState(() => _loading = true);
    try {
      await HuggingFaceService.instance.addManagedModel(modelId: model.id, file: picked);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.hf_model_added_toast)),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(content: Text('${loc.hf_model_save_failed}: $e')),
      );
      setState(() => _loading = false);
    }
  }

  String _sizeLabel(int bytes) {
    if (bytes <= 0) return 'Unknown size';
    final gb = bytes / 1073741824;
    if (gb >= 1) return '${gb.toStringAsFixed(1)} GB';
    return '${(bytes / 1048576).toStringAsFixed(0)} MB';
  }

  String _emptyCenterMessage(AppLocalizations loc) {
    if (!_hasSearched) return loc.hfSearchIntro;
    if (_searchFailed) return loc.hfSearchError;
    if (_results.isEmpty) return loc.hfNoResults;
    return loc.hfSearchIntro;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final orange = Colors.orange;

    return Scaffold(
      backgroundColor: AppColor.primaryBackground(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Text(
          loc.hfSearchTitle,
          style: AppFont.h3.copyWith(color: AppColor.textPrimary(context)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: orange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 18, color: orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        loc.hfWarningUntested,
                        style: AppFont.body.copyWith(
                          color: orange,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: loc.hfSearchPlaceholder,
                      border: const OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _search(reset: true),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: (_loading || _loadingMore) ? null : () => _search(reset: true),
                  child: Text(loc.hfSearchAction),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: _results.isEmpty && !_loadingMore
                    ? Center(
                        child: Text(
                          _emptyCenterMessage(loc),
                          textAlign: TextAlign.center,
                          style: AppFont.body.copyWith(
                            color: AppColor.textSecondary(context),
                          ),
                        ),
                      )
                    : ListView.separated(
                        controller: _scrollController,
                        itemCount: _results.length + (_loadingMore ? 1 : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          if (index >= _results.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final model = _results[index];
                          final d = HuggingFaceService.abbreviatedCount(model.downloads);
                          final l = HuggingFaceService.abbreviatedCount(model.likes);
                          return ListTile(
                            tileColor: AppColor.secondaryBackground(context),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            title: Text(model.id),
                            subtitle: Text('$d downloads • $l likes'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _openModelFiles(model),
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

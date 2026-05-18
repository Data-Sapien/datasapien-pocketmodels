import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../screens/models/hugging_face_search_screen.dart';
import '../../services/model_selector_source.dart';
import '../../theme/app_color.dart';
import '../../theme/app_font.dart';
import '../model_managed_row.dart';

/// Modal bottom sheet: list of models with download state and selection.
/// Used from main chat top bar. Selection is persisted and applied on choose.
class ModelSelectorSheet extends StatefulWidget {
  const ModelSelectorSheet({
    super.key,
    required this.onSelect,
    this.source,
  });

  /// Called when user selects a downloaded model (name, state e.g. "ready").
  final void Function(String modelName, String? modelState) onSelect;

  /// Optional; defaults to [StubModelSelectorSource].
  final ModelSelectorDataSource? source;

  @override
  State<ModelSelectorSheet> createState() => _ModelSelectorSheetState();
}

class _ModelSelectorSheetState extends State<ModelSelectorSheet> {
  late ModelSelectorDataSource _source;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _source = widget.source ?? StubModelSelectorSource();
    _source.addListener(_onSourceChanged);
    _load();
  }

  @override
  void dispose() {
    _source.removeListener(_onSourceChanged);
    super.dispose();
  }

  void _onSourceChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _source.load();
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'error';
      });
    }
  }

  Future<void> _onSelectModel(ManagedModelItem model) async {
    if (!_source.downloadedModelNames.contains(model.name)) {
      await _source.startDownload(model.name);
      return;
    }
    await _source.setCurrentModel(model.name);
    if (!mounted) return;
    widget.onSelect(model.name, 'ready');
    Navigator.of(context).pop();
  }

  void _onDownloadTap(ManagedModelItem model) {
    if (_source.downloadedModelNames.contains(model.name)) return;
    if (_source.isDownloading(model.name)) return;
    _source.startDownload(model.name);
  }

  Future<bool> _confirmAndDelete(ManagedModelItem model) async {
    final l10n = AppLocalizations.of(context)!;
    final displayName = model.resolvedDisplayTitle(l10n.default_model);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.model_delete_dialog_title),
        content: Text(l10n.model_delete_dialog_message(displayName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.model_delete_dialog_confirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return false;

    final wasCurrent = _source.currentSelectedModelName == model.name;
    try {
      await _source.deleteDownloadedModel(model.name);
      if (!mounted) return false;
      if (wasCurrent) {
        await _source.setCurrentModel('');
        widget.onSelect('', null);
      }
      return true;
    } catch (e) {
      if (!mounted) return false;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.error_title),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.ok_button),
            ),
          ],
        ),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.7;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            mainAxisSize: (_loading || _error != null)
                ? MainAxisSize.min
                : MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    l10n.select_model_sheet_title,
                    style: AppFont.h2.copyWith(
                      color: AppColor.textPrimary(context),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: AppColor.textSecondary(context),
                      size: 24,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_loading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          color: AppColor.primaryTint,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.select_model_sheet_loading,
                          style: AppFont.body.copyWith(
                            color: AppColor.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.select_model_sheet_error,
                        style: AppFont.body.copyWith(
                          color: AppColor.textSecondary(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _load,
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: _source.models.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final model = _source.models[index];
                      final downloaded = _source.downloadedModelNames
                          .contains(model.name);
                      final busy = _source.isDownloading(model.name) ||
                          _source.isQueued(model.name);
                      final row = ModelManagedRow(
                        model: model,
                        isDownloaded: downloaded,
                        isSelected:
                            _source.currentSelectedModelName == model.name,
                        isDownloading: _source.isDownloading(model.name),
                        isQueued: _source.isQueued(model.name),
                        progress: _source.progressFor(model.name),
                        onTap: () => _onSelectModel(model),
                        onDownloadTap: () => _onDownloadTap(model),
                      );
                      if (!downloaded || busy) return row;
                      return Dismissible(
                        key: ValueKey(model.name),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        confirmDismiss: (_) => _confirmAndDelete(model),
                        onDismissed: (_) {},
                        child: row,
                      );
                    },
                  ),
                ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final added = await Navigator.of(context).push<bool>(
                    MaterialPageRoute<bool>(
                      builder: (_) => const HuggingFaceSearchScreen(),
                    ),
                  );
                  if (added == true) {
                    await _load();
                  }
                },
                icon: const Icon(Icons.cloud_download_outlined),
                label: Text(l10n.hf_add_models_button),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

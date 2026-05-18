import 'package:flutter/material.dart';
import 'package:datasapien_sdk/datasapien_sdk.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../l10n/app_localizations.dart';
import '../../services/model_download_manager.dart';
import '../../services/model_selector_source.dart';
import '../../theme/app_color.dart';
import '../../theme/app_asset_icons.dart';
import '../../theme/app_font.dart';
import '../../utils/app_constants.dart';
import '../../widgets/model_managed_row.dart';

/// Third screen of onboarding: model list, selection, then Complete → main chat.
class OnboardingModelsScreen extends StatefulWidget {
  const OnboardingModelsScreen({
    super.key,
    required this.onComplete,
  });

  final VoidCallback onComplete;

  @override
  State<OnboardingModelsScreen> createState() => _OnboardingModelsScreenState();
}

class _OnboardingModelsScreenState extends State<OnboardingModelsScreen> {
  late final ModelDownloadManagerDataSource _source;
  String? _selectedModelId;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _source = ModelDownloadManagerDataSource();
    _source.addListener(_onSourceChanged);
    _load();
  }

  void _onSourceChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _source.removeListener(_onSourceChanged);
    _source.dispose();
    super.dispose();
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
        _error = 'error';
        _loading = false;
      });
    }
  }

  List<ManagedModelItem> _onboardingModels() => _source.models;

  void _select(ManagedModelItem model) {
    setState(() => _selectedModelId = model.id);
  }

  Future<void> _onContinue() async {
    final list = _onboardingModels();
    final selectedList =
        list.where((m) => m.id == _selectedModelId).toList();
    if (selectedList.isEmpty) return;
    final selected = selectedList.first;
    final modelName = selected.name;

    await _source.setCurrentModel(modelName);

    if (!_source.downloadedModelNames.contains(modelName)) {
      if (!_source.isDownloading(modelName) && !_source.isQueued(modelName)) {
        await _source.startDownload(modelName);
      }
    }

    final meDataService = DataSapien.getMeDataService();
    await meDataService.saveMeDataRecord(
      AppConstants.meDataKeys.onboardingStatus,
      AppConstants.onboardingStatus.finished,
    );

    if (!mounted) return;
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final models = _onboardingModels();
    return Scaffold(
      backgroundColor: AppColor.primaryBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                children: [
                  Text(
                    l10n.models_title,
                    style: AppFont.h2.copyWith(
                      color: AppColor.textPrimary(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.models_subtitle,
                    style: AppFont.body.copyWith(
                      color: AppColor.textSecondary(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildContent(context, l10n, models),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            AppColor.secondaryBackground(context),
                        foregroundColor: AppColor.textPrimary(context),
                        elevation: 0,
                        minimumSize: const Size.fromHeight(56),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            AppAssetIcons.mainChevronLeft,
                            width: 20,
                            height: 20,
                            fit: BoxFit.contain,
                            colorFilter: ColorFilter.mode(
                              AppColor.textPrimary(context),
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(l10n.back_button),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: _selectedModelId != null &&
                              !_loading &&
                              _error == null &&
                              models.isNotEmpty
                          ? _onContinue
                          : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColor.primaryTint,
                        foregroundColor: AppColor.buttonText,
                        minimumSize: const Size.fromHeight(56),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(l10n.continue_button),
                          const SizedBox(width: 4),
                          SvgPicture.asset(
                            AppAssetIcons.mainChevronRight,
                            width: 20,
                            height: 20,
                            fit: BoxFit.contain,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    List<ManagedModelItem> models,
  ) {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColor.primaryTint),
            const SizedBox(height: 16),
            Text(
              l10n.models_loading,
              style: AppFont.body.copyWith(
                color: AppColor.textSecondary(context),
              ),
            ),
          ],
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.models_error,
            style: AppFont.body.copyWith(
              color: AppColor.textSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (models.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.onboarding_models_empty,
            style: AppFont.body.copyWith(
              color: AppColor.textSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: models.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final model = models[index];
        final isSelected = model.id == _selectedModelId;
        return ModelManagedRow(
          model: model,
          isDownloaded: _source.downloadedModelNames.contains(model.name),
          isSelected: isSelected,
          isDownloading: _source.isDownloading(model.name),
          isQueued: _source.isQueued(model.name),
          progress: _source.progressFor(model.name),
          onTap: () => _select(model),
          onDownloadTap: () => _select(model),
        );
      },
    );
  }
}

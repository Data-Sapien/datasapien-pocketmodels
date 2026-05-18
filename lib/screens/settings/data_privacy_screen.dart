import 'package:datasapien_sdk/datasapien_sdk.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/app_preferences.dart';
import '../../services/history_manager.dart';
import '../../services/model_download_manager.dart';
import '../../services/passcode_service.dart';
import '../../theme/app_color.dart';
import '../../theme/app_font.dart';
import '../../widgets/sheets/system_ui_sheet_scope.dart';
import '../../viewmodels/main_chat_view_model.dart';
import '../passcode/passcode_screen.dart';

/// Data privacy + passcode switch (matches iOS DataPrivacySecurityViewController).
class DataPrivacyScreen extends StatefulWidget {
  const DataPrivacyScreen({super.key});

  @override
  State<DataPrivacyScreen> createState() => _DataPrivacyScreenState();
}

class _DataPrivacyScreenState extends State<DataPrivacyScreen> {
  bool _passcodeEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadPasscodeEnabled();
  }

  Future<void> _loadPasscodeEnabled() async {
    final enabled = await AppPreferences.getPasscodeEnabled();
    if (mounted) setState(() => _passcodeEnabled = enabled);
  }

  Future<void> _onPasscodeSwitchChanged(bool wantOn) async {
    if (wantOn) {
      if (!mounted) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (modalContext) => PasscodeScreen(
            mode: PasscodeMode.set,
            showCancelButton: true,
            onCancel: () => Navigator.of(modalContext).pop(),
            onSuccess: () => Navigator.of(modalContext).pop(),
          ),
        ),
      );
    } else {
      if (!mounted) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (modalContext) => PasscodeScreen(
            mode: PasscodeMode.verify,
            showCancelButton: true,
            onCancel: () => Navigator.of(modalContext).pop(),
            onSuccess: () async {
              await PasscodeService.clearPasscode();
              if (modalContext.mounted) {
                Navigator.of(modalContext).pop();
              }
            },
          ),
        ),
      );
    }
    if (mounted) await _loadPasscodeEnabled();
  }

  Future<void> _confirmDeleteAllData(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return SystemUiSheetScope(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.settings_delete_all_sheet_title,
                    style: AppFont.bodyBold.copyWith(
                      fontSize: 17,
                      color: AppColor.textPrimary(ctx),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.settings_delete_all_sheet_message,
                    style: AppFont.body.copyWith(
                      color: AppColor.textSecondary(ctx),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(l10n.settings_delete_all_sheet_destructive),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text(l10n.cancel),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (confirmed != true || !context.mounted) return;

    final rootNav = Navigator.of(context, rootNavigator: true);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text(l10n.settings_deleting_data),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                l10n.settings_deleting_data_subtitle,
                style: AppFont.caption.copyWith(
                  color: AppColor.textSecondary(ctx),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final history = HistoryManager.instance;
      final sessions = await history.fetchAllSessions();
      for (final session in sessions) {
        await history.deleteSession(session);
      }
      try {
        final meDataService = DataSapien.getMeDataService();
        final definitions = await meDataService.getMeDataDefinitions();
        for (final definition in definitions) {
          await meDataService.deleteMeData(definition.name);
        }
      } catch (_) {}
      try {
        await ModelDownloadManager.instance.deleteAllDownloadedModels();
      } catch (_) {}
      try {
        await DataSapien.getJourneyService().syncJourneys();
      } catch (_) {}
    } finally {
      if (rootNav.mounted) {
        rootNav.pop();
      }
    }

    final viewModel = MainChatViewModel.instance;
    viewModel.clearSession();
    await viewModel.loadAndSyncModel();
    await ModelDownloadManagerDataSource.refreshRegisteredPrimary();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.settings_deleted_message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColor.secondaryBackground(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColor.textPrimary(context)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.settings_privacy_screen_title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColor.textPrimary(context),
              ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          _sectionHeader(context, l10n.settings_section_data_privacy),
          Material(
            color: AppColor.primaryBackground(context),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () => _confirmDeleteAllData(context),
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: 60,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      l10n.settings_delete_all_data,
                      style: AppFont.bodyBold.copyWith(
                        fontSize: 17,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.settings_data_privacy_delete_warning,
            style: AppFont.caption.copyWith(
              color: AppColor.textSecondary(context).withValues(alpha: 0.6),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 24),
          _sectionHeader(context, l10n.settings_section_security),
          Material(
            color: AppColor.primaryBackground(context),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F7FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.pin,
                      size: 20,
                      color: AppColor.primaryTint,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.settings_passcode_lock,
                          style: AppFont.bodyBold.copyWith(
                            color: AppColor.textPrimary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _passcodeEnabled,
                    onChanged: _onPasscodeSwitchChanged,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 8),
      child: Text(
        title,
        style: AppFont.captionBold.copyWith(
          fontSize: 13,
          color: AppColor.textSecondary(context).withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

import 'package:datasapien_sdk/datasapien_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_asset_icons.dart';
import '../../theme/app_color.dart';
import '../../theme/app_font.dart';
import '../../utils/app_constants.dart';
import '../../widgets/settings/settings_switch_row.dart';

/// Memory settings: hero header + Use memories / Auto-learn (matches iOS MemorySettingsViewController).
class MemorySettingsScreen extends StatefulWidget {
  const MemorySettingsScreen({super.key});

  @override
  State<MemorySettingsScreen> createState() => _MemorySettingsScreenState();
}

class _MemorySettingsScreenState extends State<MemorySettingsScreen> {
  bool _useMemories = true;
  bool _autoLearn = true;
  bool _loading = true;

  static const Color _headerIconBg = Color(0xFFFFF2EB);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final meDataService = DataSapien.getMeDataService();
      final useRecord = await meDataService.getLastMeDataRecord(
        AppConstants.meDataKeys.useMemories,
      );
      final autoRecord = await meDataService.getLastMeDataRecord(
        AppConstants.meDataKeys.autoLearn,
      );
      if (!mounted) return;
      setState(() {
        _useMemories = _parseBool(
          useRecord?.values.isNotEmpty == true
              ? useRecord!.values.first.value
              : null,
          true,
        );
        _autoLearn = _parseBool(
          autoRecord?.values.isNotEmpty == true
              ? autoRecord!.values.first.value
              : null,
          true,
        );
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _parseBool(dynamic value, bool defaultValue) {
    if (value == null) return defaultValue;
    final s = value.toString().toLowerCase();
    if (s == 'true') return true;
    if (s == 'false') return false;
    return defaultValue;
  }

  Future<void> _saveUseMemories(bool value) async {
    setState(() => _useMemories = value);
    try {
      final meDataService = DataSapien.getMeDataService();
      await meDataService.saveMeDataRecord(
        AppConstants.meDataKeys.useMemories,
        value.toString(),
      );
    } catch (_) {}
  }

  Future<void> _saveAutoLearn(bool value) async {
    setState(() => _autoLearn = value);
    try {
      final meDataService = DataSapien.getMeDataService();
      await meDataService.saveMeDataRecord(
        AppConstants.meDataKeys.autoLearn,
        value.toString(),
      );
    } catch (_) {}
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
          l10n.settings_memory_screen_title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColor.textPrimary(context),
              ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: _headerIconBg,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            AppAssetIcons.settingsBrainHeadProfile,
                            width: 40,
                            height: 40,
                            fit: BoxFit.contain,
                            colorFilter: const ColorFilter.mode(
                              AppColor.primaryTint,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.settings_memory_header_title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColor.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.settings_memory_header_body,
                        textAlign: TextAlign.center,
                        style: AppFont.body.copyWith(
                          fontSize: 15,
                          color: AppColor.textSecondary(context)
                              .withValues(alpha: 0.6),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 8, top: 8),
                  child: Text(
                    l10n.settings_section_preferences,
                    style: AppFont.captionBold.copyWith(
                      fontSize: 13,
                      color: AppColor.textSecondary(context)
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Material(
                    color: AppColor.primaryBackground(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      children: [
                        SettingsSwitchRow(
                          title: l10n.settings_use_memories,
                          subtitle: l10n.settings_use_memories_subtitle,
                          value: _useMemories,
                          onChanged: _saveUseMemories,
                        ),
                        Divider(
                          height: 1,
                          indent: 20,
                          endIndent: 20,
                          color: AppColor.textSecondary(context)
                              .withValues(alpha: 0.1),
                        ),
                        SettingsSwitchRow(
                          title: l10n.settings_auto_learn,
                          subtitle: l10n.settings_auto_learn_subtitle,
                          value: _autoLearn,
                          onChanged: _saveAutoLearn,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_color.dart';
import '../../theme/app_font.dart';
import '../../theme/theme_manager.dart';
import '../../widgets/settings/settings_switch_row.dart';

/// App Settings: dark mode + text size slider with pins (matches iOS AppSettingsViewController).
class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  static const List<String> _textSizeOptions = [
    'small',
    'default',
    'large',
    'huge',
  ];

  bool get _isDark =>
      ThemeManager.shared.themeMode == ThemeMode.dark;

  int _sizeIndex = 1;

  @override
  void initState() {
    super.initState();
    _syncIndexFromScale();
  }

  void _syncIndexFromScale() {
    final scale = AppFont.chatScale;
    final idx = scale <= 0.9
        ? 0
        : scale <= 1.05
            ? 1
            : scale <= 1.2
                ? 2
                : 3;
    if (_sizeIndex != idx) setState(() => _sizeIndex = idx);
  }

  Future<void> _applySizeIndex(int index) async {
    final i = index.clamp(0, _textSizeOptions.length - 1);
    setState(() => _sizeIndex = i);
    await ThemeManager.shared
        .setChatTextSizeAndPersist(_textSizeOptions[i]);
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
          l10n.settings_app_settings_screen_title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColor.textPrimary(context),
              ),
        ),
      ),
      body: ListenableBuilder(
        listenable: ThemeManager.shared,
        builder: (context, _) {
          _syncIndexFromScale();
          return ListView(
            padding: const EdgeInsets.only(top: 16, bottom: 24),
            children: [
              _sectionHeader(
                context,
                l10n.settings_section_appearance,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Material(
                  color: AppColor.primaryBackground(context),
                  borderRadius: BorderRadius.circular(20),
                  child: SettingsSwitchRow(
                    leadingIcon: Icons.dark_mode,
                    title: l10n.settings_dark_mode,
                    subtitle: l10n.settings_dark_mode_subtitle,
                    value: _isDark,
                    onChanged: (value) {
                      ThemeManager.shared.setThemeAndPersist(
                        value ? ThemeMode.dark : ThemeMode.light,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _sectionHeader(
                context,
                l10n.settings_section_text_size,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Material(
                  color: AppColor.primaryBackground(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.secondaryBackground(context)
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                l10n.settings_text_size_sample,
                                textAlign: TextAlign.center,
                                style: AppFont.body.copyWith(
                                  color: AppColor.textPrimary(context),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.settings_text_size_hint,
                                textAlign: TextAlign.center,
                                style: AppFont.caption.copyWith(
                                  color: AppColor.textSecondary(context)
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Text(
                              'A',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColor.textSecondary(context)
                                    .withValues(alpha: 0.4),
                              ),
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 4,
                                  activeTrackColor: AppColor.primaryTint,
                                  inactiveTrackColor: AppColor.textSecondary(
                                    context,
                                  ).withValues(alpha: 0.15),
                                  thumbColor: AppColor.primaryTint,
                                  overlayColor: AppColor.primaryTint
                                      .withValues(alpha: 0.12),
                                ),
                                child: Slider(
                                  value: _sizeIndex.toDouble(),
                                  min: 0,
                                  max: 3,
                                  divisions: 3,
                                  onChanged: (v) {
                                    setState(
                                      () => _sizeIndex = v.round(),
                                    );
                                  },
                                  onChangeEnd: (v) =>
                                      _applySizeIndex(v.round()),
                                ),
                              ),
                            ),
                            Text(
                              'A',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: AppColor.textSecondary(context)
                                    .withValues(alpha: 0.4),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(4, (i) {
                            return InkWell(
                              onTap: () => _applySizeIndex(i),
                              borderRadius: BorderRadius.circular(20),
                              child: SizedBox(
                                width: 40,
                                height: 40,
                                child: Center(
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: AppColor.textSecondary(context)
                                          .withValues(alpha: 0.4),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _labelForTextSize(context, _textSizeOptions[_sizeIndex]),
                          textAlign: TextAlign.center,
                          style: AppFont.captionBold.copyWith(
                            color: AppColor.primaryTint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _labelForTextSize(BuildContext context, String name) {
    final l10n = AppLocalizations.of(context)!;
    switch (name) {
      case 'small':
        return l10n.settings_text_size_small;
      case 'default':
        return l10n.settings_text_size_default;
      case 'large':
        return l10n.settings_text_size_large;
      case 'huge':
        return l10n.settings_text_size_huge;
      default:
        return name;
    }
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 8, top: 8),
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

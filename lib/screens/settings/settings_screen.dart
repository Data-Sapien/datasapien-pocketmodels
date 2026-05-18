import 'package:datasapien_sdk/datasapien_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_color.dart';
import '../../theme/app_asset_icons.dart';
import '../../theme/app_font.dart';
import '../../widgets/settings/settings_row.dart';
import 'ai_personalization_screen.dart';
import 'app_settings_screen.dart';
import 'data_privacy_screen.dart';
import 'memory_settings_screen.dart';

/// Contact email (matches iOS SettingsViewController).
const String kContactSupportUrl = 'mailto:hello@datasapien.com';

const String kDatasapienWebsiteUrl = 'https://datasapien.com/';

/// Main settings root: EXPERIENCE rows, privacy, support, footer. Shown inside a modal sheet with nested [Navigator].
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _didChangeModelParams = false;

  Widget _svgIcon(String asset, {required Color color, double size = 26}) {
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  void _closeSheetWithResult() {
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop(_didChangeModelParams);
    } else {
      Navigator.of(context, rootNavigator: true).pop(_didChangeModelParams);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColor.primaryBackground(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          l10n.settings_title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColor.textPrimary(context),
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              onPressed: _closeSheetWithResult,
              style: FilledButton.styleFrom(
                backgroundColor: AppColor.primaryTint,
                foregroundColor: AppColor.buttonText,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: const StadiumBorder(),
              ),
              child: Text(
                l10n.settings_done,
                style: AppFont.button.copyWith(color: AppColor.buttonText),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        children: [
          _sectionHeader(context, l10n.settings_section_experience),
          SettingsRow(
            leading: _svgIcon(
              AppAssetIcons.settingsWandAndSparklesInverse,
              color: AppColor.primaryTint,
            ),
            title: l10n.settings_ai_personalization,
            subtitle: l10n.settings_ai_personalization_subtitle,
            onTap: () async {
              final changed = await Navigator.of(context).push<bool>(
                MaterialPageRoute<bool>(
                  builder: (_) => const AIPersonalizationScreen(),
                ),
              );
              if (changed == true && mounted) {
                setState(() => _didChangeModelParams = true);
              }
            },
          ),
          SettingsRow(
            leading: _svgIcon(
              AppAssetIcons.settingsBrainHeadProfile,
              color: AppColor.primaryTint,
            ),
            title: l10n.settings_memory,
            subtitle: l10n.settings_memory_subtitle,
            onTap: () async {
              await Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const MemorySettingsScreen(),
                ),
              );
            },
          ),
          SettingsRow(
            leading: _svgIcon(
              AppAssetIcons.settingsGearshapeFill,
              color: AppColor.primaryTint,
            ),
            title: l10n.settings_app_settings,
            subtitle: l10n.settings_app_settings_subtitle,
            onTap: () async {
              await Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const AppSettingsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _sectionHeader(context, l10n.settings_section_privacy),
          SettingsRow(
            leading: _svgIcon(
              AppAssetIcons.settingsLockFill,
              color: AppColor.primaryTint,
            ),
            title: l10n.settings_data_privacy,
            subtitle: l10n.settings_data_privacy_subtitle,
            onTap: () async {
              await Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const DataPrivacyScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _sectionHeader(context, l10n.settings_section_support),
          SettingsRow(
            leading: _svgIcon(
              AppAssetIcons.settingsEnvelopeFill,
              color: AppColor.primaryTint,
            ),
            title: l10n.settings_contact_support,
            subtitle: '',
            onTap: () => _openContact(context),
          ),
          SettingsRow(
            leading: Icon(
              Icons.description_outlined,
              color: AppColor.primaryTint,
              size: 26,
            ),
            title: l10n.settings_export_debug_logs,
            subtitle: l10n.settings_export_debug_logs_subtitle,
            onTap: () => _exportDiagnostics(context, l10n),
          ),
          const SizedBox(height: 24),
          _buildFooter(context, l10n),
        ],
      ),
    );
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

  Widget _buildFooter(BuildContext context, AppLocalizations l10n) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.hasData
            ? '${snapshot.data!.version} (${snapshot.data!.buildNumber})'
            : '1.0.0 (1)';
        return Column(
          children: [
            Divider(
              height: 1,
              color: AppColor.textSecondary(context).withValues(alpha: 0.05),
            ),
            const SizedBox(height: 24),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _openWebsite(context),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/dslogo.png',
                        width: 24,
                        height: 24,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.business,
                          size: 24,
                          color: AppColor.textSecondary(context)
                              .withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.settings_powered_by,
                        style: AppFont.captionBold.copyWith(
                          color: AppColor.textSecondary(context)
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.settings_version(version),
              style: AppFont.captionBold.copyWith(
                color: AppColor.textSecondary(context).withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 24),
            Divider(
              height: 1,
              color: AppColor.textSecondary(context).withValues(alpha: 0.05),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openWebsite(BuildContext context) async {
    final uri = Uri.parse(kDatasapienWebsiteUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  Future<void> _exportDiagnostics(
      BuildContext context, AppLocalizations l10n) async {
    try {
      final pkg = await PackageInfo.fromPlatform();
      final preamble =
          'Pocket Models (${pkg.appName})\napp version=${pkg.version}+${pkg.buildNumber}\n\n';
      final text =
          preamble + DataSapienDiagnostics.instance.exportAsPlainText();
      await SharePlus.instance.share(
        ShareParams(text: text, subject: l10n.settings_export_debug_logs),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settings_export_debug_logs_failed)),
      );
    }
  }

  Future<void> _openContact(BuildContext context) async {
    final uri = Uri.parse(kContactSupportUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.error_contact_link),
            ),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.error_contact_link),
          ),
        );
      }
    }
  }
}

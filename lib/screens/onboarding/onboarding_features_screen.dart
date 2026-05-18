import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_color.dart';
import '../../theme/app_asset_icons.dart';
import '../../theme/app_font.dart';

/// Second screen of onboarding: list of features and Continue to Models.
class OnboardingFeaturesScreen extends StatelessWidget {
  const OnboardingFeaturesScreen({super.key});

  static List<({String title, String desc, String iconAsset, Color color})>
      _features(AppLocalizations l10n) => [
            (
              title: l10n.features_private_title,
              desc: l10n.features_private_desc,
              iconAsset: AppAssetIcons.featureShieldPatternCheckered,
              color: Colors.green,
            ),
            (
              title: l10n.features_free_title,
              desc: l10n.features_free_desc,
              iconAsset: AppAssetIcons.featureDollarRotate,
              color: Colors.amber,
            ),
            (
              title: l10n.features_vision_title,
              desc: l10n.features_vision_desc,
              iconAsset: AppAssetIcons.featureEye,
              color: Colors.orange,
            ),
            (
              title: l10n.features_docs_title,
              desc: l10n.features_docs_desc,
              iconAsset: AppAssetIcons.featureDocumentOnDocument,
              color: Colors.indigo,
            ),
            (
              title: l10n.features_web_title,
              desc: l10n.features_web_desc,
              iconAsset: AppAssetIcons.featureGlobe,
              color: AppColor.primaryTint,
            ),
            (
              title: l10n.features_memory_title,
              desc: l10n.features_memory_desc,
              iconAsset: AppAssetIcons.featureBrain,
              color: Colors.pink,
            ),
            (
              title: l10n.features_custom_title,
              desc: l10n.features_custom_desc,
              iconAsset: AppAssetIcons.featureSliderHorizontal3,
              color: Colors.purple,
            ),
          ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final features = _features(l10n);
    return Scaffold(
      backgroundColor: AppColor.primaryBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.features_title,
                      style: AppFont.h1.copyWith(
                        color: AppColor.textPrimary(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ...features.map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _FeatureCard(
                          title: f.title,
                          description: f.desc,
                          iconAsset: f.iconAsset,
                          color: f.color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
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
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/models');
                      },
                      icon: SvgPicture.asset(
                        AppAssetIcons.mainChevronRight,
                        width: 20,
                        height: 20,
                        fit: BoxFit.contain,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      label: Text(l10n.continue_button),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColor.primaryTint,
                        foregroundColor: AppColor.buttonText,
                        minimumSize: const Size.fromHeight(56),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
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
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.description,
    required this.iconAsset,
    required this.color,
  });

  final String title;
  final String description;
  final String iconAsset;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.secondaryBackground(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: SvgPicture.asset(
              iconAsset,
              width: 28,
              height: 28,
              // Use contain to avoid clipping/cropping across mixed viewBoxes.
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFont.h3.copyWith(
                    color: AppColor.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppFont.caption.copyWith(
                    color: AppColor.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_asset_icons.dart';
import '../../theme/app_color.dart';
import '../../theme/app_font.dart';
import '../../widgets/app_marketing_logo.dart';

/// First screen of onboarding: title, description, and Continue to Features.
class OnboardingWelcomeScreen extends StatelessWidget {
  const OnboardingWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final h = MediaQuery.sizeOf(context).height;
    final topInset = (h * 0.1).clamp(48.0, 120.0);
    return Scaffold(
      backgroundColor: AppColor.primaryBackground(context),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: topInset),
            const Center(
              child: AppMarketingLogo(size: 100, borderRadius: 22),
            ),
            const SizedBox(height: 40),
            Text(
              l10n.welcome_title,
              style: AppFont.h1.copyWith(color: AppColor.primaryTint),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                l10n.welcome_subtitle,
                style: AppFont.h3.copyWith(
                  color: AppColor.textPrimary(context),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                l10n.welcome_desc1,
                style: AppFont.body.copyWith(
                  color: AppColor.textSecondary(context),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                l10n.welcome_desc2,
                style: AppFont.body.copyWith(
                  color: AppColor.textSecondary(context),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/features');
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
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 32,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

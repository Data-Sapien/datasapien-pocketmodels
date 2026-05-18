import 'package:flutter/material.dart';
import 'package:datasapien_sdk/datasapien_sdk.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_color.dart';
import '../theme/app_font.dart';
import '../theme/theme_manager.dart';
import '../utils/app_constants.dart';
import '../services/app_preferences.dart';
import '../services/data_migration_manager.dart';
import '../widgets/app_marketing_logo.dart';

/// Destination after splash routing (used by root to swap screen).
enum SplashDestination {
  onboarding,
  passcode,
  mainChat,
}

/// Full-screen splash that runs post-setup routing and calls [onNavigate] once.
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.onNavigate,
    this.sdkSetupFuture,
  });

  final void Function(SplashDestination destination) onNavigate;

  /// Waits at start of routing when non-null (native SDK setup).
  final Future<void>? sdkSetupFuture;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runRouting());
  }

  Future<void> _runRouting() async {
    if (_hasNavigated) return;

    try {
      await (widget.sdkSetupFuture ?? Future<void>.value());
      await ThemeManager.shared.applyInitialSettings();
      await DataMigrationManager.shared.runMigrationsIfNeeded();

      final meDataService = DataSapien.getMeDataService();
      final record = await meDataService.getLastMeDataRecord(
        AppConstants.meDataKeys.onboardingStatus,
      );

      final completed = record != null &&
          record.values.isNotEmpty &&
          record.values.first.value == AppConstants.onboardingStatus.finished;

      if (!mounted) return;
      if (_hasNavigated) return;

      if (!completed) {
        await meDataService.saveMeDataRecord(
          AppConstants.meDataKeys.onboardingStatus,
          AppConstants.onboardingStatus.started,
        );
        _hasNavigated = true;
        widget.onNavigate(SplashDestination.onboarding);
        return;
      }

      final passcodeEnabled = await AppPreferences.getPasscodeEnabled();
      _hasNavigated = true;
      if (passcodeEnabled) {
        widget.onNavigate(SplashDestination.passcode);
      } else {
        widget.onNavigate(SplashDestination.mainChat);
      }
    } catch (_) {
      if (!mounted || _hasNavigated) return;
      _hasNavigated = true;
      widget.onNavigate(SplashDestination.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColor.primaryBackground(context),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Transform.translate(
                offset: const Offset(0, -50),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppMarketingLogo(size: 120, borderRadius: 24),
                    const SizedBox(height: 24),
                    Text(
                      'Pocket Models',
                      style: AppFont.h1.copyWith(color: AppColor.primaryTint),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        color: AppColor.primaryTint,
                        strokeWidth: 2.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.splash_powered_by,
                    style: AppFont.caption.copyWith(
                      color: AppColor.textSecondary(context),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Image.asset(
                    'assets/images/dslogo.png',
                    width: 24,
                    height: 24,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.image_not_supported_outlined,
                      size: 24,
                      color: AppColor.textSecondary(context),
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

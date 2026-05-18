import 'dart:ui' show PlatformDispatcher;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart'
    show debugPrint, defaultTargetPlatform, kDebugMode, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:datasapien_sdk/datasapien_sdk.dart';
import 'package:permission_handler/permission_handler.dart';

import 'firebase_options.dart';

import 'l10n/app_localizations.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding/onboarding_flow.dart';
import 'screens/passcode/passcode_verify_screen.dart';
import 'screens/chat/main_chat_screen.dart';
import 'theme/app_system_ui.dart';
import 'theme/app_theme.dart';
import 'theme/theme_manager.dart';
import 'utils/app_constants.dart';

Future<void> _initFirebaseForMobile() async {
  if (kIsWeb) return;
  if (defaultTargetPlatform != TargetPlatform.android &&
      defaultTargetPlatform != TargetPlatform.iOS) {
    return;
  }
  // iOS: bundled GoogleService-Info.plist (Debug vs Release from Xcode run script).
  // Android: explicit options so app id matches applicationId / .debug suffix.
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    await Firebase.initializeApp();
  } else {
    await Firebase.initializeApp(
      options: kDebugMode
          ? DefaultFirebaseOptions.androidDebug
          : DefaultFirebaseOptions.android,
    );
  }
  await FirebaseCrashlytics.instance
      .setCrashlyticsCollectionEnabled(!kDebugMode);
  FlutterError.onError = (details) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}

Future<void> _requestNotificationPermissionIfMobile() async {
  if (kIsWeb) return;
  if (defaultTargetPlatform != TargetPlatform.android &&
      defaultTargetPlatform != TargetPlatform.iOS) {
    return;
  }
  await Permission.notification.request();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initFirebaseForMobile();
  await _requestNotificationPermissionIfMobile();

  final config = _buildDataSapienConfig();
  await DataSapien.initialize(config);

  DataSapienDiagnostics.instance
    ..configure(
      const DataSapienDiagnosticsConfig(
        mode: DataSapienDiagnosticsMode.verboseSupport,
      ),
    )
    ..setEnabled(true)
    ..logUiEvent('Pocket Models diagnostics recording started');

  final sdkSetupFuture = DataSapien.setup().catchError((Object e, StackTrace st) {
    assert(() {
      debugPrint('DataSapien.setup failed: $e');
      return true;
    }());
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.recordError(e, st, fatal: false);
    }
  });

  runApp(MyApp(sdkSetupFuture: sdkSetupFuture));
}

// Replace every `YOUR_*` value below with the credentials issued to you in the
// DataSapien orchestrator. Note `YOUR_MEDIA_URL` lives in
// `lib/utils/app_constants.dart` (referenced via `AppConstants.mediaBaseUrl`)
// because it is also used to resolve managed-model artwork elsewhere in the app.
//
// Get your credentials: https://datasapien.com/pricing/
// Integration guide:    https://dev.datasapien.com/
DataSapienConfig _buildDataSapienConfig() {
  return DataSapienConfig.builder()
      .setAuth(
        authUrl: 'YOUR_AUTH_URL',
        authClientId: 'YOUR_CLIENT_ID',
        authClientSecret: 'YOUR_CLIENT_SECRET',
        authScope: 'YOUR_AUTH_SCOPE',
      )
      .setHostUrl('YOUR_HOST_URL')
      .setMediaUrl(AppConstants.mediaBaseUrl) // YOUR_MEDIA_URL — see lib/utils/app_constants.dart
      .setMainColor('#1464FA')
      .setDebug(true)
      .build();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.sdkSetupFuture});

  /// When non-null, splash waits for this future (setup success or handled failure)
  /// before routing — mirrors iOS waiting for `onSetupComplete`.
  final Future<void>? sdkSetupFuture;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  SplashDestination? _postSplashRoot;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      applyAppSystemUiOverlayStyle(ThemeManager.shared.themeMode);
    }
  }

  void _onSplashComplete(SplashDestination destination) {
    if (!mounted) return;
    setState(() => _postSplashRoot = destination);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeManager.shared,
      builder: (context, _) {
        return MaterialApp(
          onGenerateTitle: (context) =>
              AppLocalizations.of(context)!.app_title,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeManager.shared.themeMode,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: _buildRoot(),
        );
      },
    );
  }

  Widget _buildRoot() {
    if (_postSplashRoot == null) {
      return SplashScreen(
        onNavigate: _onSplashComplete,
        sdkSetupFuture: widget.sdkSetupFuture,
      );
    }
    switch (_postSplashRoot!) {
      case SplashDestination.onboarding:
        return OnboardingFlow(
          onComplete: () {
            if (!mounted) return;
            setState(() => _postSplashRoot = SplashDestination.mainChat);
          },
        );
      case SplashDestination.passcode:
        return PasscodeVerifyScreen(
          onSuccess: () {
            if (!mounted) return;
            setState(() => _postSplashRoot = SplashDestination.mainChat);
          },
        );
      case SplashDestination.mainChat:
        return const MainChatScreen();
    }
  }
}

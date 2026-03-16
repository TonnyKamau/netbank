import 'package:go_router/go_router.dart';

import '../core/services/onboarding_service.dart';
import '../features/onboarding/splash_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/two_factor_auth_screen.dart';
import '../features/auth/pin_entry_screen.dart';
import '../features/home/home_screen.dart';
import '../features/compression/compression_history_screen.dart';
import '../features/compression/batch_compression_screen.dart';
import '../features/compression/compression_status_screen.dart';
import '../features/compression/select_files_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/settings/pricing_screen.dart';
import '../features/cloud/cloud_screens.dart';
import '../features/error/error_screens.dart';

class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const checkEmail = '/check-email';
  static const resetSuccess = '/reset-success';
  static const twoFactor = '/two-factor';
  static const pinEntry = '/pin-entry';
  static const biometrics = '/biometrics';
  static const home = '/home';
  static const history = '/history';
  static const batch = '/batch';
  static const compressionStatus = '/compression-status';
  static const storageSuccess = '/storage-success';
  static const selectFiles = '/select-files';
  static const decompressionProgress = '/decompression-progress';
  static const settings = '/settings';
  static const pricing = '/pricing';
  static const connectCloud = '/connect-cloud';
  static const cloudSyncSettings = '/cloud-sync';
  static const cloudError = '/cloud-error';
  static const cloudSuccess = '/cloud-success';
  static const lowStorage = '/low-storage';
  static const noInternet = '/no-internet';
}

GoRouter buildRouter(bool skipOnboarding) => GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => SplashScreen(
        onDone: () => context.go(
          skipOnboarding ? AppRoutes.login : AppRoutes.onboarding,
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => OnboardingScreen(
        onGetStarted: () async {
          await OnboardingService.markComplete();
          if (context.mounted) context.go(AppRoutes.register);
        },
        onLogin: () async {
          await OnboardingService.markComplete();
          if (context.mounted) context.go(AppRoutes.login);
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => LoginScreen(
        onLogin: () => context.go(AppRoutes.home),
        onRegister: () => context.go(AppRoutes.register),
        onForgotPassword: () => context.push(AppRoutes.forgotPassword),
        onBack: () => context.go(AppRoutes.onboarding),
      ),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => RegisterScreen(
        onRegister: () => context.go(AppRoutes.home),
        onLogin: () => context.go(AppRoutes.login),
        onBack: () => context.go(AppRoutes.onboarding),
      ),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => ForgotPasswordScreen(
        onSend: () => context.push(AppRoutes.checkEmail),
      ),
    ),
    GoRoute(
      path: AppRoutes.checkEmail,
      builder: (context, state) => CheckEmailScreen(
        onBack: () => context.pop(),
        onResend: () => context.go(AppRoutes.forgotPassword),
      ),
    ),
    GoRoute(
      path: AppRoutes.resetSuccess,
      builder: (context, state) => PasswordResetSuccessScreen(
        onLogin: () => context.go(AppRoutes.login),
      ),
    ),
    GoRoute(
      path: AppRoutes.twoFactor,
      builder: (context, state) => TwoFactorAuthScreen(
        onVerify: () => context.go(AppRoutes.home),
      ),
    ),
    GoRoute(
      path: AppRoutes.pinEntry,
      builder: (context, state) => PinEntryScreen(
        onSuccess: () => context.go(AppRoutes.home),
      ),
    ),
    GoRoute(
      path: AppRoutes.biometrics,
      builder: (context, state) => BiometricsScreen(
        onAuthenticate: () => context.go(AppRoutes.home),
        onUsePIN: () => context.go(AppRoutes.pinEntry),
      ),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => HomeScreen(
        onNavigate: (tab) {
          switch (tab.name) {
            case 'history': context.push(AppRoutes.history); break;
            case 'batch': context.push(AppRoutes.batch); break;
            case 'settings': context.push(AppRoutes.settings); break;
          }
        },
        onCompress: () => context.push(AppRoutes.batch),
      ),
    ),
    GoRoute(
      path: AppRoutes.history,
      builder: (context, state) => CompressionHistoryScreen(
        onNavigate: (tab) {
          switch (tab.name) {
            case 'home': context.go(AppRoutes.home); break;
            case 'batch': context.push(AppRoutes.batch); break;
            case 'settings': context.push(AppRoutes.settings); break;
          }
        },
        onDecompress: () => context.push(AppRoutes.selectFiles),
      ),
    ),
    GoRoute(
      path: AppRoutes.batch,
      builder: (context, state) => BatchCompressionScreen(
        onNavigate: (tab) {
          switch (tab.name) {
            case 'home': context.go(AppRoutes.home); break;
            case 'history': context.push(AppRoutes.history); break;
            case 'settings': context.push(AppRoutes.settings); break;
          }
        },
        onStartBatch: () => context.push(AppRoutes.compressionStatus),
      ),
    ),
    GoRoute(
      path: AppRoutes.compressionStatus,
      builder: (context, state) => CompressionStatusScreen(
        onComplete: () => context.pushReplacement(AppRoutes.storageSuccess),
        onCancel: () => context.pop(),
      ),
    ),
    GoRoute(
      path: AppRoutes.storageSuccess,
      builder: (context, state) => StorageSuccessScreen(
        onDone: () => context.go(AppRoutes.home),
        onViewHistory: () => context.go(AppRoutes.history),
      ),
    ),
    GoRoute(
      path: AppRoutes.selectFiles,
      builder: (context, state) => SelectFilesScreen(
        onDecompress: () => context.push(AppRoutes.decompressionProgress),
      ),
    ),
    GoRoute(
      path: AppRoutes.decompressionProgress,
      builder: (context, state) => DecompressionProgressScreen(
        onComplete: () => context.pushReplacement(AppRoutes.storageSuccess),
        onCancel: () => context.pop(),
      ),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => SettingsScreen(
        onPricing: () => context.push(AppRoutes.pricing),
        onPinSetup: () => context.push(AppRoutes.pinEntry),
        onBiometrics: () => context.push(AppRoutes.biometrics),
        onCloudConnect: () => context.push(AppRoutes.connectCloud),
      ),
    ),
    GoRoute(
      path: AppRoutes.pricing,
      builder: (context, state) => PricingScreen(
        onBack: () => context.pop(),
      ),
    ),
    GoRoute(
      path: AppRoutes.connectCloud,
      builder: (context, state) => ConnectCloudScreen(
        onConnect: (name) => context.push(AppRoutes.cloudSuccess, extra: name),
        onBack: () => context.pop(),
      ),
    ),
    GoRoute(
      path: AppRoutes.cloudSyncSettings,
      builder: (context, state) => const CloudSyncSettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.cloudError,
      builder: (context, state) => CloudConnectionErrorScreen(
        onRetry: () => context.push(AppRoutes.connectCloud),
        onBack: () => context.pop(),
      ),
    ),
    GoRoute(
      path: AppRoutes.cloudSuccess,
      builder: (context, state) {
        final name = state.extra as String? ?? 'Cloud';
        return CloudConnectionSuccessScreen(
          serviceName: name,
          onDone: () => context.go(AppRoutes.home),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.lowStorage,
      builder: (context, state) => LowStorageWarningScreen(
        onCompress: () => context.go(AppRoutes.batch),
        onUpgrade: () => context.push(AppRoutes.pricing),
      ),
    ),
    GoRoute(
      path: AppRoutes.noInternet,
      builder: (context, state) => NoInternetScreen(
        onRetry: () => context.pop(),
      ),
    ),
  ],
);

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'core/services/onboarding_service.dart';
import 'core/services/platform_auth_service.dart';
import 'core/services/session_service.dart';
import 'core/services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Keep local defaults available even if the env asset is missing.
  }
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  final results = await Future.wait([
    OnboardingService.isComplete(),
    ThemeService.instance.load().then((_) => false),
    PlatformAuthService.instance.load().then((_) => false),
    SessionService.isLoggedIn(),
  ]);
  runApp(CompressItApp(
    skipOnboarding: results[0],
    isLoggedIn: results[3],
  ));
}

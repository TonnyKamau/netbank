import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnvironment {
  AppEnvironment._();

  static String get apiBaseUrl {
    final configured = dotenv.maybeGet('UF_API_BASE_URL')?.trim() ?? '';
    if (configured.isNotEmpty) {
      return configured.replaceFirst(RegExp(r'/$'), '');
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://localhost:8000';
  }

  static String get platformApiKey {
    final configured = dotenv.maybeGet('UF_PLATFORM_API_KEY')?.trim() ?? '';
    if (configured.isNotEmpty) {
      return configured;
    }
    return 'uf_dev_key_local_only_change_me';
  }
}

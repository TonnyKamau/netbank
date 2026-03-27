import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/services/biometric_service.dart';
import 'core/services/pin_service.dart';
import 'core/services/session_service.dart';
import 'core/services/theme_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/pin_entry_screen.dart';
import 'features/auth/pin_forgot_screen.dart';
import 'routes/app_router.dart';

class CompressItApp extends StatefulWidget {
  const CompressItApp({
    super.key,
    this.skipOnboarding = false,
    this.isLoggedIn = false,
  });

  final bool skipOnboarding;
  final bool isLoggedIn;

  @override
  State<CompressItApp> createState() => _CompressItAppState();
}

class _CompressItAppState extends State<CompressItApp>
    with WidgetsBindingObserver {
  bool _showLock = false;
  bool _pinEnabled = false;
  bool _biometricsEnabled = false;
  bool _usePinFallback = false;
  bool _showForgotPin = false;
  bool _showPinReset = false;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = buildRouter(widget.skipOnboarding);
    WidgetsBinding.instance.addObserver(this);
    if (widget.isLoggedIn) {
      _checkAndLock();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkAndLock() async {
    final bio = await BiometricService.isEnabled();
    final pin = await PinService.isEnabled();
    if (bio || pin) {
      setState(() {
        _biometricsEnabled = bio;
        _pinEnabled = pin;
        _showLock = true;
        _usePinFallback = false;
        _showForgotPin = false;
        _showPinReset = false;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _checkAndLock();
    }
  }

  void _unlock() {
    setState(() {
      _showLock = false;
      _usePinFallback = false;
      _showForgotPin = false;
      _showPinReset = false;
    });
  }

  Widget _buildLockScreen() {
    // Step 3 — reset success
    if (_showPinReset) {
      return PinResetScreen(
        onLoginAgain: () {
          setState(() {
            _showLock = false;
            _showForgotPin = false;
            _showPinReset = false;
          });
          _router.go(AppRoutes.login);
        },
      );
    }

    // Step 2 — forgot PIN confirmation
    if (_showForgotPin) {
      return PinForgotScreen(
        onResetComplete: () async {
          await SessionService.setLoggedIn(false);
          setState(() => _showPinReset = true);
        },
        onCancel: () => setState(() => _showForgotPin = false),
      );
    }

    // Step 1 — biometrics first, PIN as fallback
    if (_biometricsEnabled && !_usePinFallback) {
      return BiometricsScreen(
        onSuccess: _unlock,
        onUsePIN: _pinEnabled
            ? () => setState(() => _usePinFallback = true)
            : null,
      );
    }

    return PinEntryScreen(
      onSuccess: _unlock,
      onForgotPin: () => setState(() => _showForgotPin = true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.instance,
      builder: (context, themeMode, _) => MaterialApp.router(
        title: 'Universal Folder',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        routerConfig: _router,
        builder: (context, child) {
          Widget content = _showLock ? _buildLockScreen() : child!;
          Widget result = MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: MediaQuery.textScalerOf(context).clamp(
                minScaleFactor: 0.8,
                maxScaleFactor: 1.2,
              ),
            ),
            child: content,
          );
          if (MediaQuery.sizeOf(context).width >= 600) {
            return ColoredBox(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Center(
                child: SizedBox(width: 480, child: result),
              ),
            );
          }
          return result;
        },
      ),
    );
  }
}

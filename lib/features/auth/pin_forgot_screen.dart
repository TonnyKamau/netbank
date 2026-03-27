import 'package:flutter/material.dart';
import '../../core/services/biometric_service.dart';
import '../../core/services/pin_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_responsive.dart';

// ─────────────────────────────────────────
// Forgot PIN Screen
// ─────────────────────────────────────────
class PinForgotScreen extends StatefulWidget {
  const PinForgotScreen({
    super.key,
    required this.onResetComplete,
    required this.onCancel,
  });

  /// Called after PIN & biometrics have been cleared. Caller handles navigation.
  final VoidCallback onResetComplete;
  final VoidCallback onCancel;

  @override
  State<PinForgotScreen> createState() => _PinForgotScreenState();
}

class _PinForgotScreenState extends State<PinForgotScreen> {
  bool _loading = false;

  Future<void> _resetPin() async {
    setState(() => _loading = true);
    await PinService.disable();
    await BiometricService.setEnabled(false);
    if (!mounted) return;
    setState(() => _loading = false);
    widget.onResetComplete();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight2,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _loading ? null : widget.onCancel,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              // Icon
              Center(
                child: Container(
                  width: context.s(88),
                  height: context.s(88),
                  decoration: const BoxDecoration(
                    color: AppColors.warningLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_reset_rounded,
                    color: AppColors.warning,
                    size: 44,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'Forgot Your PIN?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'To regain access, you can reset your PIN. You\'ll need to log back in with your account credentials.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 28),

              // Warning card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'This will also disable biometric authentication. '
                        'You can set up a new PIN in Settings after logging in.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : const Color(0xFF78350F),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Reset button
              ElevatedButton(
                onPressed: _loading ? null : _resetPin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.error.withValues(alpha: 0.6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Reset PIN & Log In',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: _loading ? null : widget.onCancel,
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// PIN Reset Success Screen
// ─────────────────────────────────────────
class PinResetScreen extends StatelessWidget {
  const PinResetScreen({super.key, required this.onLoginAgain});

  final VoidCallback onLoginAgain;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight2,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // Success icon
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: AppColors.successLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppColors.success,
                    size: 52,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Text(
                'PIN Reset Successfully',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Your PIN and biometric lock have been removed.\nLog in to set up a new PIN from Settings.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),

              const Spacer(),

              ElevatedButton(
                onPressed: onLoginAgain,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Log In Now',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

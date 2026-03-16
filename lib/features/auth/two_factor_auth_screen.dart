import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_responsive.dart';
import '../../core/widgets/primary_button.dart';

class TwoFactorAuthScreen extends StatefulWidget {
  const TwoFactorAuthScreen({super.key, this.onVerify, this.onBack, this.email = 'user@example.com'});

  final VoidCallback? onVerify;
  final VoidCallback? onBack;
  final String email;

  @override
  State<TwoFactorAuthScreen> createState() => _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends State<TwoFactorAuthScreen> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight2,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: isDark ? AppColors.borderDark : AppColors.slate100),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.verified_user, color: AppColors.primary, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'Two-Factor Authentication',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter the 6-digit code sent to ${widget.email}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // OTP boxes
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(6, (i) => _OtpBox(
                            controller: _controllers[i],
                            focusNode: _focusNodes[i],
                            onChanged: (val) {
                              if (val.isNotEmpty && i < 5) {
                                _focusNodes[i + 1].requestFocus();
                              } else if (val.isEmpty && i > 0) {
                                _focusNodes[i - 1].requestFocus();
                              }
                            },
                            isDark: isDark,
                          )),
                        ),
                        const SizedBox(height: 24),
                        PrimaryButton(label: 'Verify Code', onPressed: widget.onVerify),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Didn't receive the code? ",
                              style: TextStyle(
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                fontSize: 13,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: const Text(
                                'Resend',
                                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.isDark,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.s(44),
      height: context.sh(52),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: isDark ? AppColors.slate800 : AppColors.slate100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class PasswordResetSuccessScreen extends StatelessWidget {
  const PasswordResetSuccessScreen({super.key, this.onLogin});

  final VoidCallback? onLogin;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight2,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(color: AppColors.successLight, shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle, color: AppColors.success, size: 52),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Password Reset!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your password has been successfully reset. You can now log in with your new password.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  height: 1.6,
                ),
              ),
              const Spacer(),
              PrimaryButton(label: 'Back to Login', onPressed: onLogin),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

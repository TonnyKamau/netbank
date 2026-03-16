import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_responsive.dart';
import '../../core/widgets/primary_button.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key, this.onSend, this.onBack});

  final VoidCallback? onSend;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight2,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Back
                GestureDetector(
                  onTap: onBack ?? () => Navigator.maybePop(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back, size: 20, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                      const SizedBox(width: 6),
                      Text(
                        'Back to Login',
                        style: TextStyle(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Label
                Center(
                  child: Text(
                    'FORGOT PASSWORD',
                    style: TextStyle(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Icon
                Center(
                  child: Container(
                    width: context.s(80),
                    height: context.s(80),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_reset, color: AppColors.primary, size: 36),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Reset Password',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Enter the email address associated with your account and we'll send you a link to reset your password.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 2))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Email Address',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(hintText: 'your@email.com'),
                      ),
                      const SizedBox(height: 20),
                      PrimaryButton(label: 'Send Reset Link', onPressed: onSend),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CheckEmailScreen extends StatelessWidget {
  const CheckEmailScreen({super.key, this.onBack, this.onResend});

  final VoidCallback? onBack;
  final VoidCallback? onResend;

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
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBack ?? () => Navigator.maybePop(context),
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Center(
                child: Container(
                  width: context.s(88),
                  height: context.s(88),
                  decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                  child: const Icon(Icons.mark_email_read_outlined, color: AppColors.primary, size: 44),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Check your email',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "We've sent a password reset link to your email. Please check your inbox and follow the instructions.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  height: 1.6,
                ),
              ),
              const Spacer(),
              PrimaryButton(label: 'Open Email App', onPressed: () {}),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: onResend,
                  child: const Text(
                    "Didn't receive it? Resend",
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}


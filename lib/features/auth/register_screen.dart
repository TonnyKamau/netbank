import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_responsive.dart';
import '../../core/widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    this.onRegister,
    this.onLogin,
    this.onBack,
  });

  final VoidCallback? onRegister;
  final VoidCallback? onLogin;
  final VoidCallback? onBack;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _acceptTerms = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight2;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: AppColors.primary,
                    onPressed: widget.onBack ?? () => Navigator.maybePop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Netbank',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            // Hero banner
            Container(
              height: context.sh(160),
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_upload_outlined, color: AppColors.primary, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      'Start saving space today',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 4))
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Create Account',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Start saving space on your device today with smart compression',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildLabel('Full Name', isDark),
                        const SizedBox(height: 8),
                        TextFormField(decoration: const InputDecoration(hintText: 'Enter your full name')),
                        const SizedBox(height: 16),
                        _buildLabel('Email Address', isDark),
                        const SizedBox(height: 8),
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(hintText: 'you@example.com'),
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Password', isDark),
                        const SizedBox(height: 8),
                        TextFormField(
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'Create a strong password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: AppColors.textPrimary,
                                size: 20,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _acceptTerms,
                                activeColor: AppColors.primary,
                                onChanged: (v) => setState(() => _acceptTerms = v ?? false),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                  ),
                                  children: const [
                                    TextSpan(text: 'I agree to the '),
                                    TextSpan(
                                      text: 'Terms of Service',
                                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                                    ),
                                    TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        PrimaryButton(label: 'Create Account', onPressed: widget.onRegister),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(child: Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'OR CONTINUE WITH',
                                style: TextStyle(
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: SocialButton(
                                label: 'Google',
                                onPressed: () {},
                                iconWidget: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                                  child: const Center(
                                    child: Text('G', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SocialButton(label: 'Apple', onPressed: () {}, icon: Icons.apple),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary, fontSize: 14),
                            ),
                            GestureDetector(
                              onTap: widget.onLogin,
                              child: const Text(
                                'Log In',
                                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
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

  Widget _buildLabel(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textPrimaryDark : AppColors.slate800,
      ),
    );
  }
}

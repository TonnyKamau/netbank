import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_responsive.dart';

class PinEntryScreen extends StatefulWidget {
  const PinEntryScreen({super.key, this.onSuccess, this.title = 'Enter PIN'});

  final VoidCallback? onSuccess;
  final String title;

  @override
  State<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> {
  String _pin = '';
  static const int _pinLength = 4;

  void _onKey(String key) {
    if (_pin.length < _pinLength) {
      setState(() => _pin += key);
      if (_pin.length == _pinLength) {
        Future.delayed(const Duration(milliseconds: 200), widget.onSuccess);
      }
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty) setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight2,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                  child: const Icon(Icons.lock_outline, color: AppColors.primary, size: 32),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your 4-digit PIN to continue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              SizedBox(height: context.sh(40)),
              // Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pinLength, (i) {
                  final filled = i < _pin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? AppColors.primary : Colors.transparent,
                      border: Border.all(
                        color: filled ? AppColors.primary : (isDark ? AppColors.slate600 : AppColors.slate300),
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: context.sh(48)),
              // Keypad
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  childAspectRatio: 1.4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    ...['1','2','3','4','5','6','7','8','9'].map((k) => _KeyButton(
                      label: k,
                      onTap: () => _onKey(k),
                      isDark: isDark,
                    )),
                    const SizedBox.shrink(),
                    _KeyButton(label: '0', onTap: () => _onKey('0'), isDark: isDark),
                    _DeleteButton(onTap: _onDelete, isDark: isDark),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Forgot PIN?',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({required this.label, required this.onTap, required this.isDark});
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.slate800 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.onTap, required this.isDark});
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.slate800 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
        child: Center(
          child: Icon(
            Icons.backspace_outlined,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class BiometricsScreen extends StatelessWidget {
  const BiometricsScreen({super.key, this.onAuthenticate, this.onUsePIN});

  final VoidCallback? onAuthenticate;
  final VoidCallback? onUsePIN;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight2,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: GestureDetector(
                  onTap: onAuthenticate,
                  child: Container(
                    width: context.s(120),
                    height: context.s(120),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 24, spreadRadius: 4)
                      ],
                    ),
                    child: const Icon(Icons.fingerprint, color: AppColors.primary, size: 64),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Use Biometrics',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Place your finger on the sensor or use Face ID to unlock the app',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  height: 1.6,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: onAuthenticate,
                child: const Text('Authenticate'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: onUsePIN,
                child: const Text(
                  'Use PIN instead',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

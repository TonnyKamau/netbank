import 'package:flutter/material.dart';
import '../../core/services/biometric_service.dart';
import '../../core/services/pin_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_responsive.dart';

class PinEntryScreen extends StatefulWidget {
  const PinEntryScreen({
    super.key,
    this.onSuccess,
    this.onSuccessResult = false,
    this.onForgotPin,
    this.title = 'Enter PIN',
    this.subtitle = 'Enter your 4-digit PIN to continue',
    this.verifyAgainstStored = true,
  });

  /// Called when PIN verified — used for push navigation (no return value).
  final VoidCallback? onSuccess;

  /// Used when screen is pushed for a result (e.g. verify before disabling PIN).
  /// Pops with `true` on success.
  final bool onSuccessResult;

  /// Called when user taps "Forgot PIN?". If null the button is hidden.
  final VoidCallback? onForgotPin;

  final String title;
  final String subtitle;

  /// When true, verifies PIN against stored hash. When false, accepts any 4 digits.
  final bool verifyAgainstStored;

  @override
  State<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  static const int _pinLength = 4;
  String? _errorMessage;
  bool _loading = false;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _shake() => _shakeController.forward(from: 0);

  void _onKey(String key) {
    if (_loading || _pin.length >= _pinLength) return;
    setState(() {
      _pin += key;
      _errorMessage = null;
    });
    if (_pin.length == _pinLength) {
      Future.delayed(const Duration(milliseconds: 150), _verify);
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty) setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _verify() async {
    if (_loading) return;
    setState(() => _loading = true);

    bool correct;
    if (widget.verifyAgainstStored) {
      correct = await PinService.verifyPin(_pin);
    } else {
      correct = _pin.length == _pinLength;
    }

    if (!mounted) return;

    if (correct) {
      if (widget.onSuccessResult) {
        Navigator.of(context).pop(true);
      } else {
        widget.onSuccess?.call();
      }
    } else {
      _shake();
      setState(() {
        _pin = '';
        _errorMessage = 'Incorrect PIN. Try again.';
        _loading = false;
      });
    }
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
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
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
                widget.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              SizedBox(height: context.sh(40)),

              // Dots with shake
              AnimatedBuilder(
                animation: _shakeAnim,
                builder: (_, child) {
                  final offset = _shakeController.isAnimating
                      ? 8.0 * (0.5 - (_shakeAnim.value - 0.5).abs()) * 2
                      : 0.0;
                  return Transform.translate(
                    offset: Offset(
                      offset * ((_shakeAnim.value * 6).round().isEven ? 1 : -1),
                      0,
                    ),
                    child: child,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pinLength, (i) {
                    final filled = i < _pin.length;
                    final hasError = _errorMessage != null;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasError
                            ? AppColors.error
                            : (filled ? AppColors.primary : Colors.transparent),
                        border: Border.all(
                          color: hasError
                              ? AppColors.error
                              : (filled
                                  ? AppColors.primary
                                  : (isDark ? AppColors.slate600 : AppColors.slate300)),
                          width: 2,
                        ),
                      ),
                    );
                  }),
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ],

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
                    ...['1', '2', '3', '4', '5', '6', '7', '8', '9'].map((k) =>
                        _KeyButton(label: k, onTap: () => _onKey(k), isDark: isDark)),
                    const SizedBox.shrink(),
                    _KeyButton(label: '0', onTap: () => _onKey('0'), isDark: isDark),
                    _DeleteButton(onTap: _onDelete, isDark: isDark),
                  ],
                ),
              ),
              if (widget.onForgotPin != null)
                TextButton(
                  onPressed: widget.onForgotPin,
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

// ─────────────────────────────────────────
// Biometrics Screen
// ─────────────────────────────────────────
class BiometricsScreen extends StatefulWidget {
  const BiometricsScreen({super.key, this.onSuccess, this.onUsePIN});

  final VoidCallback? onSuccess;
  final VoidCallback? onUsePIN;

  @override
  State<BiometricsScreen> createState() => _BiometricsScreenState();
}

class _BiometricsScreenState extends State<BiometricsScreen> {
  bool _authenticating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Auto-trigger on load
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  Future<void> _authenticate() async {
    if (_authenticating) return;
    setState(() {
      _authenticating = true;
      _errorMessage = null;
    });

    final success = await BiometricService.authenticate();

    if (!mounted) return;
    setState(() => _authenticating = false);

    if (success) {
      widget.onSuccess?.call();
    } else {
      setState(() => _errorMessage = 'Authentication failed. Try again.');
    }
  }

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
                  onTap: _authenticate,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: context.s(120),
                    height: context.s(120),
                    decoration: BoxDecoration(
                      color: _authenticating
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : AppColors.primaryLight,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: _authenticating
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 3,
                            ),
                          )
                        : const Icon(Icons.fingerprint, color: AppColors.primary, size: 64),
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
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ],
              const Spacer(),
              ElevatedButton(
                onPressed: _authenticating ? null : _authenticate,
                child: Text(_authenticating ? 'Authenticating…' : 'Authenticate'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: widget.onUsePIN,
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

import 'package:flutter/material.dart';
import '../../core/services/pin_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_responsive.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen>
    with SingleTickerProviderStateMixin {
  static const int _pinLength = 4;

  String _pin = '';
  String _firstPin = '';
  bool _confirming = false;
  String? _errorMessage;

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

  void _shake() {
    _shakeController.forward(from: 0);
  }

  void _onKey(String key) {
    if (_pin.length >= _pinLength) return;
    setState(() {
      _pin += key;
      _errorMessage = null;
    });

    if (_pin.length == _pinLength) {
      Future.delayed(const Duration(milliseconds: 150), _onPinComplete);
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty) setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _onPinComplete() async {
    if (!_confirming) {
      setState(() {
        _firstPin = _pin;
        _pin = '';
        _confirming = true;
      });
    } else {
      if (_pin == _firstPin) {
        await PinService.setPin(_pin);
        if (mounted) Navigator.of(context).pop(true);
      } else {
        _shake();
        setState(() {
          _pin = '';
          _errorMessage = 'PINs do not match. Try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight2,
      appBar: AppBar(
        title: Text(_confirming ? 'Confirm PIN' : 'Set PIN'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_confirming) {
              setState(() {
                _confirming = false;
                _pin = '';
                _firstPin = '';
                _errorMessage = null;
              });
            } else {
              Navigator.of(context).pop(false);
            }
          },
        ),
      ),
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
                _confirming ? 'Confirm your PIN' : 'Create a PIN',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _confirming
                    ? 'Enter your PIN again to confirm'
                    : 'Choose a 4-digit PIN to protect your app',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              SizedBox(height: context.sh(32)),

              // Dots with shake animation
              AnimatedBuilder(
                animation: _shakeAnim,
                builder: (_, child) {
                  final offset = _shakeController.isAnimating
                      ? 8.0 * (0.5 - (_shakeAnim.value - 0.5).abs()) * 2
                      : 0.0;
                  return Transform.translate(
                    offset: Offset(offset * ((_shakeAnim.value * 6).round().isEven ? 1 : -1), 0),
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

              SizedBox(height: context.sh(40)),

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

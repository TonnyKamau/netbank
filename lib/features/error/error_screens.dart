import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_responsive.dart';
import '../../core/widgets/primary_button.dart';

// ─────────────────────────────────────────
// Low Storage Warning Screen
// ─────────────────────────────────────────
class LowStorageWarningScreen extends StatelessWidget {
  const LowStorageWarningScreen({
    super.key,
    this.usedGB = 92,
    this.totalGB = 100,
    this.onCompress,
    this.onUpgrade,
    this.onDismiss,
  });

  final double usedGB;
  final double totalGB;
  final VoidCallback? onCompress;
  final VoidCallback? onUpgrade;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final usagePct = usedGB / totalGB;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Close
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onDismiss ?? () => Navigator.maybePop(context),
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              // Warning icon
              Center(
                child: Container(
                  width: context.s(96),
                  height: context.s(96),
                  decoration: const BoxDecoration(color: AppColors.warningLight, shape: BoxShape.circle),
                  child: const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 52),
                ),
              ),
              const SizedBox(height: 24),
              Text('Storage Almost Full!', textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text(
                'You have used ${usedGB.toInt()} GB of ${totalGB.toInt()} GB. Free up space to avoid interruptions.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary, height: 1.6),
              ),
              const SizedBox(height: 32),
              // Storage bar
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Storage Used', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                        Text('${usedGB.toInt()} / ${totalGB.toInt()} GB', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.warning)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: usagePct,
                        minHeight: 10,
                        backgroundColor: isDark ? AppColors.slate800 : AppColors.slate100,
                        valueColor: AlwaysStoppedAnimation(usagePct > 0.9 ? AppColors.error : AppColors.warning),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('${(usagePct * 100).toInt()}% used', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              PrimaryButton(label: 'Compress Files Now', onPressed: onCompress),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onUpgrade,
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
                child: const Text('Upgrade Storage Plan'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// No Internet Connection Screen
// ─────────────────────────────────────────
class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Container(
                  width: context.s(100),
                  height: context.s(100),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.slate800 : AppColors.slate100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.wifi_off, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary, size: 52),
                ),
              ),
              const SizedBox(height: 32),
              Text('No Internet Connection', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
              const SizedBox(height: 12),
              Text(
                "Looks like you're offline. Check your Wi-Fi or mobile data connection and try again.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary, height: 1.6),
              ),
              const SizedBox(height: 40),
              // Tips
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Things to try:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                    const SizedBox(height: 12),
                    ...[
                      'Check Wi-Fi or mobile data',
                      'Toggle Airplane mode off and on',
                      'Restart your router',
                    ].map((tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(Icons.arrow_right, color: AppColors.primary, size: 20),
                          const SizedBox(width: 6),
                          Text(tip, style: TextStyle(fontSize: 13, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
              const Spacer(),
              PrimaryButton(label: 'Try Again', onPressed: onRetry),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Some features are available offline',
                  style: TextStyle(fontSize: 13, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

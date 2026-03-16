import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_responsive.dart';
import '../../core/widgets/primary_button.dart';

class CompressionStatusScreen extends StatefulWidget {
  const CompressionStatusScreen({
    super.key,
    this.fileName = 'vacation_photos.zip',
    this.originalSize = '128 MB',
    this.onComplete,
    this.onCancel,
  });

  final String fileName;
  final String originalSize;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;

  @override
  State<CompressionStatusScreen> createState() => _CompressionStatusScreenState();
}

class _CompressionStatusScreenState extends State<CompressionStatusScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), widget.onComplete);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Compressing...'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onCancel ?? () => Navigator.maybePop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            // File icon
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: context.s(100),
                    height: context.s(100),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.compress, color: AppColors.primary, size: 48),
                  ),
                  SizedBox(
                    width: context.s(116),
                    height: context.s(116),
                    child: AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (_, _) => CircularProgressIndicator(
                        value: _progressAnimation.value,
                        strokeWidth: 4,
                        backgroundColor: isDark ? AppColors.slate800 : AppColors.slate200,
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              widget.fileName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Original size: ${widget.originalSize}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
            ),
            const SizedBox(height: 40),
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (_, _) {
                final pct = (_progressAnimation.value * 100).toInt();
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Progress', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                        Text('$pct%', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: _progressAnimation.value,
                        minHeight: 10,
                        backgroundColor: isDark ? AppColors.slate800 : AppColors.slate100,
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                      ),
                      child: Column(
                        children: [
                          _StatusRow('Stage', pct < 30 ? 'Analyzing file...' : pct < 70 ? 'Compressing...' : 'Finalizing...', isDark),
                          const SizedBox(height: 8),
                          _StatusRow('Est. Result', '~${((double.tryParse(widget.originalSize.split(' ')[0]) ?? 0) * 0.35).toStringAsFixed(1)} MB', isDark),
                          const SizedBox(height: 8),
                          _StatusRow('Reduction', '~65%', isDark, valueColor: AppColors.success),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: widget.onCancel,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                side: const BorderSide(color: AppColors.primary),
              ),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow(this.label, this.value, this.isDark, {this.valueColor});
  final String label;
  final String value;
  final bool isDark;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary))),
      ],
    );
  }
}


class StorageSuccessScreen extends StatelessWidget {
  const StorageSuccessScreen({
    super.key,
    this.fileName = 'vacation_photos.zip',
    this.originalSize = '128 MB',
    this.compressedSize = '44.8 MB',
    this.savings = '65%',
    this.onDone,
    this.onViewHistory,
  });

  final String fileName;
  final String originalSize;
  final String compressedSize;
  final String savings;
  final VoidCallback? onDone;
  final VoidCallback? onViewHistory;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(color: AppColors.successLight, shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle, color: AppColors.success, size: 56),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Compression Complete!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                fileName,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ResultStat(label: 'Original', value: originalSize, isDark: isDark),
                    Column(children: [
                      Icon(Icons.arrow_forward, color: AppColors.primary, size: 20),
                    ]),
                    _ResultStat(label: 'Compressed', value: compressedSize, isDark: isDark),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(8)),
                      child: Text('-$savings', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              PrimaryButton(label: 'Done', onPressed: onDone),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onViewHistory,
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
                child: const Text('View History'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  const _ResultStat({required this.label, required this.value, required this.isDark});
  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
        Text(label, style: TextStyle(fontSize: 12, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
      ],
    );
  }
}

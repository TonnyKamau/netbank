import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key, this.onBack, this.onSelectPlan});

  final VoidCallback? onBack;
  final ValueChanged<String>? onSelectPlan;

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  bool _isYearly = false;
  String _selectedPlan = 'Pro';

  final _plans = [
    _Plan(
      name: 'Starter',
      monthlyPrice: 1,
      yearlyPrice: 9,
      tag: 'Free Trial',
      tagColor: AppColors.textPrimary,
      features: ['5GB Storage', 'Basic Compression', '10 files/day', 'Email Support'],
    ),
    _Plan(
      name: 'Basic',
      monthlyPrice: 2,
      yearlyPrice: 19,
      features: ['20GB Storage', 'Standard Compression', '50 files/day', 'Email Support'],
    ),
    _Plan(
      name: 'Pro',
      monthlyPrice: 3,
      yearlyPrice: 29,
      tag: 'Most Popular',
      tagColor: AppColors.primary,
      isPopular: true,
      features: ['100GB Storage', 'High Compression', 'Unlimited files', 'No Ads', 'Priority Support'],
    ),
    _Plan(
      name: 'Ultra',
      monthlyPrice: 4,
      yearlyPrice: 39,
      features: ['Unlimited Storage', 'Max Compression', 'Batch Processing', 'API Access', 'Dedicated Support'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Pricing & Plans'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack ?? () => Navigator.maybePop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            Text('Choose your plan', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(
              'Compress more, save more. Upgrade anytime.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
            ),
            const SizedBox(height: 24),
            // Billing toggle
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.slate800 : AppColors.slate100,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ToggleOption(label: 'Monthly', isActive: !_isYearly, onTap: () => setState(() => _isYearly = false), isDark: isDark),
                  _ToggleOption(
                    label: 'Yearly',
                    badge: 'Save 30%',
                    isActive: _isYearly,
                    onTap: () => setState(() => _isYearly = true),
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Plan cards
            ..._plans.map((plan) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _PlanCard(
                plan: plan,
                isSelected: _selectedPlan == plan.name,
                isYearly: _isYearly,
                onSelect: () {
                  setState(() => _selectedPlan = plan.name);
                  widget.onSelectPlan?.call(plan.name);
                },
                isDark: isDark,
              ),
            )),
            const SizedBox(height: 8),
            // Features comparison hint
            Text(
              'All plans include a 7-day free trial. Cancel anytime.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

class _Plan {
  const _Plan({
    required this.name,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.features,
    this.tag,
    this.tagColor,
    this.isPopular = false,
  });
  final String name;
  final int monthlyPrice;
  final int yearlyPrice;
  final List<String> features;
  final String? tag;
  final Color? tagColor;
  final bool isPopular;
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.isSelected, required this.isYearly, required this.onSelect, required this.isDark});
  final _Plan plan;
  final bool isSelected;
  final bool isYearly;
  final VoidCallback onSelect;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final price = isYearly ? plan.yearlyPrice : plan.monthlyPrice;
    final period = isYearly ? '/yr' : '/mo';

    return GestureDetector(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: plan.isPopular ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.08), blurRadius: 16)] : null,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(plan.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                          if (plan.tag != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: plan.tagColor ?? AppColors.primary,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(plan.tag!, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(text: '\$$price', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary, letterSpacing: -1)),
                            TextSpan(text: period, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : (isDark ? AppColors.slate500 : AppColors.slate300),
                      width: 2,
                    ),
                  ),
                  child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: plan.features.map((f) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: AppColors.success, size: 14),
                  const SizedBox(width: 4),
                  Text(f, style: TextStyle(fontSize: 13, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                ],
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  const _ToggleOption({required this.label, required this.isActive, required this.onTap, required this.isDark, this.badge});
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isDark;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? (isDark ? AppColors.surfaceDark : Colors.white) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: isActive ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4)] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary) : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(999)),
                child: Text(badge!, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/models/universal_folder_models.dart';
import '../../core/services/platform_account_service.dart';
import '../../core/theme/app_colors.dart';

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key, this.onBack, this.onSelectPlan});

  final VoidCallback? onBack;
  final ValueChanged<String>? onSelectPlan;

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  final _account = PlatformAccountService.instance;
  late Future<List<PricingPlan>> _plansFuture;
  String? _selectedPlan;
  String? _message;
  bool _working = false;

  @override
  void initState() {
    super.initState();
    _plansFuture = _account.fetchPlans();
  }

  Future<void> _selectPlan(PricingPlan plan) async {
    setState(() {
      _selectedPlan = plan.code;
      _working = true;
      _message = null;
    });
    try {
      final session = await _account.createCheckoutSession(plan.code);
      await _account.activateDemoPlan(plan.code, reference: session.reference);
      if (!mounted) return;
      setState(() => _message = '${plan.name} is now active for this account.');
      widget.onSelectPlan?.call(plan.name);
    } catch (error) {
      if (!mounted) return;
      setState(() => _message = error.toString());
    } finally {
      if (mounted) {
        setState(() => _working = false);
      }
    }
  }

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
      body: FutureBuilder<List<PricingPlan>>(
        future: _plansFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load plans.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final plans = snapshot.data ?? const [];
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text('Choose your plan', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                const SizedBox(height: 8),
                Text(
                  'Subscriptions now come from the backend platform API.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                ),
                const SizedBox(height: 24),
                ...plans.map((plan) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _PlanCard(
                    plan: plan,
                    isSelected: _selectedPlan == plan.code,
                    onSelect: _working ? null : () => _selectPlan(plan),
                    isDark: isDark,
                  ),
                )),
                if (_message != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _message!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: _message!.contains('active') ? AppColors.success : AppColors.error,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.isSelected,
    required this.onSelect,
    required this.isDark,
  });

  final PricingPlan plan;
  final bool isSelected;
  final VoidCallback? onSelect;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final monthly = (plan.priceMonthlyCents / 100).toStringAsFixed(plan.priceMonthlyCents == 0 ? 0 : 2);

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
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plan.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(text: '\$$monthly', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary, letterSpacing: -1)),
                            TextSpan(text: '/mo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('${plan.storageQuotaGb} GB storage • ${plan.maxFileSizeMb} MB max file', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
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
              children: plan.features.map((feature) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: AppColors.success, size: 14),
                  const SizedBox(width: 4),
                  Text(feature, style: TextStyle(fontSize: 13, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                ],
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

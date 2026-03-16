import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_responsive.dart';
import '../../core/widgets/settings_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    this.onPricing,
    this.onPinSetup,
    this.onBiometrics,
    this.onCloudConnect,
    this.onBack,
  });

  final VoidCallback? onPricing;
  final VoidCallback? onPinSetup;
  final VoidCallback? onBiometrics;
  final VoidCallback? onCloudConnect;
  final VoidCallback? onBack;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pinEnabled = true;
  bool _biometrics = false;
  bool _incognito = false;
  String _theme = 'System';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark2 : AppColors.slate50,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack ?? () => Navigator.maybePop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile card
            Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark.withValues(alpha: 0.5) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.slate200),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                ),
                child: Row(
                  children: [
                    Container(
                      width: context.s(80),
                      height: context.s(80),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1), width: 3),
                      ),
                      child: const Icon(Icons.person, color: AppColors.primary, size: 40),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Alex Johnson', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                          const SizedBox(height: 2),
                          const Text('PREMIUM MEMBER', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                          const SizedBox(height: 2),
                          Text('alex.j@example.com', style: TextStyle(fontSize: 13, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(80, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Edit'),
                    ),
                  ],
                ),
              ),
            ),
            // Plans
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Storage Relief Plans', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _PlanCard(name: 'Starter', price: '\$1', isCurrentPlan: true, isDark: isDark, features: ['5GB Storage', 'Basic Compression']),
                        const SizedBox(width: 12),
                        _PlanCard(name: 'Basic', price: '\$2', isDark: isDark, features: ['20GB Storage', 'Standard Compression']),
                        const SizedBox(width: 12),
                        _PlanCard(name: 'Pro', price: '\$3', isPopular: true, isDark: isDark, features: ['100GB Storage', 'High Compression', 'No Ads']),
                        const SizedBox(width: 12),
                        _PlanCard(name: 'Ultra', price: '\$4', isDark: isDark, features: ['Unlimited Storage', 'Batch Processing', 'Priority Support']),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Security & Privacy
            _SectionCard(
              title: 'Security & Privacy',
              isDark: isDark,
              children: [
                SettingsTile(
                  icon: Icons.pin_outlined,
                  title: 'PIN Protection',
                  subtitle: 'Require PIN to open the app',
                  trailing: Switch(value: _pinEnabled, onChanged: (v) => setState(() => _pinEnabled = v)),
                ),
                Divider(height: 1, indent: 16, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                SettingsTile(
                  icon: Icons.fingerprint,
                  title: 'Biometric Authentication',
                  subtitle: 'Use TouchID or FaceID',
                  trailing: Switch(value: _biometrics, onChanged: (v) => setState(() => _biometrics = v)),
                ),
                Divider(height: 1, indent: 16, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                SettingsTile(
                  icon: Icons.visibility_off_outlined,
                  title: 'Incognito Compression',
                  subtitle: "Don't save history of files",
                  trailing: Switch(value: _incognito, onChanged: (v) => setState(() => _incognito = v)),
                ),
              ],
            ),
            // Appearance
            _SectionCard(
              title: 'Appearance',
              isDark: isDark,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.palette_outlined, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Theme Mode', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                              Text('Choose how the app looks to you', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.slate800 : AppColors.slate100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: ['Light', 'Dark', 'System'].map((t) {
                            final isActive = t == _theme;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _theme = t),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: isActive ? (isDark ? AppColors.surfaceDark : Colors.white) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: isActive ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4)] : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    t,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                                      color: isActive ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary) : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Account
            _SectionCard(
              title: 'Account',
              isDark: isDark,
              children: [
                SettingsTile(icon: Icons.cloud_outlined, title: 'Connect Cloud', subtitle: 'Google Drive, Dropbox...', trailing: const Icon(Icons.chevron_right, color: AppColors.textPrimary), onTap: widget.onCloudConnect),
                Divider(height: 1, indent: 16, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                SettingsTile(icon: Icons.notifications_outlined, title: 'Notifications', trailing: const Icon(Icons.chevron_right, color: AppColors.textPrimary)),
                Divider(height: 1, indent: 16, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                SettingsTile(icon: Icons.help_outline, title: 'Help & Support', trailing: const Icon(Icons.chevron_right, color: AppColors.textPrimary)),
                Divider(height: 1, indent: 16, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                SettingsTile(
                  icon: Icons.logout,
                  title: 'Log Out',
                  iconColor: AppColors.error,
                  iconBgColor: AppColors.errorLight,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.isDark, required this.children});
  final String title;
  final bool isDark;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark.withValues(alpha: 0.5) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.slate100),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.name,
    required this.price,
    required this.isDark,
    required this.features,
    this.isCurrentPlan = false,
    this.isPopular = false,
  });
  final String name;
  final String price;
  final bool isDark;
  final List<String> features;
  final bool isCurrentPlan;
  final bool isPopular;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark.withValues(alpha: 0.5) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isPopular ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.slate100),
                width: isPopular ? 2 : 1,
              ),
              boxShadow: isPopular ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.08), blurRadius: 16)] : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isPopular) const SizedBox(height: 8),
                Text(name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(text: price, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary, letterSpacing: -1)),
                      TextSpan(text: '/mo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (isCurrentPlan)
                  Container(
                    width: double.infinity,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: isDark ? AppColors.slate700 : AppColors.slate100, borderRadius: BorderRadius.circular(8)),
                    child: Text('Current', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                  )
                else if (isPopular)
                  Container(
                    width: double.infinity,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                    child: const Text('Upgrade Now', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  )
                else
                  Container(
                    width: double.infinity,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Upgrade', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                const SizedBox(height: 12),
                ...features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success, size: 14),
                      const SizedBox(width: 6),
                      Expanded(child: Text(f, style: TextStyle(fontSize: 11, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary))),
                    ],
                  ),
                )),
              ],
            ),
          ),
          if (isPopular)
            Positioned(
              top: -12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(999)),
                  child: const Text('Popular', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ),
            ),
          if (isCurrentPlan)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppColors.textPrimary, borderRadius: BorderRadius.circular(4)),
                child: const Text('Free', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ),
            ),
        ],
      ),
    );
  }
}

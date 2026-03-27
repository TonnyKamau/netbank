import 'package:flutter/material.dart';
import '../../core/services/biometric_service.dart';
import '../../core/services/pin_service.dart';
import '../../core/services/platform_auth_service.dart';
import '../../core/services/session_service.dart';
import '../../core/services/theme_service.dart';
import '../../core/models/universal_folder_models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_responsive.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/app_reveal.dart';
import '../../core/widgets/settings_tile.dart';
import '../auth/pin_entry_screen.dart';
import '../auth/pin_setup_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    this.onPricing,
    this.onPinSetup,
    this.onBiometrics,
    this.onCloudConnect,
    this.onBack,
    this.onNavigate,
  });

  final VoidCallback? onPricing;
  final VoidCallback? onPinSetup;
  final VoidCallback? onBiometrics;
  final VoidCallback? onCloudConnect;
  final VoidCallback? onBack;
  final ValueChanged<NavTab>? onNavigate;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pinEnabled = false;
  bool _biometrics = false;
  bool _incognito = false;
  bool _loadingAccount = false;
  PlatformUser? _user;

  @override
  void initState() {
    super.initState();
    _user = PlatformAuthService.instance.user;
    _loadSecurityState();
  }

  Future<void> _loadSecurityState() async {
    final pin = await PinService.isEnabled();
    final bio = await BiometricService.isEnabled();
    if (mounted) setState(() { _pinEnabled = pin; _biometrics = bio; });
  }

  Future<void> _loadAccountState() async {
    if (!PlatformAuthService.instance.isAuthenticated) return;
    setState(() => _loadingAccount = true);
    try {
      final refreshedUser = await PlatformAuthService.instance.refreshUser();
      if (!mounted) return;
      setState(() => _user = refreshedUser ?? _user);
    } catch (_) {
      if (!mounted) return;
      setState(() => _user = PlatformAuthService.instance.user);
    } finally {
      if (mounted) {
        setState(() => _loadingAccount = false);
      }
    }
  }

  Future<void> _logout() async {
    await PlatformAuthService.instance.logout();
    await SessionService.setLoggedIn(false);
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _onPinToggle(bool value) async {
    if (value) {
      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const PinSetupScreen()),
      );
      if (result == true && mounted) setState(() => _pinEnabled = true);
    } else {
      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => const PinEntryScreen(
            title: 'Verify PIN',
            subtitle: 'Enter your current PIN to disable it',
            onSuccessResult: true,
          ),
        ),
      );
      if (result == true && mounted) {
        await PinService.disable();
        await BiometricService.setEnabled(false);
        setState(() { _pinEnabled = false; _biometrics = false; });
      }
    }
  }

  Future<void> _onBiometricsToggle(bool value) async {
    if (value) {
      final available = await BiometricService.isAvailable();
      if (!available) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Biometrics not available on this device')),
          );
        }
        return;
      }
      final success = await BiometricService.authenticate(
        reason: 'Authenticate to enable biometrics for Universal Folder',
      );
      if (success && mounted) {
        await BiometricService.setEnabled(true);
        setState(() => _biometrics = true);
      }
    } else {
      await BiometricService.setEnabled(false);
      if (mounted) setState(() => _biometrics = false);
    }
  }

  String get _theme => switch (ThemeService.instance.value) {
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
    _ => 'System',
  };

  void _setTheme(String t) {
    final mode = switch (t) {
      'Light' => ThemeMode.light,
      'Dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    ThemeService.instance.setTheme(mode);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = _user;
    final reliefPlans = [
      const _PlanCardData(code: 'basic_20', name: 'Basic', price: '\$1', storage: '20GB', features: ['Device sync', 'Basic compression']),
      const _PlanCardData(code: 'plus_50', name: 'Plus', price: '\$2', storage: '50GB', features: ['Faster compression', 'History sync']),
      const _PlanCardData(code: 'pro_100', name: 'Pro', price: '\$3', storage: '100GB', features: ['Priority compression', 'Cloud backup'], isPopular: true),
      const _PlanCardData(code: 'max_150', name: 'Max', price: '\$4', storage: '150GB', features: ['Batch jobs', 'Smart restore']),
      const _PlanCardData(code: 'elite_250', name: 'Elite', price: '\$5', storage: '250GB', features: ['Large files', 'Shared history']),
      const _PlanCardData(code: 'power_350', name: 'Power', price: '\$6', storage: '350GB', features: ['Priority queue', 'Faster restore']),
      const _PlanCardData(code: 'ultra_500', name: 'Ultra', price: '\$8', storage: '500GB', features: ['Premium support', 'Full cloud sync']),
    ];
    final membershipLabel = user == null
        ? 'GUEST'
        : user.isAdmin
            ? 'ADMIN'
            : '${user.defaultPlanCode.toUpperCase()} MEMBER';

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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppReveal(
                    child: Padding(
                      padding: EdgeInsets.all(context.s(24)),
                      child: Container(
                        padding: EdgeInsets.all(context.s(20)),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark.withValues(alpha: 0.5) : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.slate200),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isCompact = constraints.maxWidth < 420;
                            final infoColumn = Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.fullName.isNotEmpty == true ? user!.fullName : 'Guest User',
                                  style: TextStyle(
                                    fontSize: context.s(18),
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: context.sh(2)),
                                Text(
                                  membershipLabel,
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: context.s(11),
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                SizedBox(height: context.sh(2)),
                                Text(
                                  user?.email ?? 'Not signed in',
                                  style: TextStyle(
                                    fontSize: context.s(13),
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                  ),
                                ),
                                if (_loadingAccount) ...[
                                  SizedBox(height: context.sh(8)),
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ],
                              ],
                            );

                            if (isCompact) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
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
                                      SizedBox(width: context.s(16)),
                                      Expanded(child: infoColumn),
                                    ],
                                  ),
                                  SizedBox(height: context.sh(16)),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: PlatformAuthService.instance.isAuthenticated ? _loadAccountState : null,
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: const Size(double.infinity, 42),
                                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                      child: const Text('Refresh'),
                                    ),
                                  ),
                                ],
                              );
                            }

                            return Row(
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
                                SizedBox(width: context.s(16)),
                                Expanded(child: infoColumn),
                                ElevatedButton(
                                  onPressed: PlatformAuthService.instance.isAuthenticated ? _loadAccountState : null,
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(80, 36),
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  child: const Text('Refresh'),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.s(24)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Storage Relief Plans',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: context.sh(16)),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: reliefPlans
                                .map((plan) => Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: _PlanCard(
                                        name: plan.name,
                                        price: plan.price,
                                        storage: plan.storage,
                                        isDark: isDark,
                                        features: plan.features,
                                        isPopular: plan.isPopular,
                                        isCurrentPlan: user?.defaultPlanCode == plan.code,
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SectionCard(
                    title: 'Security & Privacy',
                    isDark: isDark,
                    children: [
                      SettingsTile(
                        icon: Icons.pin_outlined,
                        title: 'PIN Protection',
                        subtitle: 'Require PIN to open the app',
                        trailing: Switch(value: _pinEnabled, onChanged: _onPinToggle),
                      ),
                      Divider(height: 1, indent: 16, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                      SettingsTile(
                        icon: Icons.fingerprint,
                        title: 'Biometric Authentication',
                        subtitle: 'Use TouchID or FaceID',
                        trailing: Switch(value: _biometrics, onChanged: _onBiometricsToggle),
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
                                      onTap: () => setState(() => _setTheme(t)),
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
                                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
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
                        onTap: _logout,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AppBottomNav(
            currentTab: NavTab.settings,
            onTap: widget.onNavigate ?? (_) {},
          ),
        ],
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
    required this.storage,
    required this.isDark,
    required this.features,
    this.isCurrentPlan = false,
    this.isPopular = false,
  });
  final String name;
  final String price;
  final String storage;
  final bool isDark;
  final List<String> features;
  final bool isCurrentPlan;
  final bool isPopular;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 182,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            constraints: const BoxConstraints(minHeight: 214),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
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
                if (isPopular)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Popular',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                Text(name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(text: price, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary, letterSpacing: -1)),
                      TextSpan(text: '/mo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$storage Storage',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
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
                ...features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 1),
                            child: Icon(Icons.check_circle, color: AppColors.success, size: 14),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              feature,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                height: 1.25,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
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

class _PlanCardData {
  const _PlanCardData({
    required this.code,
    required this.name,
    required this.price,
    required this.storage,
    required this.features,
    this.isPopular = false,
  });

  final String code;
  final String name;
  final String price;
  final String storage;
  final List<String> features;
  final bool isPopular;
}

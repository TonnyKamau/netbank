import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/app_responsive.dart';

enum NavTab { home, history, batch, settings }

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.currentTab, required this.onTap});

  final NavTab currentTab;
  final ValueChanged<NavTab> onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark.withValues(alpha: 0.96) : Colors.white.withValues(alpha: 0.96),
        border: Border(top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.s(12), vertical: context.s(8)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                isActive: currentTab == NavTab.home,
                onTap: () => onTap(NavTab.home),
              ),
              _NavItem(
                icon: Icons.history_outlined,
                activeIcon: Icons.history,
                label: 'History',
                isActive: currentTab == NavTab.history,
                onTap: () => onTap(NavTab.history),
              ),
              _NavItem(
                icon: Icons.auto_fix_high_outlined,
                activeIcon: Icons.auto_fix_high,
                label: 'Batch',
                isActive: currentTab == NavTab.batch,
                onTap: () => onTap(NavTab.batch),
              ),
              _NavItem(
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings,
                label: 'Settings',
                isActive: currentTab == NavTab.settings,
                onTap: () => onTap(NavTab.settings),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(horizontal: context.s(14), vertical: context.s(8)),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary.withValues(alpha: 0.14) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: isActive ? 1.08 : 1,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                child: Icon(
                  isActive ? activeIcon : icon,
                  color: isActive ? AppColors.primary : AppColors.slate400,
                  size: isActive ? context.s(31) : context.s(28),
                ),
              ),
              SizedBox(height: context.s(4)),
              Text(
                label,
                style: TextStyle(
                  fontSize: context.s(11),
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive ? AppColors.primary : AppColors.slate400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

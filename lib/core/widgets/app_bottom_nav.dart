import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

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
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? activeIcon : icon,
            color: isActive ? AppColors.primary : AppColors.slate400,
            size: 24,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? AppColors.primary : AppColors.slate400,
            ),
          ),
        ],
      ),
    );
  }
}

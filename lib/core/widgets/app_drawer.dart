import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/app_responsive.dart';
import 'app_bottom_nav.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
    this.onClose,
  });

  final NavTab currentTab;
  final ValueChanged<NavTab> onTabSelected;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(context.s(20), context.s(12), context.s(12), context.s(20)),
              child: Row(
                children: [
                  Container(
                    width: context.s(48),
                    height: context.s(48),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(context.s(16)),
                    ),
                    child: Icon(Icons.folder_copy_outlined, color: AppColors.primary, size: context.s(24)),
                  ),
                  SizedBox(width: context.s(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Universal Folder',
                          style: TextStyle(
                            fontSize: context.s(18),
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: context.sh(2)),
                        Text(
                          'Quick links',
                          style: TextStyle(
                            fontSize: context.s(12),
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onClose ?? () => Navigator.of(context).maybePop(),
                    icon: Icon(
                      Icons.close,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: context.s(12), vertical: context.s(12)),
                children: [
                  _DrawerItem(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    isActive: currentTab == NavTab.home,
                    onTap: () => _handleTap(context, NavTab.home),
                  ),
                  _DrawerItem(
                    icon: Icons.history_outlined,
                    label: 'History',
                    isActive: currentTab == NavTab.history,
                    onTap: () => _handleTap(context, NavTab.history),
                  ),
                  _DrawerItem(
                    icon: Icons.auto_fix_high_outlined,
                    label: 'Batch Compression',
                    isActive: currentTab == NavTab.batch,
                    onTap: () => _handleTap(context, NavTab.batch),
                  ),
                  _DrawerItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    isActive: currentTab == NavTab.settings,
                    onTap: () => _handleTap(context, NavTab.settings),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(context.s(20), context.s(8), context.s(20), context.s(20)),
              child: Text(
                'Use the links above to move around the app faster.',
                style: TextStyle(
                  fontSize: context.s(12),
                  height: 1.4,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, NavTab tab) {
    Navigator.of(context).pop();
    if (tab != currentTab) {
      onTabSelected(tab);
    }
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: context.sh(6)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(context.s(16)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(horizontal: context.s(14), vertical: context.sh(14)),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(context.s(16)),
              border: Border.all(
                color: isActive
                    ? AppColors.primary.withValues(alpha: 0.45)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: context.s(22),
                  color: isActive
                      ? AppColors.primary
                      : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                ),
                SizedBox(width: context.s(12)),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: context.s(14),
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive
                          ? AppColors.primary
                          : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                    ),
                  ),
                ),
                if (isActive)
                  Icon(Icons.arrow_forward_ios, size: context.s(14), color: AppColors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

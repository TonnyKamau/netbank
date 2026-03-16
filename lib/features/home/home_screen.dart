import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_responsive.dart';
import '../../core/widgets/app_bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onNavigate, this.onCompress});

  final ValueChanged<NavTab>? onNavigate;
  final VoidCallback? onCompress;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  NavTab _tab = NavTab.home;

  void _onTabTap(NavTab tab) {
    setState(() => _tab = tab);
    widget.onNavigate?.call(tab);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Column(
        children: [
          // Header
          Container(
            color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _onTabTap(NavTab.settings),
                  child: Icon(Icons.menu, color: isDark ? AppColors.slate300 : AppColors.slate700, size: 24),
                ),
                const Expanded(
                  child: Text(
                    'Netbank',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                GestureDetector(
                  onTap: () => _onTabTap(NavTab.settings),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                    child: const Icon(Icons.account_circle_outlined, color: AppColors.primary, size: 24),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, optimize your files',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Reduce file size without losing quality',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Storage card
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Storage Usage', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                              Text('65 GB / 100 GB', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: 0.65,
                              minHeight: 10,
                              backgroundColor: isDark ? AppColors.slate800 : AppColors.slate100,
                              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.info_outline, color: AppColors.primary, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                "You're using 65% of your total space",
                                style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Upload area
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GestureDetector(
                      onTap: widget.onCompress,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: context.sh(40)),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            style: BorderStyle.solid,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 12)],
                              ),
                              child: const Icon(Icons.upload_file, color: Colors.white, size: 30),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Upload or Select Files',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Supports PNG, JPG, PDF, MP4 and more',
                              style: TextStyle(fontSize: 13, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Categories
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Category',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _CategoryCard(icon: Icons.image_outlined, label: 'Photos', color: AppColors.emerald, bgColor: AppColors.emeraldLight, isDark: isDark)),
                            const SizedBox(width: 12),
                            Expanded(child: _CategoryCard(icon: Icons.videocam_outlined, label: 'Videos', color: AppColors.orange, bgColor: AppColors.orangeLight, isDark: isDark)),
                            const SizedBox(width: 12),
                            Expanded(child: _CategoryCard(icon: Icons.description_outlined, label: 'Docs', color: AppColors.blue, bgColor: AppColors.blueLight, isDark: isDark)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Recent history
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent History',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                              ),
                            ),
                            TextButton(
                              onPressed: () => _onTabTap(NavTab.history),
                              style: TextButton.styleFrom(padding: EdgeInsets.zero),
                              child: const Text('View All', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _HistoryItem(
                          icon: Icons.picture_as_pdf,
                          name: 'project_proposal.pdf',
                          details: '2.4 MB → 840 KB',
                          savings: '-65%',
                          isDark: isDark,
                        ),
                        const SizedBox(height: 8),
                        _HistoryItem(
                          icon: Icons.image_outlined,
                          name: 'vacation_photo.jpg',
                          details: '5.1 MB → 1.2 MB',
                          savings: '-76%',
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppBottomNav(currentTab: _tab, onTap: _onTabTap),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? color.withValues(alpha: 0.2) : bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  const _HistoryItem({
    required this.icon,
    required this.name,
    required this.details,
    required this.savings,
    required this.isDark,
  });

  final IconData icon;
  final String name;
  final String details;
  final String savings;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? AppColors.slate800 : AppColors.slate100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary), overflow: TextOverflow.ellipsis),
                Text(details, style: TextStyle(fontSize: 12, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.successLightDark : AppColors.successLight,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(savings, style: const TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

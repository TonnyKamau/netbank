import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_bottom_nav.dart';

class CompressionHistoryScreen extends StatefulWidget {
  const CompressionHistoryScreen({super.key, this.onNavigate, this.onDecompress});

  final ValueChanged<NavTab>? onNavigate;
  final VoidCallback? onDecompress;

  @override
  State<CompressionHistoryScreen> createState() => _CompressionHistoryScreenState();
}

class _CompressionHistoryScreenState extends State<CompressionHistoryScreen> {
  String _selectedFilter = 'All';
  final _filters = ['All', 'Photos', 'Videos', 'Docs', 'Audio'];

  final _items = [
    _HistoryItem(icon: Icons.folder_zip_outlined, name: 'vacation_photos.zip', date: 'Oct 24, 2023', saving: 'Saved 64%'),
    _HistoryItem(icon: Icons.movie_outlined, name: 'project_demo_4k.mp4', date: 'Oct 23, 2023', saving: 'Saved 42%'),
    _HistoryItem(icon: Icons.description_outlined, name: 'tax_returns_2023.pdf', date: 'Oct 22, 2023', saving: 'Restored'),
    _HistoryItem(icon: Icons.image_outlined, name: 'family_reunion.jpg', date: 'Oct 21, 2023', saving: 'Saved 71%'),
    _HistoryItem(icon: Icons.audio_file_outlined, name: 'podcast_episode_12.mp3', date: 'Oct 20, 2023', saving: 'Saved 55%'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Column(
        children: [
          // Header
          Container(
            color: isDark ? AppColors.backgroundDark.withValues(alpha: 0.8) : AppColors.backgroundLight.withValues(alpha: 0.8),
            padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 12),
            child: Row(
              children: [
                Icon(Icons.menu, color: isDark ? Colors.white : AppColors.textPrimary, size: 24),
                Expanded(
                  child: Text(
                    'History',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.slate800 : AppColors.slate100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.account_circle_outlined, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary, size: 24),
                ),
              ],
            ),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Search bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.slate800 : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(Icons.search, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary, size: 20),
                          ),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search past tasks...',
                                hintStyle: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary, fontSize: 14),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                filled: false,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Filter chips
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 52,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: _filters.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final isActive = _filters[i] == _selectedFilter;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedFilter = _filters[i]),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isActive ? AppColors.primary : (isDark ? AppColors.slate800 : AppColors.slate100),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              _filters[i],
                              style: TextStyle(
                                color: isActive ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                                fontSize: 13,
                                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Section header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'RECENT TASKS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                        ),
                        Text('Clear all', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primary)),
                      ],
                    ),
                  ),
                ),
                // Items
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _HistoryCard(item: _items[i], isDark: isDark, onTap: widget.onDecompress),
                      ),
                      childCount: _items.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppBottomNav(
            currentTab: NavTab.history,
            onTap: widget.onNavigate ?? (_) {},
          ),
        ],
      ),
    );
  }
}

class _HistoryItem {
  const _HistoryItem({required this.icon, required this.name, required this.date, required this.saving});
  final IconData icon;
  final String name;
  final String date;
  final String saving;
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.item, required this.isDark, this.onTap});
  final _HistoryItem item;
  final bool isDark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate800.withValues(alpha: 0.3) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? AppColors.slate700 : AppColors.slate50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? AppColors.slate600 : AppColors.slate100),
            ),
            child: Icon(item.icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 12, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                    children: [
                      TextSpan(text: '${item.date} '),
                      TextSpan(text: '(${item.saving})', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
        ],
      ),
    ),
    );
  }
}


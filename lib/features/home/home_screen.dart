import 'package:flutter/material.dart';

import '../../core/models/universal_folder_models.dart';
import '../../core/services/local_file_service.dart';
import '../../core/services/operation_flow_service.dart';
import '../../core/services/universal_folder_api.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_responsive.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/app_reveal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onNavigate, this.onCompress});

  final ValueChanged<NavTab>? onNavigate;
  final VoidCallback? onCompress;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _flow = OperationFlowService.instance;
  final _localFiles = LocalFileService.instance;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late Future<BackendStats> _statsFuture;
  late Future<List<StoredFileItem>> _recentFilesFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = UniversalFolderApi.instance.fetchStats();
    _recentFilesFuture = _localFiles.listSavedFiles();
    _flow.addListener(_handleFlowChange);
  }

  @override
  void dispose() {
    _flow.removeListener(_handleFlowChange);
    super.dispose();
  }

  void _handleFlowChange() {
    if (!mounted) return;
    setState(() {
      _statsFuture = UniversalFolderApi.instance.fetchStats();
      _recentFilesFuture = _localFiles.listSavedFiles();
    });
  }

  void _onTabTap(NavTab tab) {
    widget.onNavigate?.call(tab);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontal = context.s(16);
    final cardWidth = context.isTablet
        ? (context.screenWidth - horizontal * 2 - context.s(24)) / 3
        : (context.screenWidth - horizontal * 2 - context.s(24)) / 3;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      drawer: AppDrawer(
        currentTab: NavTab.home,
        onTabSelected: _onTabTap,
      ),
      body: Column(
        children: [
          Container(
            color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            padding: EdgeInsets.fromLTRB(horizontal, MediaQuery.of(context).padding.top + context.s(8), horizontal, context.s(12)),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  icon: Icon(Icons.menu, color: isDark ? AppColors.slate300 : AppColors.slate700, size: context.s(28)),
                ),
                Expanded(
                  child: Text(
                    'Universal Folder',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: context.s(18), fontWeight: FontWeight.bold),
                  ),
                ),
                InkWell(
                  onTap: () => _onTabTap(NavTab.settings),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: context.s(42),
                    height: context.s(42),
                    decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                    child: Icon(Icons.account_circle_outlined, color: AppColors.primary, size: context.s(24)),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: context.sh(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppReveal(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(horizontal, context.sh(20), horizontal, context.sh(4)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, optimize your files',
                            style: TextStyle(
                              fontSize: context.s(22),
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: context.sh(4)),
                          Text(
                            'Fast compression, quick restore, and local device storage that stays easy to manage.',
                            style: TextStyle(
                              fontSize: context.s(13),
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AppReveal(
                    animate: false,
                    delay: const Duration(milliseconds: 80),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(horizontal, context.sh(12), horizontal, context.sh(4)),
                      child: FutureBuilder<BackendStats>(
                        future: _statsFuture,
                        builder: (context, snapshot) {
                          final stats = snapshot.data;
                          if (snapshot.connectionState == ConnectionState.waiting || stats == null) {
                            return const SizedBox.shrink();
                          }

                          return Container(
                            padding: EdgeInsets.all(context.s(18)),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceDark : Colors.white,
                              borderRadius: BorderRadius.circular(context.s(20)),
                              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'System Health',
                                      style: TextStyle(
                                        fontSize: context.s(13),
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                      ),
                                    ),
                                    AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 220),
                                      child: Text(
                                        stats.systemStatus,
                                        key: ValueKey(stats.systemStatus),
                                        style: TextStyle(
                                          fontSize: context.s(12),
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: context.sh(12)),
                                Wrap(
                                  spacing: context.s(10),
                                  runSpacing: context.sh(10),
                                  children: [
                                    SizedBox(width: cardWidth, child: _MiniStat(label: 'Ratio', value: '${stats.ratio}:1', isDark: isDark)),
                                    SizedBox(width: cardWidth, child: _MiniStat(label: 'Heat', value: '${stats.heatReduction}%', isDark: isDark)),
                                    SizedBox(width: cardWidth, child: _MiniStat(label: 'Tips', value: '${stats.activeTips}', isDark: isDark)),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  AppReveal(
                    delay: const Duration(milliseconds: 140),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(horizontal, context.sh(16), horizontal, 0),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: widget.onCompress,
                          borderRadius: BorderRadius.circular(context.s(24)),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: context.sh(220)),
                            child: Ink(
                              width: double.infinity,
                              padding: EdgeInsets.fromLTRB(context.s(24), context.sh(28), context.s(24), context.sh(24)),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surfaceDark : AppColors.primary.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(context.s(24)),
                                border: Border.all(
                                  color: isDark ? AppColors.primary.withValues(alpha: 0.4) : AppColors.primary.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: isDark ? 0.12 : 0.08),
                                    blurRadius: 18,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0.96, end: 1),
                                    duration: const Duration(milliseconds: 520),
                                    curve: Curves.easeOutBack,
                                    builder: (context, value, child) => Transform.scale(scale: value, child: child),
                                    child: Container(
                                      width: context.s(84),
                                      height: context.s(84),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.28), blurRadius: 18)],
                                      ),
                                      child: Icon(Icons.upload_file_rounded, color: Colors.white, size: context.s(34)),
                                    ),
                                  ),
                                  SizedBox(height: context.sh(22)),
                                  Text(
                                    'Upload or Select Files',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: context.s(22),
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: context.sh(10)),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: context.isTablet ? 430 : 280),
                                    child: Text(
                                      'Tap to pick a file from your device and send it through Universal Folder with a smoother, faster workflow.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: context.s(14),
                                        height: 1.45,
                                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  AppReveal(
                    delay: const Duration(milliseconds: 200),
                    child: Padding(
                      padding: EdgeInsets.all(horizontal),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Category',
                            style: TextStyle(
                              fontSize: context.s(16),
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: context.sh(16)),
                          Wrap(
                            spacing: context.s(12),
                            runSpacing: context.sh(12),
                            children: [
                              SizedBox(width: cardWidth, child: _CategoryCard(icon: Icons.image_outlined, label: 'Photos', color: AppColors.emerald, bgColor: AppColors.emeraldLight, isDark: isDark)),
                              SizedBox(width: cardWidth, child: _CategoryCard(icon: Icons.videocam_outlined, label: 'Videos', color: AppColors.orange, bgColor: AppColors.orangeLight, isDark: isDark)),
                              SizedBox(width: cardWidth, child: _CategoryCard(icon: Icons.description_outlined, label: 'Docs', color: AppColors.blue, bgColor: AppColors.blueLight, isDark: isDark)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  AppReveal(
                    delay: const Duration(milliseconds: 260),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(horizontal, 0, horizontal, context.sh(24)),
                      child: FutureBuilder<List<StoredFileItem>>(
                        future: _recentFilesFuture,
                        builder: (context, snapshot) {
                          final files = (snapshot.data ?? const <StoredFileItem>[]).take(3).toList();

                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Recent History',
                                    style: TextStyle(
                                      fontSize: context.s(16),
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => _onTabTap(NavTab.history),
                                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                    child: Text(
                                      'View All',
                                      style: TextStyle(color: AppColors.primary, fontSize: context.s(13), fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: context.sh(8)),
                              if (files.isEmpty && _flow.lastDecompression == null)
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(context.s(16)),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.surfaceDark : Colors.white,
                                    borderRadius: BorderRadius.circular(context.s(14)),
                                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                                  ),
                                  child: Text(
                                    'Files saved on your device will appear here after compression or restore.',
                                    style: TextStyle(
                                      fontSize: context.s(13),
                                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                    ),
                                  ),
                                )
                              else ...[
                                for (var index = 0; index < files.length; index++)
                                  Padding(
                                    padding: EdgeInsets.only(top: index == 0 ? 0 : context.sh(8)),
                                    child: _HistoryItem(
                                      icon: _iconForName(files[index].name),
                                      name: files[index].name,
                                      details: 'Saved on device - ${_formatBytes(files[index].size)}',
                                      savings: files[index].isCompressedAsset || files[index].isFolderArchive ? 'Saved' : 'Ready',
                                      isDark: isDark,
                                    ),
                                  ),
                                if (_flow.lastDecompression != null && !files.any((item) => item.name == _flow.lastDecompression!.filename))
                                  Padding(
                                    padding: EdgeInsets.only(top: context.sh(8)),
                                    child: _HistoryItem(
                                      icon: Icons.unarchive_outlined,
                                      name: _flow.lastDecompression!.filename,
                                      details: 'Restored ${_formatBytes(_flow.lastDecompression!.size)}',
                                      savings: 'Ready',
                                      isDark: isDark,
                                    ),
                                  ),
                              ],
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppBottomNav(currentTab: NavTab.home, onTap: _onTabTap),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.isDark,
  });

  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: EdgeInsets.symmetric(vertical: context.sh(10), horizontal: context.s(8)),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate800.withValues(alpha: 0.45) : AppColors.slate50,
        borderRadius: BorderRadius.circular(context.s(14)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: context.s(16),
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: context.sh(4)),
          Text(
            label,
            style: TextStyle(
              fontSize: context.s(11),
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

IconData _iconForName(String name) {
  final lower = name.toLowerCase();
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.png') || lower.endsWith('.webp')) {
    return Icons.image_outlined;
  }
  if (lower.endsWith('.mp4') || lower.endsWith('.mov') || lower.endsWith('.mkv')) {
    return Icons.videocam_outlined;
  }
  if (lower.endsWith('.pdf') || lower.endsWith('.doc') || lower.endsWith('.docx') || lower.endsWith('.txt')) {
    return Icons.description_outlined;
  }
  if (lower.endsWith('.uf') || lower.endsWith('.ufd')) {
    return Icons.compress;
  }
  return Icons.insert_drive_file_outlined;
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(context.s(14)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: EdgeInsets.symmetric(vertical: context.sh(16)),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(context.s(14)),
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          child: Column(
            children: [
              Container(
                width: context.s(48),
                height: context.s(48),
                decoration: BoxDecoration(
                  color: isDark ? color.withValues(alpha: 0.2) : bgColor,
                  borderRadius: BorderRadius.circular(context.s(10)),
                ),
                child: Icon(icon, color: color, size: context.s(24)),
              ),
              SizedBox(height: context.sh(8)),
              Text(
                label,
                style: TextStyle(
                  fontSize: context.s(12),
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
            ],
          ),
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
      padding: EdgeInsets.all(context.s(12)),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(context.s(10)),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: context.s(40),
            height: context.s(40),
            decoration: BoxDecoration(
              color: isDark ? AppColors.slate800 : AppColors.slate100,
              borderRadius: BorderRadius.circular(context.s(8)),
            ),
            child: Icon(icon, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary, size: context.s(20)),
          ),
          SizedBox(width: context.s(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontSize: context.s(13), fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary), overflow: TextOverflow.ellipsis),
                Text(details, style: TextStyle(fontSize: context.s(12), color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: context.s(8), vertical: context.sh(4)),
            decoration: BoxDecoration(
              color: savings == 'Ready'
                  ? (isDark ? AppColors.primary.withValues(alpha: 0.16) : AppColors.primaryLight)
                  : (isDark ? AppColors.successLightDark : AppColors.successLight),
              borderRadius: BorderRadius.circular(context.s(6)),
            ),
            child: Text(
              savings,
              style: TextStyle(
                color: savings == 'Ready' ? AppColors.primary : AppColors.success,
                fontSize: context.s(12),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatBytes(int bytes) {
  if (bytes <= 0) return '0 B';
  const units = ['B', 'KB', 'MB', 'GB'];
  double value = bytes.toDouble();
  var index = 0;
  while (value >= 1024 && index < units.length - 1) {
    value /= 1024;
    index++;
  }
  return '${value.toStringAsFixed(value >= 100 ? 0 : 1)} ${units[index]}';
}

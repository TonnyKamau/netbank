import 'package:flutter/material.dart';

import '../../core/models/universal_folder_models.dart';
import '../../core/services/local_file_service.dart';
import '../../core/services/operation_flow_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_responsive.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/app_reveal.dart';

class CompressionHistoryScreen extends StatefulWidget {
  const CompressionHistoryScreen({super.key, this.onNavigate, this.onDecompress});

  final ValueChanged<NavTab>? onNavigate;
  final VoidCallback? onDecompress;

  @override
  State<CompressionHistoryScreen> createState() => _CompressionHistoryScreenState();
}

class _CompressionHistoryScreenState extends State<CompressionHistoryScreen> {
  final _localFiles = LocalFileService.instance;
  final _flow = OperationFlowService.instance;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<List<StoredFileItem>> _futureFiles;
  String _selectedFilter = 'All';
  final _filters = ['All', 'UFLD', 'UF', 'Archives'];

  @override
  void initState() {
    super.initState();
    _futureFiles = _loadCompressedFiles();
  }

  Future<List<StoredFileItem>> _loadCompressedFiles() async {
    final files = await _localFiles.listSavedFiles();
    return files.where((item) => item.canBeDecompressed).toList();
  }

  void _reload() {
    setState(() {
      _futureFiles = _loadCompressedFiles();
    });
  }

  List<StoredFileItem> _applyFilter(List<StoredFileItem> items) {
    return switch (_selectedFilter) {
      'UFLD' => items.where((item) => item.name.toLowerCase().endsWith('.ufd')).toList(),
      'UF' => items.where((item) => item.name.toLowerCase().endsWith('.uf')).toList(),
      'Archives' => items.where((item) => item.name.toLowerCase().endsWith('.zip') || item.name.toLowerCase().endsWith('.ufd')).toList(),
      _ => items.where((item) => item.canBeDecompressed).toList(),
    };
  }

  void _startDecompression(StoredFileItem item) {
    _flow.setPendingDecompression(
      fileName: item.name,
      filePath: item.path ?? item.name,
    );
    widget.onDecompress?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontal = context.s(16);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      drawer: AppDrawer(
        currentTab: NavTab.history,
        onTabSelected: widget.onNavigate ?? (_) {},
      ),
      body: Column(
        children: [
          Container(
            color: isDark ? AppColors.backgroundDark.withValues(alpha: 0.8) : AppColors.backgroundLight.withValues(alpha: 0.8),
            padding: EdgeInsets.fromLTRB(horizontal, MediaQuery.of(context).padding.top + context.s(8), horizontal, context.s(12)),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  icon: Icon(Icons.menu, color: isDark ? Colors.white : AppColors.textPrimary, size: context.s(24)),
                ),
                Expanded(
                  child: Text(
                    'History',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: context.s(18),
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _reload,
                  icon: Icon(Icons.refresh, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                ),
              ],
            ),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: AppReveal(
                    child: SizedBox(
                      height: context.sh(56),
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: context.sh(8)),
                        itemCount: _filters.length,
                        separatorBuilder: (_, _) => SizedBox(width: context.s(8)),
                        itemBuilder: (context, i) {
                          final isActive = _filters[i] == _selectedFilter;
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => setState(() => _selectedFilter = _filters[i]),
                              borderRadius: BorderRadius.circular(999),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: EdgeInsets.symmetric(horizontal: context.s(18)),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isActive ? AppColors.primary : (isDark ? AppColors.slate800 : AppColors.slate100),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  _filters[i],
                                  style: TextStyle(
                                    color: isActive ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                                    fontSize: context.s(13),
                                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: AppReveal(
                    delay: const Duration(milliseconds: 70),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: context.sh(8)),
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        runSpacing: context.sh(6),
                        spacing: context.s(12),
                        children: [
                          Text(
                            'SAVED ON THIS DEVICE',
                            style: TextStyle(
                              fontSize: context.s(12),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Tap a compressed file to restore it',
                            style: TextStyle(
                              fontSize: context.s(12),
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                FutureBuilder<List<StoredFileItem>>(
                  future: _futureFiles,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasError) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(context.s(24)),
                            child: Text(
                              'Could not load files saved on this device.\n${snapshot.error}',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    }

                    final items = _applyFilter(snapshot.data ?? const <StoredFileItem>[]);
                    if (items.isEmpty) {
                      return const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: Text('No saved files yet. Compress a file first.')),
                      );
                    }

                    return SliverPadding(
                      padding: EdgeInsets.fromLTRB(horizontal, 0, horizontal, context.sh(16)),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) => AppReveal(
                            delay: Duration(milliseconds: 120 + (i * 45)),
                            child: Padding(
                              padding: EdgeInsets.only(bottom: context.sh(12)),
                              child: _HistoryCard(
                                item: items[i],
                                isDark: isDark,
                                onTap: () => _startDecompression(items[i]),
                              ),
                            ),
                          ),
                          childCount: items.length,
                        ),
                      ),
                    );
                  },
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

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.item, required this.isDark, this.onTap});

  final StoredFileItem item;
  final bool isDark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.s(16)),
        child: Ink(
          padding: EdgeInsets.all(context.s(12)),
          decoration: BoxDecoration(
            color: isDark ? AppColors.slate800.withValues(alpha: 0.3) : Colors.white,
            borderRadius: BorderRadius.circular(context.s(16)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
          ),
          child: Row(
            children: [
              Container(
                width: context.s(48),
                height: context.s(48),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.slate700 : AppColors.slate50,
                  borderRadius: BorderRadius.circular(context.s(12)),
                  border: Border.all(color: isDark ? AppColors.slate600 : AppColors.slate100),
                ),
                child: Icon(_iconForItem(item), color: AppColors.primary, size: context.s(24)),
              ),
              SizedBox(width: context.s(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: TextStyle(fontSize: context.s(14), fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary), overflow: TextOverflow.ellipsis),
                    SizedBox(height: context.sh(2)),
                    Text(
                      '${_formatDate(item.modifiedAt)} - ${_formatBytes(item.size)}',
                      style: TextStyle(fontSize: context.s(12), color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _iconForItem(StoredFileItem item) {
  if (item.name.toLowerCase().endsWith('.ufd')) return Icons.folder_zip_outlined;
  if (item.name.toLowerCase().endsWith('.uf')) return Icons.compress;
  if (item.name.toLowerCase().endsWith('.zip')) return Icons.archive_outlined;
  return Icons.insert_drive_file_outlined;
}

String _formatDate(DateTime value) {
  final month = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][value.month];
  return '$month ${value.day}, ${value.year}';
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

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';

class SelectFilesScreen extends StatefulWidget {
  const SelectFilesScreen({super.key, this.onDecompress, this.onBack});

  final VoidCallback? onDecompress;
  final VoidCallback? onBack;

  @override
  State<SelectFilesScreen> createState() => _SelectFilesScreenState();
}

class _SelectFilesScreenState extends State<SelectFilesScreen> {
  final _selected = <String>{};
  String _activeTab = 'Files';
  final _tabs = ['Files', 'Photos', 'Downloads'];

  final _files = [
    _File(icon: Icons.folder_zip_outlined, name: 'vacation_photos.zip', size: '44.8 MB', date: 'Oct 24'),
    _File(icon: Icons.folder_zip_outlined, name: 'project_assets.zip', size: '78 MB', date: 'Oct 22'),
    _File(icon: Icons.archive_outlined, name: 'documents_backup.tar', size: '112 MB', date: 'Oct 20'),
    _File(icon: Icons.folder_zip_outlined, name: 'music_collection.zip', size: '234 MB', date: 'Oct 18'),
    _File(icon: Icons.archive_outlined, name: 'code_archive.gz', size: '8.3 MB', date: 'Oct 15'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Select Files to Decompress'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack ?? () => Navigator.maybePop(context),
        ),
        actions: [
          TextButton(
            onPressed: () => setState(() {
              if (_selected.length == _files.length) {
                _selected.clear();
              } else {
                _selected.addAll(_files.map((f) => f.name));
              }
            }),
            child: const Text('Select All', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab bar
          Container(
            height: 48,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.slate800 : AppColors.slate100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: _tabs.map((tab) {
                final isActive = tab == _activeTab;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _activeTab = tab),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isActive ? (isDark ? AppColors.surfaceDark : Colors.white) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: isActive ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4)] : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        tab,
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
          // File list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _files.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final file = _files[i];
                final isSelected = _selected.contains(file.name);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (isSelected) { _selected.remove(file.name); } else { _selected.add(file.name); }
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.borderLight),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.slate800 : AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(file.icon, color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(file.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary), overflow: TextOverflow.ellipsis),
                              Text('${file.size} • ${file.date}', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                            ],
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 150),
                          child: isSelected
                              ? const Icon(Icons.check_circle, color: AppColors.primary, size: 22, key: ValueKey(true))
                              : Icon(Icons.radio_button_unchecked, color: isDark ? AppColors.slate500 : AppColors.slate300, size: 22, key: const ValueKey(false)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Bottom action
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).padding.bottom + 16),
            child: PrimaryButton(
              label: _selected.isEmpty ? 'Select files to decompress' : 'Decompress (${_selected.length})',
              onPressed: _selected.isNotEmpty ? widget.onDecompress : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _File {
  const _File({required this.icon, required this.name, required this.size, required this.date});
  final IconData icon;
  final String name;
  final String size;
  final String date;
}

class DecompressionProgressScreen extends StatefulWidget {
  const DecompressionProgressScreen({super.key, this.fileName = 'vacation_photos.zip', this.onComplete, this.onCancel});

  final String fileName;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;

  @override
  State<DecompressionProgressScreen> createState() => _DecompressionProgressScreenState();
}

class _DecompressionProgressScreenState extends State<DecompressionProgressScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 300), widget.onComplete);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Decompressing'),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: widget.onCancel ?? () => Navigator.maybePop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                    child: const Icon(Icons.folder_zip_outlined, color: AppColors.primary, size: 48),
                  ),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (_, _) => SizedBox(
                      width: 112,
                      height: 112,
                      child: CircularProgressIndicator(
                        value: _controller.value,
                        strokeWidth: 4,
                        backgroundColor: isDark ? AppColors.slate800 : AppColors.slate200,
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(widget.fileName, textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
            const SizedBox(height: 40),
            AnimatedBuilder(
              animation: _controller,
              builder: (_, _) {
                final pct = (_controller.value * 100).toInt();
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Extracting...', style: TextStyle(fontSize: 14, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                        Text('$pct%', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: _controller.value,
                        minHeight: 10,
                        backgroundColor: isDark ? AppColors.slate800 : AppColors.slate100,
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                  ],
                );
              },
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: widget.onCancel,
              style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/primary_button.dart';

class BatchCompressionScreen extends StatefulWidget {
  const BatchCompressionScreen({super.key, this.onNavigate, this.onStartBatch});

  final ValueChanged<NavTab>? onNavigate;
  final VoidCallback? onStartBatch;

  @override
  State<BatchCompressionScreen> createState() => _BatchCompressionScreenState();
}

class _BatchCompressionScreenState extends State<BatchCompressionScreen> {
  final _selectedFiles = <String>{};
  double _quality = 0.7;

  final _files = [
    _FileItem(icon: Icons.image_outlined, name: 'profile_photo.jpg', size: '4.2 MB', type: 'Photo'),
    _FileItem(icon: Icons.movie_outlined, name: 'birthday_video.mp4', size: '128 MB', type: 'Video'),
    _FileItem(icon: Icons.picture_as_pdf_outlined, name: 'contract_v2.pdf', size: '12 MB', type: 'Doc'),
    _FileItem(icon: Icons.image_outlined, name: 'screenshot_2023.png', size: '2.1 MB', type: 'Photo'),
    _FileItem(icon: Icons.description_outlined, name: 'report_final.docx', size: '3.8 MB', type: 'Doc'),
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
            color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 12),
            child: Row(
              children: [
                Icon(Icons.arrow_back, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                Expanded(
                  child: Text(
                    'Batch Compression',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                  ),
                ),
                Icon(Icons.add_circle_outline, color: AppColors.primary, size: 24),
              ],
            ),
          ),
          Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(label: 'Files', value: '${_files.length}', isDark: isDark),
                        Container(width: 1, height: 32, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                        _StatItem(label: 'Total', value: '150 MB', isDark: isDark),
                        Container(width: 1, height: 32, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                        _StatItem(label: 'Est. Save', value: '~70%', isDark: isDark, valueColor: AppColors.success),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Quality slider
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Compression Quality', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                            Text('${(_quality * 100).toInt()}%', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                        Slider(
                          value: _quality,
                          onChanged: (v) => setState(() => _quality = v),
                          activeColor: AppColors.primary,
                          inactiveColor: isDark ? AppColors.slate700 : AppColors.slate200,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Max Compression', style: TextStyle(fontSize: 11, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                            Text('Best Quality', style: TextStyle(fontSize: 11, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // File list
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Files to Compress', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                      TextButton(
                        onPressed: () => setState(() {
                          if (_selectedFiles.length == _files.length) {
                            _selectedFiles.clear();
                          } else {
                            _selectedFiles.addAll(_files.map((f) => f.name));
                          }
                        }),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: Text(
                          _selectedFiles.length == _files.length ? 'Deselect All' : 'Select All',
                          style: const TextStyle(color: AppColors.primary, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._files.map((file) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _FileCard(
                      file: file,
                      isSelected: _selectedFiles.contains(file.name),
                      onToggle: () => setState(() {
                        if (_selectedFiles.contains(file.name)) {
                          _selectedFiles.remove(file.name);
                        } else {
                          _selectedFiles.add(file.name);
                        }
                      }),
                      isDark: isDark,
                    ),
                  )),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: 'Start Batch Compression (${_selectedFiles.length})',
                    onPressed: _selectedFiles.isNotEmpty ? widget.onStartBatch : null,
                  ),
                ],
              ),
            ),
          ),
          AppBottomNav(
            currentTab: NavTab.batch,
            onTap: widget.onNavigate ?? (_) {},
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value, required this.isDark, this.valueColor});
  final String label;
  final String value;
  final bool isDark;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: valueColor ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary))),
        Text(label, style: TextStyle(fontSize: 12, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
      ],
    );
  }
}

class _FileItem {
  const _FileItem({required this.icon, required this.name, required this.size, required this.type});
  final IconData icon;
  final String name;
  final String size;
  final String type;
}

class _FileCard extends StatelessWidget {
  const _FileCard({required this.file, required this.isSelected, required this.onToggle, required this.isDark});
  final _FileItem file;
  final bool isSelected;
  final VoidCallback onToggle;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: isDark ? AppColors.slate800 : AppColors.slate100, borderRadius: BorderRadius.circular(8)),
              child: Icon(file.icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(file.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary), overflow: TextOverflow.ellipsis),
                  Text(file.size, style: TextStyle(fontSize: 12, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
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
  }
}

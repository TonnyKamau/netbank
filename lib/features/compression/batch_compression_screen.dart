import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/services/operation_flow_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_responsive.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/app_reveal.dart';
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
  final _files = <_FileItem>[];
  double _quality = 0.7;

  int get _totalBytes => _files.fold(0, (sum, file) => sum + file.sizeBytes);

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (!mounted || result == null) return;

    final files = result.files
        .where((file) => (file.path ?? '').isNotEmpty)
        .map(
          (file) => _FileItem(
            icon: _iconForName(file.name),
            name: file.name,
            sizeBytes: file.size,
            type: _typeForName(file.name),
            path: file.path!,
          ),
        )
        .toList();

    if (!mounted) return;
    setState(() {
      _files
        ..clear()
        ..addAll(files);
      _selectedFiles
        ..clear()
        ..addAll(files.map((file) => file.name));
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedFiles.length == _files.length) {
        _selectedFiles.clear();
      } else {
        _selectedFiles.addAll(_files.map((f) => f.name));
      }
    });
  }

  void _startCompression() {
    if (_selectedFiles.isEmpty) return;
    final file = _files.firstWhere((item) => _selectedFiles.contains(item.name));
    OperationFlowService.instance.setPendingCompression(
      filePath: file.path,
      fileName: file.name,
    );
    widget.onStartBatch?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontal = context.s(16);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Column(
        children: [
          Container(
            color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            padding: EdgeInsets.fromLTRB(horizontal, MediaQuery.of(context).padding.top + context.s(8), horizontal, context.s(12)),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => widget.onNavigate?.call(NavTab.home),
                  icon: Icon(Icons.arrow_back, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                ),
                Expanded(
                  child: Text(
                    'Batch Compression',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: context.s(18),
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _pickFiles,
                  icon: Icon(Icons.add_circle_outline, color: AppColors.primary, size: context.s(24)),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(horizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppReveal(
                    child: Container(
                      padding: EdgeInsets.all(context.s(16)),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(context.s(16)),
                        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                      ),
                      child: Wrap(
                        spacing: context.s(12),
                        runSpacing: context.sh(12),
                        alignment: WrapAlignment.spaceAround,
                        children: [
                          _StatItem(label: 'Files', value: '${_files.length}', isDark: isDark),
                          _StatItem(label: 'Total', value: _formatBytes(_totalBytes), isDark: isDark),
                          _StatItem(label: 'Source', value: _files.isEmpty ? 'Device' : 'Live', isDark: isDark, valueColor: AppColors.success),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: context.sh(20)),
                  AppReveal(
                    delay: const Duration(milliseconds: 70),
                    child: Container(
                      padding: EdgeInsets.all(context.s(16)),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(context.s(16)),
                        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Compression Quality',
                                style: TextStyle(
                                  fontSize: context.s(14),
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '${(_quality * 100).toInt()}%',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: context.s(14),
                                ),
                              ),
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
                              Text('Max Compression', style: TextStyle(fontSize: context.s(11), color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                              Text('Best Quality', style: TextStyle(fontSize: context.s(11), color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: context.sh(20)),
                  AppReveal(
                    delay: const Duration(milliseconds: 130),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Files to Compress',
                          style: TextStyle(
                            fontSize: context.s(15),
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                        ),
                        Wrap(
                          spacing: context.s(8),
                          children: [
                            TextButton(
                              onPressed: _pickFiles,
                              style: TextButton.styleFrom(padding: EdgeInsets.zero),
                              child: Text('Pick Files', style: TextStyle(color: AppColors.primary, fontSize: context.s(13))),
                            ),
                            TextButton(
                              onPressed: _files.isEmpty ? null : _toggleSelectAll,
                              style: TextButton.styleFrom(padding: EdgeInsets.zero),
                              child: Text(
                                _selectedFiles.length == _files.length ? 'Deselect All' : 'Select All',
                                style: TextStyle(color: AppColors.primary, fontSize: context.s(13)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.sh(8)),
                  if (_files.isEmpty)
                    AppReveal(
                      delay: const Duration(milliseconds: 180),
                      child: Container(
                        padding: EdgeInsets.all(context.s(20)),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(context.s(16)),
                          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                        ),
                        child: Text(
                          'Pick a file from your device to send it to the Universal Folder backend for real compression.',
                          style: TextStyle(fontSize: context.s(13), color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                        ),
                      ),
                    )
                  else
                    ..._files.asMap().entries.map(
                      (entry) => AppReveal(
                        delay: Duration(milliseconds: 180 + entry.key * 35),
                        child: Padding(
                          padding: EdgeInsets.only(bottom: context.sh(8)),
                          child: _FileCard(
                            file: entry.value,
                            isSelected: _selectedFiles.contains(entry.value.name),
                            onToggle: () => setState(() {
                              if (_selectedFiles.contains(entry.value.name)) {
                                _selectedFiles.remove(entry.value.name);
                              } else {
                                _selectedFiles.add(entry.value.name);
                              }
                            }),
                            isDark: isDark,
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: context.sh(20)),
                  PrimaryButton(
                    label: 'Compress Selected (${_selectedFiles.length})',
                    onPressed: _selectedFiles.isNotEmpty ? _startCompression : null,
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
    return Container(
      constraints: BoxConstraints(minWidth: context.s(88)),
      padding: EdgeInsets.symmetric(horizontal: context.s(10), vertical: context.sh(10)),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate800.withValues(alpha: 0.45) : AppColors.slate50,
        borderRadius: BorderRadius.circular(context.s(14)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: context.s(18), fontWeight: FontWeight.bold, color: valueColor ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary))),
          Text(label, style: TextStyle(fontSize: context.s(12), color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _FileItem {
  const _FileItem({
    required this.icon,
    required this.name,
    required this.sizeBytes,
    required this.type,
    required this.path,
  });

  final IconData icon;
  final String name;
  final int sizeBytes;
  final String type;
  final String path;
}

class _FileCard extends StatelessWidget {
  const _FileCard({required this.file, required this.isSelected, required this.onToggle, required this.isDark});
  final _FileItem file;
  final bool isSelected;
  final VoidCallback onToggle;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(context.s(14)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.all(context.s(12)),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(context.s(14)),
            border: Border.all(
              color: isSelected ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.borderLight),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.08), blurRadius: 12)] : null,
          ),
          child: Row(
            children: [
              Container(
                width: context.s(42),
                height: context.s(42),
                decoration: BoxDecoration(color: isDark ? AppColors.slate800 : AppColors.slate100, borderRadius: BorderRadius.circular(context.s(10))),
                child: Icon(file.icon, color: AppColors.primary, size: context.s(22)),
              ),
              SizedBox(width: context.s(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(file.name, style: TextStyle(fontSize: context.s(13), fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary), overflow: TextOverflow.ellipsis),
                    Text('${file.type} - ${_formatBytes(file.sizeBytes)}', style: TextStyle(fontSize: context.s(12), color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
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

String _typeForName(String name) {
  final parts = name.toLowerCase().split('.');
  final ext = parts.length > 1 ? parts.last : '';
  if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) return 'Photo';
  if (['mp4', 'mov', 'mkv', 'avi', 'webm'].contains(ext)) return 'Video';
  if (['pdf', 'doc', 'docx', 'txt', 'csv', 'json'].contains(ext)) return 'Doc';
  return 'File';
}

IconData _iconForName(String name) {
  return switch (_typeForName(name)) {
    'Photo' => Icons.image_outlined,
    'Video' => Icons.movie_outlined,
    'Doc' => Icons.picture_as_pdf_outlined,
    _ => Icons.insert_drive_file_outlined,
  };
}

import 'package:flutter/material.dart';

import '../../core/models/universal_folder_models.dart';
import '../../core/services/local_file_service.dart';
import '../../core/services/operation_flow_service.dart';
import '../../core/services/universal_folder_api.dart';
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
  final _localFiles = LocalFileService.instance;
  final _selected = <String>{};
  late Future<List<StoredFileItem>> _futureFiles;

  @override
  void initState() {
    super.initState();
    _futureFiles = _loadFiles();
  }

  Future<List<StoredFileItem>> _loadFiles() async {
    final files = await _localFiles.listSavedFiles();
    return files.where((file) => file.canBeDecompressed).toList();
  }

  void _startDecompression() {
    if (_selected.isEmpty) return;
    if (_latestFiles == null) return;
    final file = _latestFiles!.firstWhere((item) => item.name == _selected.first);
    if (!file.canBeDecompressed) return;
    OperationFlowService.instance.setPendingDecompression(
      fileName: file.name,
      filePath: file.path ?? file.name,
    );
    widget.onDecompress?.call();
  }

  List<StoredFileItem>? _latestFiles;

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
      ),
      body: FutureBuilder<List<StoredFileItem>>(
        future: _futureFiles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load files saved on this device.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final files = snapshot.data ?? const [];
          _latestFiles = files;
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: files.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final file = files[i];
                    final isSelected = _selected.contains(file.name);
                    return GestureDetector(
                      onTap: () => setState(() {
                        _selected
                          ..clear()
                          ..add(file.name);
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
                              child: Icon(_iconForItem(file), color: AppColors.primary, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(file.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary), overflow: TextOverflow.ellipsis),
                                  Text('${_formatBytes(file.size)} • ${_formatDate(file.modifiedAt)}', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
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
              Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).padding.bottom + 16),
                child: PrimaryButton(
                  label: _selected.isEmpty ? 'Select a saved compressed file' : 'Decompress Selected',
                  onPressed: _selected.isNotEmpty ? _startDecompression : null,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class DecompressionProgressScreen extends StatefulWidget {
  const DecompressionProgressScreen({super.key, this.onComplete, this.onCancel});

  final VoidCallback? onComplete;
  final VoidCallback? onCancel;

  @override
  State<DecompressionProgressScreen> createState() => _DecompressionProgressScreenState();
}

class _DecompressionProgressScreenState extends State<DecompressionProgressScreen> {
  final _flow = OperationFlowService.instance;
  final _api = UniversalFolderApi.instance;
  final _localFiles = LocalFileService.instance;

  Object? _error;
  bool _working = true;

  @override
  void initState() {
    super.initState();
    _runDecompression();
  }

  Future<void> _runDecompression() async {
    final fileName = _flow.pendingDecompressionName;
    final filePath = _flow.pendingDecompressionPath;
    if (fileName == null || filePath == null) {
      setState(() {
        _working = false;
        _error = 'No file is queued for decompression.';
      });
      return;
    }

    try {
      final result = await _api.decompressFile(filePath: filePath, fileName: fileName);
      final localPath = await _localFiles.saveBytes(
        bytes: result.bytes,
        fileName: result.fileName,
      );
      final persistedResult = DecompressionResponse(
        filename: result.fileName,
        size: result.bytes.length,
        type: result.type,
        localPath: localPath,
      );
      _flow.recordDecompression(persistedResult);
      if (!mounted) return;
      setState(() => _working = false);
      Future<void>.delayed(const Duration(milliseconds: 350), () {
        widget.onComplete?.call();
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _working = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fileName = _flow.pendingDecompressionName ?? _flow.lastDecompression?.filename ?? 'Stored file';

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
                  SizedBox(
                    width: 112,
                    height: 112,
                    child: CircularProgressIndicator(
                      value: _working ? null : 1,
                      strokeWidth: 4,
                      backgroundColor: isDark ? AppColors.slate800 : AppColors.slate200,
                      valueColor: AlwaysStoppedAnimation(_error == null ? AppColors.primary : AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(fileName, textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
            const SizedBox(height: 40),
            Text(
              _error != null ? _error.toString() : (_working ? 'Requesting restore from backend...' : 'Restore finished.'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: _error != null ? AppColors.error : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
            ),
            if (_error == null && !_working && _flow.lastDecompression?.localPath != null) ...[
              const SizedBox(height: 16),
              Text(
                'Saved on this device:\n${_flow.lastDecompression!.localPath}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
              ),
            ],
            const Spacer(),
            if (_error != null)
              PrimaryButton(label: 'Try Again', onPressed: _runDecompression)
            else
              OutlinedButton(
                onPressed: widget.onCancel,
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
                child: Text(_working ? 'Cancel' : 'Close'),
              ),
          ],
        ),
      ),
    );
  }
}

IconData _iconForItem(StoredFileItem item) {
  if (item.name.toLowerCase().endsWith('.ufd')) return Icons.folder_zip_outlined;
  if (item.name.toLowerCase().endsWith('.uf')) return Icons.compress;
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
  return '$month ${value.day}';
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

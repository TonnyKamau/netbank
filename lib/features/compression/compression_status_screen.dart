import 'package:flutter/material.dart';

import '../../core/models/universal_folder_models.dart';
import '../../core/services/local_file_service.dart';
import '../../core/services/operation_flow_service.dart';
import '../../core/services/universal_folder_api.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_responsive.dart';
import '../../core/widgets/primary_button.dart';

class CompressionStatusScreen extends StatefulWidget {
  const CompressionStatusScreen({
    super.key,
    this.onComplete,
    this.onCancel,
  });

  final VoidCallback? onComplete;
  final VoidCallback? onCancel;

  @override
  State<CompressionStatusScreen> createState() => _CompressionStatusScreenState();
}

class _CompressionStatusScreenState extends State<CompressionStatusScreen> {
  final _flow = OperationFlowService.instance;
  final _api = UniversalFolderApi.instance;
  final _localFiles = LocalFileService.instance;

  CompressionResponse? _result;
  Object? _error;
  bool _working = true;

  @override
  void initState() {
    super.initState();
    _runCompression();
  }

  Future<void> _runCompression() async {
    final path = _flow.pendingCompressionPath;
    final name = _flow.pendingCompressionName;
    if (path == null || name == null) {
      setState(() {
        _working = false;
        _error = 'No file is queued for compression.';
      });
      return;
    }

    setState(() {
      _working = true;
      _error = null;
    });

    try {
      final result = await _api.compressFile(filePath: path, fileName: name);
      final localPath = await _localFiles.saveBytes(
        bytes: result.bytes,
        fileName: result.fileName,
      );
      final persistedResult = CompressionResponse(
        filename: result.fileName,
        size: result.bytes.length,
        originalSize: result.originalSize ?? 0,
        ratio: result.ratio ?? 1.0,
        type: result.type,
        localPath: localPath,
      );
      _flow.recordCompression(persistedResult);
      if (!mounted) return;
      setState(() {
        _result = persistedResult;
        _working = false;
      });
      Future<void>.delayed(const Duration(milliseconds: 450), () {
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
    final fileName = _flow.pendingCompressionName ?? _result?.filename ?? 'Selected file';
    final originalSize = _result == null ? '-' : _formatBytes(_result!.originalSize);
    final compressedSize = _result == null ? '-' : _formatBytes(_result!.size);
    final savings = _result == null ? '-' : '${(_result!.savingsFraction * 100).toStringAsFixed(1)}%';

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Compressing...'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onCancel ?? () => Navigator.maybePop(context),
        ),
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
                    width: context.s(100),
                    height: context.s(100),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.compress, color: AppColors.primary, size: 48),
                  ),
                  SizedBox(
                    width: context.s(116),
                    height: context.s(116),
                    child: CircularProgressIndicator(
                      value: _working ? null : 1,
                      strokeWidth: 4,
                      backgroundColor: isDark ? AppColors.slate800 : AppColors.slate200,
                      valueColor: AlwaysStoppedAnimation(
                        _error == null ? AppColors.primary : AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              fileName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _working ? 'Sending file to Universal Folder backend...' : 'Compression request finished.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
              child: Column(
                children: [
                  _StatusRow('Stage', _error != null ? 'Failed' : (_working ? 'Compressing...' : 'Completed'), isDark, valueColor: _error != null ? AppColors.error : null),
                  const SizedBox(height: 8),
                  _StatusRow('Original', originalSize, isDark),
                  const SizedBox(height: 8),
                  _StatusRow('Compressed', compressedSize, isDark),
                  const SizedBox(height: 8),
                  _StatusRow('Reduction', savings, isDark, valueColor: AppColors.success),
                ],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 20),
              Text(
                _error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.error, fontSize: 13),
              ),
            ] else if (_result?.localPath != null) ...[
              const SizedBox(height: 20),
              Text(
                'Saved on this device:\n${_result!.localPath}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  fontSize: 12,
                ),
              ),
            ],
            const Spacer(),
            if (_error != null)
              PrimaryButton(label: 'Try Again', onPressed: _runCompression)
            else
              OutlinedButton(
                onPressed: widget.onCancel,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  side: const BorderSide(color: AppColors.primary),
                ),
                child: Text(_working ? 'Cancel' : 'Close'),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow(this.label, this.value, this.isDark, {this.valueColor});
  final String label;
  final String value;
  final bool isDark;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary))),
      ],
    );
  }
}

class StorageSuccessScreen extends StatelessWidget {
  const StorageSuccessScreen({
    super.key,
    this.onDone,
    this.onViewHistory,
  });

  final VoidCallback? onDone;
  final VoidCallback? onViewHistory;

  @override
  Widget build(BuildContext context) {
    final flow = OperationFlowService.instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompression = flow.lastOperation != OperationKind.decompression;
    final compression = flow.lastCompression;
    final decompression = flow.lastDecompression;

    final title = isCompression ? 'Compression Complete!' : 'Decompression Complete!';
    final fileName = isCompression
        ? (compression?.filename ?? 'Output ready')
        : (decompression?.filename ?? 'Restored output ready');
    final originalValue = isCompression
        ? _formatBytes(compression?.originalSize ?? 0)
        : 'Stored archive';
    final resultValue = isCompression
        ? _formatBytes(compression?.size ?? 0)
        : _formatBytes(decompression?.size ?? 0);
    final badge = isCompression
        ? '-${(((compression?.savingsFraction ?? 0) * 100)).toStringAsFixed(1)}%'
        : 'Ready';

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(color: AppColors.successLight, shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle, color: AppColors.success, size: 56),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                fileName,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ResultStat(label: isCompression ? 'Original' : 'Source', value: originalValue, isDark: isDark),
                    const Icon(Icons.arrow_forward, color: AppColors.primary, size: 20),
                    _ResultStat(label: isCompression ? 'Compressed' : 'Output', value: resultValue, isDark: isDark),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(8)),
                      child: Text(badge, style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              PrimaryButton(label: 'Done', onPressed: onDone),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onViewHistory,
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
                child: const Text('View History'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  const _ResultStat({required this.label, required this.value, required this.isDark});
  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
        Text(label, style: TextStyle(fontSize: 12, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
      ],
    );
  }
}

String _formatBytes(int bytes) {
  if (bytes <= 0) return '-';
  const units = ['B', 'KB', 'MB', 'GB'];
  double value = bytes.toDouble();
  var index = 0;
  while (value >= 1024 && index < units.length - 1) {
    value /= 1024;
    index++;
  }
  return '${value.toStringAsFixed(value >= 100 ? 0 : 1)} ${units[index]}';
}

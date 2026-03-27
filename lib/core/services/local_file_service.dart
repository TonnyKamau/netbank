import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/universal_folder_models.dart';

class LocalFileService {
  LocalFileService._();

  static final LocalFileService instance = LocalFileService._();

  Future<Directory?> _outputDirectory() async {
    if (kIsWeb) return null;
    final baseDir = await getApplicationDocumentsDirectory();
    final outputDir = Directory('${baseDir.path}${Platform.pathSeparator}universal_folder');
    if (!await outputDir.exists()) {
      await outputDir.create(recursive: true);
    }
    return outputDir;
  }

  Future<String?> saveBytes({
    required List<int> bytes,
    required String fileName,
  }) async {
    if (kIsWeb) return null;

    final outputDir = await _outputDirectory();
    if (outputDir == null) return null;
    final sanitized = _sanitizeName(fileName);
    final file = File('${outputDir.path}${Platform.pathSeparator}$sanitized');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<List<StoredFileItem>> listSavedFiles() async {
    final outputDir = await _outputDirectory();
    if (outputDir == null || !await outputDir.exists()) {
      return const [];
    }

    final files = <StoredFileItem>[];
    await for (final entity in outputDir.list()) {
      if (entity is! File) continue;
      final stat = await entity.stat();
      files.add(
        StoredFileItem(
          name: entity.uri.pathSegments.isNotEmpty ? entity.uri.pathSegments.last : entity.path,
          size: stat.size,
          modifiedAt: stat.modified,
          path: entity.path,
        ),
      );
    }
    files.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    return files;
  }

  String _sanitizeName(String value) {
    final cleaned = value.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_').trim();
    return cleaned.isEmpty ? 'output.bin' : cleaned;
  }
}

import 'package:flutter/foundation.dart';

import '../models/universal_folder_models.dart';

class OperationFlowService extends ChangeNotifier {
  OperationFlowService._();

  static final OperationFlowService instance = OperationFlowService._();

  String? pendingCompressionPath;
  String? pendingCompressionName;
  String? pendingDecompressionPath;
  String? pendingDecompressionName;

  CompressionResponse? lastCompression;
  DecompressionResponse? lastDecompression;
  OperationKind? lastOperation;

  void setPendingCompression({
    required String filePath,
    required String fileName,
  }) {
    pendingCompressionPath = filePath;
    pendingCompressionName = fileName;
    notifyListeners();
  }

  void clearPendingCompression() {
    pendingCompressionPath = null;
    pendingCompressionName = null;
    notifyListeners();
  }

  void setPendingDecompression({
    required String fileName,
    required String filePath,
  }) {
    pendingDecompressionPath = filePath;
    pendingDecompressionName = fileName;
    notifyListeners();
  }

  void clearPendingDecompression() {
    pendingDecompressionPath = null;
    pendingDecompressionName = null;
    notifyListeners();
  }

  void recordCompression(CompressionResponse response) {
    lastCompression = response;
    lastOperation = OperationKind.compression;
    pendingCompressionPath = null;
    pendingCompressionName = null;
    notifyListeners();
  }

  void recordDecompression(DecompressionResponse response) {
    lastDecompression = response;
    lastOperation = OperationKind.decompression;
    pendingDecompressionPath = null;
    pendingDecompressionName = null;
    notifyListeners();
  }
}

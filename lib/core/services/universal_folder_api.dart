import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_environment.dart';
import '../models/universal_folder_models.dart';

class BinaryFileResult {
  const BinaryFileResult({
    required this.fileName,
    required this.bytes,
    required this.type,
    this.originalSize,
    this.ratio,
  });

  final String fileName;
  final List<int> bytes;
  final String type;
  final int? originalSize;
  final double? ratio;
}

class UniversalFolderApi {
  UniversalFolderApi._();

  static final UniversalFolderApi instance = UniversalFolderApi._();

  Uri _uri(String path) => Uri.parse('${AppEnvironment.apiBaseUrl}$path');

  Future<BackendStats> fetchStats() async {
    final response = await http.get(_uri('/stats'), headers: _headers(null));
    _ensureSuccess(response);
    return BackendStats.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<BinaryFileResult> compressFile({
    required String filePath,
    required String fileName,
  }) async {
    final request = http.MultipartRequest('POST', _uri('/compress'))
      ..headers.addAll(_multipartHeaders(null))
      ..files.add(await http.MultipartFile.fromPath('file', filePath, filename: fileName));
    final streamed = await request.send();
    return _parseBinaryResponse(streamed);
  }

  Future<BinaryFileResult> decompressFile({
    required String filePath,
    required String fileName,
  }) async {
    final request = http.MultipartRequest('POST', _uri('/decompress'))
      ..headers.addAll(_multipartHeaders(null))
      ..files.add(await http.MultipartFile.fromPath('file', filePath, filename: fileName));
    final streamed = await request.send();
    return _parseBinaryResponse(streamed);
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body, {
    String? bearerToken,
  }) async {
    final response = await http.post(
      _uri(path),
      headers: _headers(bearerToken),
      body: jsonEncode(body),
    );
    _ensureSuccess(response);
    return Map<String, dynamic>.from(jsonDecode(response.body) as Map);
  }

  Future<Map<String, dynamic>> putJson(
    String path,
    Map<String, dynamic> body, {
    String? bearerToken,
  }) async {
    final response = await http.put(
      _uri(path),
      headers: _headers(bearerToken),
      body: jsonEncode(body),
    );
    _ensureSuccess(response);
    return Map<String, dynamic>.from(jsonDecode(response.body) as Map);
  }

  Future<List<Map<String, dynamic>>> getJsonList(
    String path, {
    String? bearerToken,
  }) async {
    final response = await http.get(_uri(path), headers: _headers(bearerToken));
    _ensureSuccess(response);
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<Map<String, dynamic>> getJsonMap(
    String path, {
    String? bearerToken,
  }) async {
    final response = await http.get(_uri(path), headers: _headers(bearerToken));
    _ensureSuccess(response);
    return Map<String, dynamic>.from(jsonDecode(response.body) as Map);
  }

  Future<void> delete(
    String path, {
    String? bearerToken,
  }) async {
    final response = await http.delete(_uri(path), headers: _headers(bearerToken));
    _ensureSuccess(response);
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    String message = 'Request failed (${response.statusCode})';
    final bodyText = response.body.trim();
    try {
      final body = jsonDecode(bodyText) as Map<String, dynamic>;
      final apiMessage = body['detail']?.toString() ?? body['error']?.toString();
      if (apiMessage != null && apiMessage.isNotEmpty) {
        message = apiMessage;
      }
    } catch (_) {
      if (bodyText.isNotEmpty) {
        final isHtmlError = bodyText.startsWith('<!DOCTYPE html') || bodyText.startsWith('<html');
        if (isHtmlError) {
          message = _friendlyHttpError(response.statusCode);
        } else {
          message = bodyText;
        }
      }
    }
    throw UniversalFolderApiException(message);
  }

  String _friendlyHttpError(int statusCode) {
    switch (statusCode) {
      case 502:
        return 'The server gateway could not reach Universal Folder. Check the backend URL and that the server is running.';
      case 503:
        return 'Universal Folder is temporarily unavailable. Try again in a moment.';
      case 504:
        return 'Universal Folder took too long to respond. Check your connection and backend server.';
      default:
        return 'The server returned an unexpected response. Check the backend URL and try again.';
    }
  }

  Map<String, String> _headers(String? bearerToken) {
    return {
      'Content-Type': 'application/json',
      'x-api-key': AppEnvironment.platformApiKey,
      if ((bearerToken ?? '').isNotEmpty) 'Authorization': 'Bearer $bearerToken',
    };
  }

  Map<String, String> _multipartHeaders(String? bearerToken) {
    return {
      'x-api-key': AppEnvironment.platformApiKey,
      if ((bearerToken ?? '').isNotEmpty) 'Authorization': 'Bearer $bearerToken',
    };
  }

  Future<BinaryFileResult> _parseBinaryResponse(http.StreamedResponse response) async {
    final bytes = await response.stream.toBytes();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final text = utf8.decode(bytes, allowMalformed: true);
      throw UniversalFolderApiException(_extractErrorMessage(text, response.statusCode));
    }
    return BinaryFileResult(
      fileName: response.headers['x-uf-filename'] ?? 'output.bin',
      bytes: bytes,
      type: response.headers['x-uf-type'] ?? 'file',
      originalSize: int.tryParse(response.headers['x-uf-original-size'] ?? ''),
      ratio: double.tryParse(response.headers['x-uf-ratio'] ?? ''),
    );
  }

  String _extractErrorMessage(String bodyText, int statusCode) {
    String message = 'Request failed ($statusCode)';
    try {
      final body = jsonDecode(bodyText) as Map<String, dynamic>;
      final apiMessage = body['detail']?.toString() ?? body['error']?.toString();
      if (apiMessage != null && apiMessage.isNotEmpty) {
        return apiMessage;
      }
    } catch (_) {
      if (bodyText.isNotEmpty) {
        final isHtmlError = bodyText.startsWith('<!DOCTYPE html') || bodyText.startsWith('<html');
        return isHtmlError ? _friendlyHttpError(statusCode) : bodyText;
      }
    }
    return message;
  }
}

class UniversalFolderApiException implements Exception {
  UniversalFolderApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

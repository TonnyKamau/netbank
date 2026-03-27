// Run with: flutter test test/generate_icon_test.dart
// Copies the website brand assets into the Flutter app icon paths.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('copy app_icon.png from website logo', () async {
    await _copy(
      source: '../universal_folder/public/logo-mark-v4.png',
      destination: 'assets/images/app_icon.png',
    );
  });

  test('copy app_icon_fg.png from website icon mark', () async {
    await _copy(
      source: '../universal_folder/public/icon-mark-v4.png',
      destination: 'assets/images/app_icon_fg.png',
    );
  });
}

Future<void> _copy({
  required String source,
  required String destination,
}) async {
  final sourceFile = File(source);
  if (!await sourceFile.exists()) {
    throw Exception('Source asset not found: $source');
  }

  final destinationFile = File(destination);
  await destinationFile.parent.create(recursive: true);
  await sourceFile.copy(destinationFile.path);
}

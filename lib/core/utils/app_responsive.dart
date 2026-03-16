import 'package:flutter/material.dart';

extension AppResponsive on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  bool get isTablet => screenWidth >= 600;
  bool get isSmallPhone => screenHeight < 700;

  /// Scale [size] relative to 390pt reference width. Clamped to [0.8, 1.3].
  double s(double size) => size * (screenWidth / 390).clamp(0.8, 1.3);

  /// Scale [size] relative to 844pt reference height. Clamped to [0.8, 1.3].
  double sh(double size) => size * (screenHeight / 844).clamp(0.8, 1.3);
}

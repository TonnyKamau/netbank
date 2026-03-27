import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 96.0, this.withBackground = true});

  final double size;
  final bool withBackground;

  static const String _fullAsset = 'assets/images/app_icon.png';
  static const String _foregroundAsset = 'assets/images/app_icon_fg.png';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(withBackground ? size * 0.24 : size * 0.18),
        child: Image.asset(
          withBackground ? _fullAsset : _foregroundAsset,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFF0E1F1F),
                borderRadius: BorderRadius.circular(size * 0.24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Icon(
                Icons.folder_copy_rounded,
                size: size * 0.46,
                color: const Color(0xFF8FECE7),
              ),
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AppReveal extends StatelessWidget {
  const AppReveal({
    super.key,
    required this.child,
    this.animate = true,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 0.08),
    this.duration = const Duration(milliseconds: 420),
  });

  final Widget child;
  final bool animate;
  final Duration delay;
  final Offset offset;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    if (!animate) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration + delay,
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        final delayedProgress = delay == Duration.zero
            ? value
            : ((value - (delay.inMilliseconds / (duration + delay).inMilliseconds)).clamp(0.0, 1.0)).toDouble();
        final opacity = delayedProgress.clamp(0.0, 1.0);
        final dx = offset.dx * (1 - opacity);
        final dy = offset.dy * (1 - opacity);
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(dx * 100, dy * 100),
            child: child,
          ),
        );
      },
    );
  }
}

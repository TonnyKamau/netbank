import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_responsive.dart';
import '../../core/widgets/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.onGetStarted, this.onLogin});

  final VoidCallback? onGetStarted;
  final VoidCallback? onLogin;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  static const int _totalPages = 5;

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildDots({bool dark = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_totalPages, (i) {
        final isActive = i == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: dark
                ? (isActive ? Colors.white : Colors.white.withValues(alpha: 0.3))
                : (isActive
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF0F7FF),
      body: PageView(
        controller: _pageController,
        onPageChanged: (i) => setState(() => _currentPage = i),
        children: [
          _Slide1(
            onGetStarted: _nextPage,
            onLogin: widget.onLogin,
            onSkip: widget.onGetStarted,
            dots: _buildDots(),
          ),
          _Slide2(
            onBack: _prevPage,
            onContinue: _nextPage,
            dots: _buildDots(),
          ),
          _Slide3(
            onBack: _prevPage,
            onContinue: _nextPage,
            onLogin: widget.onLogin,
            dots: _buildDots(),
          ),
          _Slide4(
            onBack: _prevPage,
            onContinue: _nextPage,
            onSkip: widget.onGetStarted,
            dots: _buildDots(),
          ),
          _Slide5(
            onBack: _prevPage,
            onStart: widget.onGetStarted,
            onMaybeLater: widget.onLogin,
            dots: _buildDots(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Slide 1 — Storage Relief
// ─────────────────────────────────────────
class _Slide1 extends StatelessWidget {
  const _Slide1({
    required this.onGetStarted,
    required this.onSkip,
    required this.onLogin,
    required this.dots,
  });

  final VoidCallback onGetStarted;
  final VoidCallback? onSkip;
  final VoidCallback? onLogin;
  final Widget dots;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        children: [
          // Top bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                const SizedBox(width: 48),
                Expanded(
                  child: Text(
                    'Netbank',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: TextButton(
                    onPressed: onSkip,
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Illustration card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.08),
                            Colors.transparent,
                          ],
                          radius: 0.7,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cloud_done,
                          color: AppColors.primary,
                          size: context.s(96),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [Icons.image, Icons.videocam, Icons.description]
                              .map(
                                (ic) => Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Icon(
                                    ic,
                                    color: AppColors.primary.withValues(alpha: 0.35),
                                    size: 26,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Text
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
            child: Column(
              children: [
                Text(
                  'Solving your storage limits',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.s(24),
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Keep all your memories without worry',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.s(15),
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Dots
          Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: dots),

          // Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              children: [
                PrimaryButton(
                  label: 'Get Started',
                  onPressed: onGetStarted,
                  height: 56,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: onLogin,
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Log In',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Slide 2 — Security & Privacy
// ─────────────────────────────────────────
class _Slide2 extends StatelessWidget {
  const _Slide2({
    required this.onBack,
    required this.onContinue,
    required this.dots,
  });

  final VoidCallback onBack;
  final VoidCallback onContinue;
  final Widget dots;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBack,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
                const Expanded(
                  child: Text(
                    'Onboarding',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),

          Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: dots),

          // Illustration card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  width: double.infinity,
                  color: isDark ? const Color(0xFF1E2A4A) : const Color(0xFFEEF2FF),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -30,
                        left: -30,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 0.12),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -30,
                        right: -30,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: context.s(100),
                              height: context.s(100),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.security,
                                color: AppColors.primary,
                                size: context.s(52),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.fingerprint,
                                  color: AppColors.primary.withValues(alpha: 0.4),
                                  size: 28,
                                ),
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.enhanced_encryption,
                                  color: AppColors.primary.withValues(alpha: 0.4),
                                  size: 28,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Title & description
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
            child: Column(
              children: [
                Text(
                  'Security & Privacy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.s(26),
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your files are protected with industry-standard military-grade security protocols.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.s(14),
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // Feature cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _FeatureCard(
                  icon: Icons.lock,
                  title: 'End-to-End Encryption',
                  subtitle:
                      'Only you hold the keys. Even we cannot access your compressed archives.',
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _FeatureCard(
                  icon: Icons.fingerprint,
                  title: 'Biometric Protection',
                  subtitle: 'Unlock your private vault using FaceID or TouchID for instant access.',
                  isDark: isDark,
                ),
              ],
            ),
          ),

          // Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              children: [
                PrimaryButton(
                  label: 'Continue Securely',
                  onPressed: onContinue,
                  height: 56,
                ),
                const SizedBox(height: 10),
                Text(
                  'By continuing, you agree to our Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Slide 3 — Universal Support
// ─────────────────────────────────────────
class _Slide3 extends StatelessWidget {
  const _Slide3({
    required this.onBack,
    required this.onContinue,
    required this.onLogin,
    required this.dots,
  });

  final VoidCallback onBack;
  final VoidCallback onContinue;
  final VoidCallback? onLogin;
  final Widget dots;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBack,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
                const Expanded(
                  child: Text(
                    'Step 3 of 5',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),

          Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: dots),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  width: double.infinity,
                  color: isDark ? AppColors.surfaceDark : const Color(0xFFF0F4FF),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -30,
                        right: -30,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 0.08),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -30,
                        left: -30,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 0.06),
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.cloud_done,
                              color: AppColors.primary,
                              size: context.s(88),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [Icons.image, Icons.description, Icons.article]
                                  .map(
                                    (ic) => Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 6),
                                      child: Icon(
                                        ic,
                                        color: AppColors.primary.withValues(alpha: 0.35),
                                        size: 24,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
            child: Column(
              children: [
                Text(
                  'Universal Support',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.s(26),
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Compress photos, videos, and documents seamlessly. One tool for all your file needs, optimized for quality and speed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.s(14),
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _FeatureCard(
                  icon: Icons.image,
                  title: 'Media Optimization',
                  subtitle: 'Reduce image size without losing detail',
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _FeatureCard(
                  icon: Icons.videocam,
                  title: 'Video Transcoding',
                  subtitle: 'Shrink 4K videos for easy sharing',
                  isDark: isDark,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              children: [
                PrimaryButton(label: 'Continue', onPressed: onContinue, height: 56),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onLogin,
                  child: const Text(
                    'Log In',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Slide 4 — Universal Decompression
// ─────────────────────────────────────────
class _Slide4 extends StatelessWidget {
  const _Slide4({
    required this.onBack,
    required this.onContinue,
    required this.onSkip,
    required this.dots,
  });

  final VoidCallback onBack;
  final VoidCallback onContinue;
  final VoidCallback? onSkip;
  final Widget dots;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBack,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
                const Expanded(
                  child: Text(
                    'Onboarding',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),

          Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: dots),

          // Dark illustration card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0F172A), Color(0xFF1E3A5F)],
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.15),
                      ),
                    ),
                    Container(
                      width: context.s(88),
                      height: context.s(88),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            blurRadius: 30,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.upload_rounded,
                        color: AppColors.primary,
                        size: context.s(44),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
            child: Column(
              children: [
                Text(
                  'Universal\nDecompression',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.s(26),
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Restore any compressed file to its original, high-quality state instantly. Experience seamless retrieval with zero data loss.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.s(14),
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _FeatureCard(
                  icon: Icons.bolt,
                  title: 'Instant Retrieval',
                  subtitle: 'Files are restored in milliseconds.',
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _FeatureCard(
                  icon: Icons.hd,
                  title: 'Original Quality',
                  subtitle: 'Zero artifacts or pixelation.',
                  isDark: isDark,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              children: [
                PrimaryButton(label: 'Continue', onPressed: onContinue, height: 56),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onSkip,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Slide 5 — Final Step
// ─────────────────────────────────────────
class _Slide5 extends StatelessWidget {
  const _Slide5({
    required this.onBack,
    required this.onStart,
    required this.onMaybeLater,
    required this.dots,
  });

  final VoidCallback onBack;
  final VoidCallback? onStart;
  final VoidCallback? onMaybeLater;
  final Widget dots;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBack,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
                const Expanded(
                  child: Text(
                    'Step 5 of 5',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),

          // Gradient illustration card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFF6B6B), Color(0xFFAB47BC)],
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 20,
                      right: 20,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 30,
                      left: 30,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'POTENTIAL SAVINGS',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.savings_outlined,
                                  color: Color(0xFFAB47BC),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '85% More Space',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: context.s(20),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Title & description
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Column(
              children: [
                Text(
                  'Maximize your space,\npreserve your memories.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.s(24),
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Ready to optimize your device and keep your best moments in stunning high quality with our advanced compression?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.s(14),
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // Dots
          Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: dots),

          // Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              children: [
                PrimaryButton(
                  label: 'Start Compressing',
                  onPressed: onStart,
                  height: 56,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onMaybeLater,
                  child: const Text(
                    'Maybe later',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Shared feature card widget
// ─────────────────────────────────────────
class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_text_styles.dart';
import '../../../../design_system/widgets/app_logo.dart';
import '../../../../design_system/widgets/primary_button.dart';
import '../../../../shared/data/app_preferences.dart';

class _OnboardingPage {
  final String imagePath;
  final String title;
  final String body;

  const _OnboardingPage({
    required this.imagePath,
    required this.title,
    required this.body,
  });
}

/// First-launch onboarding: communicates the core loop (play → log → level up)
/// in a few seconds and drops the user into the app, defeating the empty-app
/// problem (CLAUDE.md §4, memory.md.txt). Shown once; the router gate keeps it
/// from reappearing. Always skippable so it never adds forced friction.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const List<_OnboardingPage> _pages = [
    _OnboardingPage(
      imagePath: 'assets/images/brand/onboarding/onboarding_1_log.png',
      title: 'Log your session in seconds',
      body: 'Walk off court and tap to log. Smart defaults mean one tap does '
          'it — match result, feel and gear optional.',
    ),
    _OnboardingPage(
      imagePath: 'assets/images/brand/onboarding/onboarding_2_level_up.png',
      title: 'Watch your skills level up',
      body: 'Every session fills your Player Profile — serve, forehand, '
          'footwork, mental game. Real progress, made visible.',
    ),
    _OnboardingPage(
      imagePath: 'assets/images/brand/onboarding/onboarding_3_motivation.png',
      title: 'Play. Log. Level up.',
      body: 'Earn XP, keep streaks and unlock badges. Your game grows like '
          'an RPG character — every point earned on court.',
    ),
  ];

  final PageController _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(appPreferencesProvider).setOnboardingComplete(true);
    if (!mounted) return;
    context.go('/sessions');
  }

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const AppLogo(height: 30),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _finish,
                      child: const Text('Skip'),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) =>
                    _OnboardingPageView(page: _pages[i]),
              ),
            ),
            _BottomBar(
              count: _pages.length,
              index: _index,
              isLast: _isLast,
              onNext: _next,
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  final _OnboardingPage page;

  const _OnboardingPageView({required this.page});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Illustration — takes ~58% of the available page height.
        Expanded(
          flex: 58,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.lg),
              child: Image.asset(
                page.imagePath,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        // Text — left-aligned for a premium editorial feel.
        Expanded(
          flex: 42,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(page.title, style: AppTextStyles.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  page.body,
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Dots indicator + CTA in a single bottom bar so the layout stays fixed
/// regardless of page content height.
class _BottomBar extends StatelessWidget {
  final int count;
  final int index;
  final bool isLast;
  final VoidCallback onNext;

  const _BottomBar({
    required this.count,
    required this.index,
    required this.isLast,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.sm,
        AppSpacing.screen,
        AppSpacing.lg,
      ),
      child: Row(
        children: [
          // Dots
          Row(
            children: [
              for (var i = 0; i < count; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  height: 8,
                  width: i == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: i == index
                        ? AppColors.primary
                        : AppColors.outline,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                ),
            ],
          ),
          const Spacer(),
          // CTA
          FilledButton(
            onPressed: onNext,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(isLast ? 'Get started' : 'Next'),
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  isLast ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

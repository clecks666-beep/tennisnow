import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_text_styles.dart';
import '../../../../design_system/widgets/app_logo.dart';
import '../../../../design_system/widgets/primary_button.dart';
import '../../../../shared/data/app_preferences.dart';

/// One value slide in the intro.
class _OnboardingPage {
  final IconData icon;
  final String title;
  final String body;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.body,
  });
}

/// First-launch onboarding: communicates the core loop in a few seconds and
/// drops the user into the app, defeating the empty-app problem (CLAUDE.md §4,
/// memory.md.txt). Shown once; the router gate (see goRouterProvider) keeps it
/// from reappearing. Skippable so it never adds forced friction.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const List<_OnboardingPage> _pages = [
    _OnboardingPage(
      icon: Icons.bolt_rounded,
      title: 'Log in seconds',
      body:
          'Capture a match or training session the moment you walk off court — '
          'with smart defaults, it takes one tap.',
    ),
    _OnboardingPage(
      icon: Icons.favorite_rounded,
      title: 'Capture how you felt',
      body:
          'Add your mood, energy and equipment alongside performance. That\'s '
          'what reveals why you play your best.',
    ),
    _OnboardingPage(
      icon: Icons.insights_rounded,
      title: 'See what lifts your game',
      body:
          'Watch your trends, keep a streak alive and earn badges. Small wins '
          'that keep you coming back.',
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
    // Persist first so the router gate lets us through, then enter the app.
    await ref.read(appPreferencesProvider).setOnboardingComplete(true);
    if (!mounted) return;
    context.go('/sessions');
  }

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Brand presence on the very first screen builds trust and tells
            // the user what they're in (§10 first impression). The logo is
            // centred; Skip stays reachable on the right without forcing it.
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
                itemBuilder: (context, i) => _OnboardingPageView(page: _pages[i]),
              ),
            ),
            _Dots(count: _pages.length, index: _index),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screen),
              child: PrimaryButton(
                label: _isLast ? 'Get started' : 'Next',
                onPressed: _next,
              ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 112,
            width: 112,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(page.icon, size: 56, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            page.title,
            style: AppTextStyles.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            page.body,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int index;

  const _Dots({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            height: 8,
            width: i == index ? 24 : 8,
            decoration: BoxDecoration(
              color: i == index ? AppColors.primary : AppColors.outline,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
          ),
      ],
    );
  }
}

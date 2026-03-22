import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../home/application/app_session_controller.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _OnboardingBody(ref: ref);
  }
}

class _OnboardingBody extends StatefulWidget {
  const _OnboardingBody({required this.ref});

  final WidgetRef ref;

  @override
  State<_OnboardingBody> createState() => _OnboardingBodyState();
}

class _OnboardingBodyState extends State<_OnboardingBody> {
  final _pageController = PageController();
  int _index = 0;

  static const _items = <_OnboardingItem>[
    _OnboardingItem(
      title: 'Find your perfect stay',
      subtitle:
          'Discover unique homes and rooms for short stays, from 1 day up to 30 days.',
      badge: 'Curated Collection',
      badgeValue: 'The Tutta Selection',
      icon: Icons.villa_outlined,
      accentColor: Color(0xFF0B2D6B),
    ),
    _OnboardingItem(
      title: 'Booking made simple',
      subtitle:
          'Secure your reservation in a few taps with payment methods adapted for Uzbekistan.',
      badge: 'Payment',
      badgeValue: 'Click and Payme supported',
      icon: Icons.credit_card_outlined,
      accentColor: Color(0xFF14489A),
    ),
    _OnboardingItem(
      title: 'Unlock premium exchanges',
      subtitle:
          'Use your skills in design, photography, or language for curated Free Stay options.',
      badge: 'Skill Exchange',
      badgeValue: 'Premium benefit',
      icon: Icons.auto_awesome_outlined,
      accentColor: Color(0xFF6D6A2C),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finish() {
    widget.ref.read(appSessionControllerProvider.notifier).completeOnboarding();
    context.go(RouteNames.auth);
  }

  @override
  Widget build(BuildContext context) {
    final item = _items[_index];
    final isLast = _index == _items.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Step ${_index + 1} / ${_items.length}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  TextButton(onPressed: _finish, child: const Text('Skip')),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _items.length,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemBuilder: (_, pageIndex) {
                    final page = _items[pageIndex];
                    return _OnboardingPage(item: page);
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _items.length,
                  (dotIndex) => AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: dotIndex == _index ? 22 : 8,
                    decoration: BoxDecoration(
                      color: dotIndex == _index
                          ? item.accentColor
                          : item.accentColor.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    if (isLast) {
                      _finish();
                      return;
                    }

                    await _pageController.nextPage(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOut,
                    );
                  },
                  child: Text(isLast ? 'Get started' : 'Next'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.item});

  final _OnboardingItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: [
                  item.accentColor.withValues(alpha: 0.90),
                  item.accentColor.withValues(alpha: 0.60),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white,
                    child: Icon(item.icon, color: item.accentColor, size: 30),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.badge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          item.badgeValue,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          item.title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          item.subtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class _OnboardingItem {
  const _OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeValue,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String subtitle;
  final String badge;
  final String badgeValue;
  final IconData icon;
  final Color accentColor;
}

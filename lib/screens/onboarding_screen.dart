import 'package:flutter/material.dart';
import '../services/store.dart';
import '../theme.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    await PileStore.instance.completeOnboarding();
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 28, right: 28),
              child: Row(
                children: List.generate(3, (index) => Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(right: 8),
                    height: 4,
                    decoration: BoxDecoration(
                      color: _currentPage >= index ? PlColors.lime : PlColors.line,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                )),
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildPage(
                    icon: '🕹️',
                    subtitle: 'PILE',
                    title: 'Conquer your\ngaming backlog.',
                    body: 'Stop wasting money on games you never start. Turn your pile of shame into a hall of fame, one completed game at a time.',
                    t: t,
                  ),
                  _buildPage(
                    icon: '🎯',
                    subtitle: 'FOCUS',
                    title: 'Play more.\nSpend less.',
                    body: 'Let roulette pick tonight\'s game so you stop endlessly scrolling. See your real completion rate and feel good about what you play.',
                    t: t,
                  ),
                  _buildPage(
                    icon: '🚀',
                    subtitle: 'HYPE',
                    title: 'Ready for the\nnext big drop.',
                    body: 'Track the releases you actually care about. Create a save-up plan so day one never hits your rent.\n\nNo accounts. No subscriptions. 100% yours.',
                    t: t,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  FilledButton(
                    onPressed: _nextPage,
                    child: Text(_currentPage == 2 ? 'Open the pile' : 'Next'),
                  ),
                  const SizedBox(height: 16),
                  if (_currentPage < 2)
                    TextButton(
                      onPressed: _finishOnboarding,
                      style: TextButton.styleFrom(
                        foregroundColor: PlColors.dim,
                      ),
                      child: const Text('Skip'),
                    )
                  else
                    const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({
    required String icon,
    required String subtitle,
    required String title,
    required String body,
    required TextTheme t,
  }) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),

          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(icon, style: const TextStyle(fontSize: 64)),
                const SizedBox(height: 28),
                Text(subtitle, style: t.labelSmall),
                const SizedBox(height: 10),
                Text(title, style: t.displayMedium),
                const SizedBox(height: 16),
                Text(
                  body,
                  style: t.bodyLarge!.copyWith(color: PlColors.dim, height: 1.55),
                ),
              ],
            ),
          ),

          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

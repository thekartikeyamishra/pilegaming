import 'package:flutter/material.dart';
import '../services/store.dart';
import '../theme.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              const Text('🕹️', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 28),
              Text('PILE', style: t.labelSmall),
              const SizedBox(height: 10),
              Text('Beat the backlog\nbefore the next\nbig drop.', style: t.displayMedium),
              const SizedBox(height: 16),
              Text(
                'Track every game you own, expose what you\'ve actually finished, let roulette pick tonight\'s game — and for the releases you\'re hyped about, a countdown with a save-up plan so day one never hits your rent.\n\nNo account. No cloud. Your library is yours.',
                style: t.bodyLarge!.copyWith(color: PlColors.dim, height: 1.55),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () async {
                  await PileStore.instance.completeOnboarding();
                  if (!context.mounted) return;
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const HomeScreen()));
                },
                child: const Text('Open the pile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

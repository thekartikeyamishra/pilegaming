import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart'; // Ensure confetti is in pubspec.yaml
import '../theme.dart';

/// PremiumUnlockDialog is a highly polished, celebratory overlay shown immediately
/// after a user voluntarily upgrades to Pro. It reinforces their decision as a
/// positive investment using premium visual assets, haptics, and smooth motion.
class PremiumUnlockDialog extends StatefulWidget {
  const PremiumUnlockDialog({super.key});

  /// A helper method to easily show this dialog from anywhere
  static Future<void> show(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: PlColors.void_.withOpacity(0.85),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) =>
          const PremiumUnlockDialog(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<PremiumUnlockDialog> createState() => _PremiumUnlockDialogState();
}

class _PremiumUnlockDialogState extends State<PremiumUnlockDialog>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Confetti celebration
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 4));

    // Breathing glow effect around the dialog
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.2, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Trigger haptics and confetti once the UI renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      HapticFeedback.heavyImpact();
      _confettiController.play();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The main dialog container
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                width: 320,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: PlColors.panel,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: PlColors.premium
                        .withOpacity(_glowAnimation.value + 0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: PlColors.premium
                          .withOpacity(_glowAnimation.value * 0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon with pop animation
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      builder: (context, scale, child) => Transform.scale(
                        scale: scale,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: PlColors.premium.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.workspace_premium,
                            color: PlColors.premium,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'PRO UNLOCKED',
                      style: t.labelSmall!.copyWith(
                        color: PlColors.premium,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      'Welcome to\nthe next level.',
                      textAlign: TextAlign.center,
                      style: t.displayMedium,
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Your library is now limitless. Thank you for investing in your gaming habits and supporting independent development.',
                      textAlign: TextAlign.center,
                      style: t.bodyMedium!.copyWith(
                        color: PlColors.dim,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: PlColors.premium,
                        foregroundColor: PlColors.void_,
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Enter Pro'),
                    ),
                  ],
                ),
              );
            },
          ),

          // Confetti Overlay Layer
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2, // blast downwards
              maxBlastForce: 6,
              minBlastForce: 2,
              emissionFrequency: 0.03,
              numberOfParticles: 20,
              gravity: 0.2,
              colors: const [
                PlColors.premium,
                Colors.white,
                PlColors.amber,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

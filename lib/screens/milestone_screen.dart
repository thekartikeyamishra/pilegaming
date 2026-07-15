import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart'; // Ensure confetti: ^0.8.0 is in pubspec.yaml
import '../theme.dart';

/// MilestoneScreen celebrates user achievements (like leveling up or clearing the backlog).
/// It features heavy haptic feedback, fluid entrance animations, and a confetti particle system
/// to make completing tasks feel like a highly rewarding, premium experience.
class MilestoneScreen extends StatefulWidget {
  final String title;
  final String message;
  final String iconEmoji;

  const MilestoneScreen({
    super.key,
    required this.title,
    required this.message,
    this.iconEmoji = '🏆',
  });

  @override
  State<MilestoneScreen> createState() => _MilestoneScreenState();
}

class _MilestoneScreenState extends State<MilestoneScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    // Initialize the confetti controller for a 3-second burst
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    // Trigger animations and haptics immediately after the screen is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
      HapticFeedback.heavyImpact(); // Strong tactile reward
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    
    return Scaffold(
      backgroundColor: PlColors.void_,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Main UI Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Spring-like bounce animation for the achievement icon
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.elasticOut,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: Text(
                          widget.iconEmoji,
                          style: const TextStyle(fontSize: 80),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  
                  // Smooth fade and slide up for the text content
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    builder: (context, opacity, child) {
                      return Opacity(
                        opacity: opacity,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - opacity)),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Text(
                          'MILESTONE REACHED',
                          style: t.labelSmall!.copyWith(color: PlColors.lime),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.title,
                          style: t.displayMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.message,
                          style: t.bodyLarge!.copyWith(color: PlColors.dim, height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Delayed fade in for the dismiss button
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeIn,
                    builder: (context, opacity, child) {
                      return Opacity(
                        opacity: opacity,
                        child: child,
                      );
                    },
                    child: FilledButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Keep Building the Pile'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Full-screen Confetti overlay layer
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2, // Straight down
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 25,
              gravity: 0.15,
              colors: const [
                PlColors.lime,
                PlColors.magenta,
                PlColors.amber,
                PlColors.frost,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
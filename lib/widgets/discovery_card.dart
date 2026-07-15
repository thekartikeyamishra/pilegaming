import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

/// DiscoveryCard is used to organically guide users towards feature discovery 
/// (e.g., trying out the roulette, setting up a hype countdown) without blocking
/// their core flow. It employs a subtle breathing animation to draw the eye
/// and smooth scale transitions on interaction.
class DiscoveryCard extends StatefulWidget {
  final String title;
  final String description;
  final String iconEmoji;
  final String actionLabel;
  final VoidCallback onAction;
  final VoidCallback onDismiss;

  const DiscoveryCard({
    super.key,
    required this.title,
    required this.description,
    required this.iconEmoji,
    required this.actionLabel,
    required this.onAction,
    required this.onDismiss,
  });

  @override
  State<DiscoveryCard> createState() => _DiscoveryCardState();
}

class _DiscoveryCardState extends State<DiscoveryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    // Creates a subtle, continuous breathing effect for the card's border glow
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.1, end: 0.4).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    HapticFeedback.lightImpact();
    widget.onAction();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          child: AnimatedScale(
            scale: _isPressed ? 0.96 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: PlColors.panel,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: PlColors.magenta.withOpacity(_glowAnimation.value),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: PlColors.magenta.withOpacity(_glowAnimation.value * 0.5),
                    blurRadius: 12,
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon Area
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: PlColors.magenta.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            widget.iconEmoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Content Area
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: t.titleLarge!.copyWith(fontSize: 16),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                widget.description,
                                style: t.bodySmall!.copyWith(height: 1.4),
                              ),
                              const SizedBox(height: 12),
                              
                              // Action Label
                              Row(
                                children: [
                                  Text(
                                    widget.actionLabel,
                                    style: t.labelSmall!.copyWith(
                                      color: PlColors.magenta,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_forward,
                                    color: PlColors.magenta,
                                    size: 14,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Dismiss Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 18, color: PlColors.dim),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        widget.onDismiss();
                      },
                      splashRadius: 20,
                      tooltip: 'Dismiss tip',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
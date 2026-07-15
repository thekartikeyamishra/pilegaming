import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

/// AchievementBadge visually tracks a user's gamification milestones.
/// It features a fluid circular progress ring, dynamic colors based on unlock state,
/// and built-in tactile tooltips for feature discovery.
class AchievementBadge extends StatelessWidget {
  final String id;
  final String title;
  final String description;
  final String iconEmoji;
  final bool isUnlocked;
  
  /// Progress towards unlocking this badge (0.0 to 1.0)
  final double progress; 

  const AchievementBadge({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.iconEmoji,
    this.isUnlocked = false,
    this.progress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    
    // Dynamically adjust theme tokens based on the achievement's state
    final activeColor = isUnlocked ? PlColors.lime : PlColors.dim;
    final bgColor = isUnlocked ? PlColors.lime.withOpacity(0.08) : PlColors.panel;
    final borderColor = isUnlocked ? PlColors.lime.withOpacity(0.4) : PlColors.line;

    return Tooltip(
      message: '$title\n$description',
      textStyle: t.bodySmall!.copyWith(color: PlColors.void_),
      decoration: BoxDecoration(
        color: PlColors.frost,
        borderRadius: BorderRadius.circular(8),
      ),
      triggerMode: TooltipTriggerMode.tap,
      onTriggered: () => HapticFeedback.selectionClick(),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.8, end: 1.0),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: Container(
          width: 90,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  // Smooth animated progress ring wrapping the icon
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: isUnlocked ? 1.0 : progress),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) => CircularProgressIndicator(
                        value: value,
                        strokeWidth: 3,
                        backgroundColor: PlColors.line,
                        valueColor: AlwaysStoppedAnimation(activeColor),
                      ),
                    ),
                  ),
                  
                  // Central Icon (dimmed or locked if not achieved)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      isUnlocked ? iconEmoji : '🔒',
                      key: ValueKey<bool>(isUnlocked),
                      style: TextStyle(
                        fontSize: 22,
                        // Apply a grayscale effect if the badge is locked but partially progressed
                        color: isUnlocked ? null : Colors.grey.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              
              // Achievement Title
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: t.labelSmall!.copyWith(
                  fontSize: 9,
                  height: 1.2,
                  color: isUnlocked ? PlColors.frost : PlColors.dim,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
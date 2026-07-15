import 'dart:async';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'gamification_engine.dart';

/// ReviewService handles Store optimization (ASO) by triggering the native App Store
/// and Play Store review prompts ONLY when the user is in a high-satisfaction state
/// (e.g., clearing a game from their backlog), maximizing 5-star conversion rates.
class ReviewService {
  static final ReviewService instance = ReviewService._();
  ReviewService._();

  static const String _kReviewRequested = 'pile.review_requested.v1';
  final InAppReview _inAppReview = InAppReview.instance;

  Future<void> init() async {
    // Listen to positive milestones emitted by the GamificationEngine.
    // We only want to ask for a review when the user feels accomplished.
    GamificationEngine.instance.onAchievementUnlocked.listen((achievementId) {
      // Trigger on meaningful milestones where the user experiences core value
      if (achievementId == 'first_blood' || achievementId == 'backlog_slayer') {
        _attemptReviewRequest();
      }
    });
  }

  Future<void> _attemptReviewRequest() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasRequested = prefs.getBool(_kReviewRequested) ?? false;

      // Never interrupt or spam the user if they've already been prompted
      if (hasRequested) return;

      if (await _inAppReview.isAvailable()) {
        // Add a slight delay to ensure the review prompt doesn't interrupt 
        // the immediate milestone celebration animations (like confetti or haptics).
        await Future.delayed(const Duration(seconds: 3));
        
        await _inAppReview.requestReview();
        
        // Mark as requested so we don't bother them again
        await prefs.setBool(_kReviewRequested, true);
      }
    } catch (_) {
      // Silently fail if the store API throws an exception.
      // A failed review request should never break the user experience.
    }
  }
}
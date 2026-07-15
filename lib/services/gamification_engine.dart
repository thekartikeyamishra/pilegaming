import 'dart:async';
import 'store.dart';

/// GamificationEngine drives the outcome-based motivation loops.
/// It silently observes the PileStore for state changes and translates
/// user actions into XP, Levels, and Achievement Milestones without
/// blocking the main UI thread.
class GamificationEngine {
  static final GamificationEngine instance = GamificationEngine._();
  GamificationEngine._();

  int _lastBeatenCount = 0;
  int _lastOwnedCount = 0;
  int _lastHypeCount = 0;
  int _lastLevel = 1;

  // Streams for the UI to listen to and trigger Lottie/Confetti animations
  final StreamController<String> _achievementController = StreamController<String>.broadcast();
  final StreamController<int> _levelUpController = StreamController<int>.broadcast();

  /// Emits the achievement ID when a new milestone is reached
  Stream<String> get onAchievementUnlocked => _achievementController.stream;
  
  /// Emits the new level integer when the user levels up
  Stream<int> get onLevelUp => _levelUpController.stream;

  void init() {
    final store = PileStore.instance;
    
    // Initialize baseline state to prevent retroactive popups on app launch
    _lastBeatenCount = store.beatenCount;
    _lastOwnedCount = store.ownedCount;
    _lastHypeCount = store.hype.length;
    _lastLevel = store.currentLevel;

    // Attach silent observer
    store.addListener(_evaluateState);
  }

  void _evaluateState() {
    final store = PileStore.instance;

    // 1. Evaluate Beaten Games (The primary goal of the app)
    if (store.beatenCount > _lastBeatenCount) {
      final diff = store.beatenCount - _lastBeatenCount;
      store.gainXp(50 * diff); // High reward for beating games
      _lastBeatenCount = store.beatenCount;

      if (store.beatenCount >= 1) _unlock('first_blood');
      if (store.beatenCount >= 5) _unlock('backlog_slayer');
      if (store.beatenCount >= 10) _unlock('completionist');
      if (store.beatenCount >= 25) _unlock('master_gamer');
    } else if (store.beatenCount < _lastBeatenCount) {
      _lastBeatenCount = store.beatenCount; // Sync on deletion/status change
    }

    // 2. Evaluate Library Growth
    if (store.ownedCount > _lastOwnedCount) {
      final diff = store.ownedCount - _lastOwnedCount;
      store.gainXp(5 * diff); // Small reward for logging games
      _lastOwnedCount = store.ownedCount;

      if (store.ownedCount >= 10) _unlock('growing_pile');
      if (store.ownedCount >= 25) _unlock('hoarder');
    } else if (store.ownedCount < _lastOwnedCount) {
      _lastOwnedCount = store.ownedCount; // Sync on deletion
    }

    // 3. Evaluate Hype/Savings Tracking
    if (store.hype.length > _lastHypeCount) {
      final diff = store.hype.length - _lastHypeCount;
      store.gainXp(15 * diff); // Medium reward for financial planning
      _lastHypeCount = store.hype.length;

      if (store.hype.isNotEmpty) _unlock('hype_train');
    } else if (store.hype.length < _lastHypeCount) {
      _lastHypeCount = store.hype.length;
    }

    // 4. Evaluate Level Ups
    if (store.currentLevel > _lastLevel) {
      _levelUpController.add(store.currentLevel);
      _lastLevel = store.currentLevel;
    } else if (store.currentLevel < _lastLevel) {
      _lastLevel = store.currentLevel; // Sync if XP is somehow lost/reset
    }
  }

  Future<void> _unlock(String id) async {
    final store = PileStore.instance;
    // Attempt to unlock; will return false if already unlocked previously
    final newlyUnlocked = await store.unlockAchievement(id);
    
    if (newlyUnlocked) {
      _achievementController.add(id);
    }
  }

  void dispose() {
    PileStore.instance.removeListener(_evaluateState);
    _achievementController.close();
    _levelUpController.close();
  }
}
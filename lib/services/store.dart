import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game.dart';

class PileStore extends ChangeNotifier {
  static final PileStore instance = PileStore._();
  PileStore._();

  static const _kGames = 'pile.games.v1';
  static const _kHype = 'pile.hype.v1';
  static const _kPro = 'pile.pro.v1';
  static const _kOnboarded = 'pile.onboarded.v1';
  static const freeLimit = 25;

  late SharedPreferences _prefs;
  List<GameEntry> games = [];
  List<HypeEntry> hype = [];
  bool isPro = false;
  bool onboarded = false;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final g = _prefs.getString(_kGames);
    if (g != null) games = GameEntry.decodeList(g);
    final h = _prefs.getString(_kHype);
    if (h != null) hype = HypeEntry.decodeList(h);
    hype.sort((a, b) => a.releaseDate.compareTo(b.releaseDate));
    isPro = _prefs.getBool(_kPro) ?? false;
    onboarded = _prefs.getBool(_kOnboarded) ?? false;
    notifyListeners();
  }

  Future<void> persist() async {
    await _prefs.setString(_kGames, GameEntry.encodeList(games));
    await _prefs.setString(_kHype, HypeEntry.encodeList(hype));
    notifyListeners();
  }

  Future<void> setPro(bool v) async {
    isPro = v;
    await _prefs.setBool(_kPro, v);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    onboarded = true;
    await _prefs.setBool(_kOnboarded, true);
    notifyListeners();
  }

  bool get atFreeLimit => !isPro && games.length >= freeLimit;

  // ---------- The numbers that make the Shame Card ----------
  int get pileSize =>
      games.where((g) => g.status == GameStatus.backlog).length;
  int get beatenCount =>
      games.where((g) => g.status == GameStatus.beaten).length;
  int get ownedCount =>
      games.where((g) => g.status != GameStatus.wishlist).length;

  /// Money sunk into games never started — the headline shame number.
  double get shameMoney => games
      .where((g) => g.status == GameStatus.backlog && g.hoursPlayed == 0)
      .fold(0.0, (s, g) => s + g.pricePaid);

  double get completionRate =>
      ownedCount == 0 ? 0 : beatenCount / ownedCount;

  /// Backlog roulette — the fun way to answer "what should I play?"
  GameEntry? roulette() {
    final pool =
        games.where((g) => g.status == GameStatus.backlog).toList();
    if (pool.isEmpty) return null;
    return pool[Random().nextInt(pool.length)];
  }

  Future<void> addGame(GameEntry g) async {
    games.insert(0, g);
    await persist();
  }

  Future<void> deleteGame(String id) async {
    games.removeWhere((g) => g.id == id);
    await persist();
  }

  Future<void> addHype(HypeEntry h) async {
    hype.add(h);
    hype.sort((a, b) => a.releaseDate.compareTo(b.releaseDate));
    await persist();
  }

  Future<void> deleteHype(String id) async {
    hype.removeWhere((h) => h.id == id);
    await persist();
  }
}

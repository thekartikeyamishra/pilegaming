import 'dart:convert';

enum GameStatus { backlog, playing, beaten, abandoned, wishlist }

extension GameStatusX on GameStatus {
  String get label => switch (this) {
        GameStatus.backlog => 'Backlog',
        GameStatus.playing => 'Playing',
        GameStatus.beaten => 'Beaten',
        GameStatus.abandoned => 'Dropped',
        GameStatus.wishlist => 'Wishlist',
      };
}

/// One game the user owns or wants. Titles are user-entered text — factual
/// references only, no cover art or logos, which keeps the app entirely
/// clear of game-IP entanglement (see README §legal).
///
/// `pile.game.v1` is the agent contract: a recommendation agent can read the
/// library, a deal-hunting agent can read the wishlist. Add fields; never
/// rename them.
class GameEntry {
  final String id;
  String title;
  String platform; // PC / PS5 / Xbox / Switch / Mobile / Other
  GameStatus status;
  double pricePaid;
  double hoursPlayed;
  int rating; // 0 = unrated, 1-5
  DateTime added;

  GameEntry({
    required this.id,
    required this.title,
    this.platform = 'PC',
    this.status = GameStatus.backlog,
    this.pricePaid = 0,
    this.hoursPlayed = 0,
    this.rating = 0,
    DateTime? added,
  }) : added = added ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'schema': 'pile.game.v1',
        'id': id,
        'title': title,
        'platform': platform,
        'status': status.name,
        'price_paid': pricePaid,
        'hours_played': hoursPlayed,
        'rating': rating,
        'added': added.toIso8601String(),
      };

  static GameEntry fromJson(Map<String, dynamic> j) => GameEntry(
        id: j['id'] as String,
        title: j['title'] as String,
        platform: j['platform'] as String? ?? 'PC',
        status: GameStatus.values.firstWhere((s) => s.name == j['status'],
            orElse: () => GameStatus.backlog),
        pricePaid: (j['price_paid'] as num?)?.toDouble() ?? 0,
        hoursPlayed: (j['hours_played'] as num?)?.toDouble() ?? 0,
        rating: (j['rating'] as num?)?.toInt() ?? 0,
        added: j['added'] != null ? DateTime.parse(j['added']) : null,
      );

  static String encodeList(List<GameEntry> l) =>
      jsonEncode(l.map((e) => e.toJson()).toList());
  static List<GameEntry> decodeList(String s) => (jsonDecode(s) as List)
      .map((e) => GameEntry.fromJson(e as Map<String, dynamic>))
      .toList();
}

/// An upcoming release the user is hyped for: countdown + save-up plan.
/// Works for any game, ever — GTA 6 today, whatever comes next tomorrow.
class HypeEntry {
  final String id;
  String title;
  DateTime releaseDate;
  double targetPrice; // what they expect to spend
  double saved; // what they've put aside so far

  HypeEntry({
    required this.id,
    required this.title,
    required this.releaseDate,
    this.targetPrice = 0,
    this.saved = 0,
  });

  int get daysLeft => releaseDate.difference(DateTime.now()).inDays;
  double get remaining => (targetPrice - saved).clamp(0, double.infinity);

  /// Suggested weekly set-aside to be fully funded by release day.
  double get weeklySaveNeeded {
    final weeks = (daysLeft / 7).clamp(1, 5200);
    return remaining / weeks;
  }

  Map<String, dynamic> toJson() => {
        'schema': 'pile.hype.v1',
        'id': id,
        'title': title,
        'release_date': releaseDate.toIso8601String(),
        'target_price': targetPrice,
        'saved': saved,
      };

  static HypeEntry fromJson(Map<String, dynamic> j) => HypeEntry(
        id: j['id'] as String,
        title: j['title'] as String,
        releaseDate: DateTime.parse(j['release_date'] as String),
        targetPrice: (j['target_price'] as num?)?.toDouble() ?? 0,
        saved: (j['saved'] as num?)?.toDouble() ?? 0,
      );

  static String encodeList(List<HypeEntry> l) =>
      jsonEncode(l.map((e) => e.toJson()).toList());
  static List<HypeEntry> decodeList(String s) => (jsonDecode(s) as List)
      .map((e) => HypeEntry.fromJson(e as Map<String, dynamic>))
      .toList();
}

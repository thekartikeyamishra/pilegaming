import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/game.dart';
import '../services/store.dart';
import '../services/toolbox.dart';
import '../theme.dart';
import 'edit_sheets.dart';
import 'shame_card.dart';
import 'settings_screen.dart';
import 'paywall_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final store = PileStore.instance;
  late TabController _tabs;
  GameStatus? _filter = GameStatus.backlog;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    store.addListener(_refresh);
  }

  @override
  void dispose() {
    store.removeListener(_refresh);
    _tabs.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pile', style: t.titleLarge),
        actions: [
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: store.levelProgress),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: PlColors.panel,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: PlColors.lime.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('LVL ${store.currentLevel}',
                          style: t.labelSmall!.copyWith(color: PlColors.lime)),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          value: value,
                          strokeWidth: 2,
                          backgroundColor: PlColors.line,
                          valueColor: const AlwaysStoppedAnimation(PlColors.lime),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: 'Shame card',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ShameCardScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: PlColors.lime,
          labelColor: PlColors.lime,
          unselectedLabelColor: PlColors.dim,
          labelStyle: t.labelSmall!.copyWith(fontSize: 13),
          tabs: const [Tab(text: 'THE PILE'), Tab(text: 'HYPE')],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [_pileTab(t), _hypeTab(t)],
      ),
      floatingActionButton: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) => Transform.scale(
          scale: scale,
          child: child,
        ),
        child: FloatingActionButton.extended(
          backgroundColor: PlColors.lime,
          foregroundColor: PlColors.void_,
          icon: const Icon(Icons.add),
          label: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _tabs.index == 0 ? 'Add game' : 'Track release',
              key: ValueKey<int>(_tabs.index),
            ),
          ),
          onPressed: () {
            if (_tabs.index == 0) {
              if (store.atFreeLimit) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PaywallScreen()));
                return;
              }
              EditSheets.editGame(context, null);
            } else {
              EditSheets.editHype(context, null);
            }
          },
        ),
      ),
    );
  }

  Widget _pileTab(TextTheme t) {
    final list = _filter == null
        ? store.games
        : store.games.where((g) => g.status == _filter).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: [
        Row(children: [
          _stat(t, 'IN THE PILE', '${store.pileSize}', PlColors.frost),
          const SizedBox(width: 10),
          _stat(t, 'BEATEN', '${store.beatenCount}', PlColors.lime),
          const SizedBox(width: 10),
          _stat(
              t,
              'SUNK, UNPLAYED',
              NumberFormat.compactCurrency(symbol: '\$', decimalDigits: 0)
                  .format(store.shameMoney),
              PlColors.red),
        ]),
        const SizedBox(height: 14),

        OutlinedButton.icon(
          icon: const Icon(Icons.casino_outlined, color: PlColors.magenta),
          label: const Text('Backlog roulette — pick for me'),
          onPressed: () {
            final g = store.roulette();
            if (g == null) return;
            showDialog(
              context: context,
              builder: (ctx) => TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.8, end: 1.0),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                builder: (context, scale, child) => Transform.scale(
                  scale: scale,
                  child: child,
                ),
                child: AlertDialog(
                  backgroundColor: PlColors.panel,
                  title: Text('🎰 Fate says:',
                      style: Theme.of(ctx).textTheme.titleLarge),
                  content: Text('${g.title}\n(${g.platform})',
                      style: Theme.of(ctx).textTheme.headlineMedium),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Spin again later')),
                    FilledButton(
                      onPressed: () async {
                        g.status = GameStatus.playing;
                        await store.persist();
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      child: const Text('Playing it'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 18),

        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _chip(null, 'All'),
              ...GameStatus.values.map((s) => _chip(s, s.label)),
            ],
          ),
        ),
        const SizedBox(height: 14),

        if (!store.isPro && store.games.length >= (PileStore.freeLimit - 5))
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const PaywallScreen())),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [PlColors.panel, PlColors.panel.withOpacity(0.6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: PlColors.lime.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.workspace_premium,
                        color: PlColors.lime, size: 28),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Unlock your full library',
                              style: t.titleLarge!.copyWith(fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(
                            'You are approaching the free limit. Invest in Pro to track unlimited games and master your backlog.',
                            style: t.bodySmall!.copyWith(height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: list.isEmpty
              ? Padding(
                  key: const ValueKey('empty_state'),
                  padding: const EdgeInsets.only(top: 48),
                  child: Text(
                    store.games.isEmpty
                        ? 'Empty pile. Impossible.\nAdd the games you own but haven\'t touched.'
                        : 'Nothing with this status.',
                    textAlign: TextAlign.center,
                    style: t.bodyMedium!.copyWith(color: PlColors.dim, height: 1.5),
                  ),
                )
              : Column(
                  key: const ValueKey('list_state'),
                  children: list
                      .map((g) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Card(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => EditSheets.editGame(context, g),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(g.title,
                                                style: t.titleLarge!
                                                    .copyWith(fontSize: 16)),
                                            const SizedBox(height: 4),
                                            Text(
                                                '${g.platform} · ${g.status.label}'
                                                '${g.hoursPlayed > 0 ? ' · ${g.hoursPlayed.toStringAsFixed(0)}h' : ''}'
                                                '${g.rating > 0 ? ' · ${'★' * g.rating}' : ''}',
                                                style: t.bodySmall),
                                          ],
                                        ),
                                      ),
                                      _statusDot(g.status),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
        ),
      ],
    );
  }

  Widget _hypeTab(TextTheme t) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: store.hype.isEmpty
              ? Padding(
                  key: const ValueKey('hype_empty'),
                  padding: const EdgeInsets.only(top: 48),
                  child: Text(
                    'Track the releases you\'re saving for.\nCountdown + a weekly save-up plan,\nso release day never hits your rent.',
                    textAlign: TextAlign.center,
                    style: t.bodyMedium!.copyWith(color: PlColors.dim, height: 1.5),
                  ),
                )
              : Column(
                  key: const ValueKey('hype_list'),
                  children: store.hype.map((h) {
                    final pct = h.targetPrice == 0
                        ? 1.0
                        : (h.saved / h.targetPrice).clamp(0.0, 1.0);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => EditSheets.editHype(context, h),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                        child: Text(h.title,
                                            style: t.titleLarge!
                                                .copyWith(fontSize: 17))),
                                    Text(
                                      h.daysLeft < 0
                                          ? 'OUT NOW'
                                          : '${h.daysLeft} DAYS',
                                      style: t.labelSmall!.copyWith(
                                          color: PlColors.magenta, fontSize: 13),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                    DateFormat('MMMM d, yyyy')
                                        .format(h.releaseDate),
                                    style: t.bodySmall),
                                if (h.targetPrice > 0) ...[
                                  const SizedBox(height: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0.0, end: pct),
                                      duration:
                                          const Duration(milliseconds: 1000),
                                      curve: Curves.easeOutCubic,
                                      builder: (context, value, _) =>
                                          LinearProgressIndicator(
                                        value: value,
                                        minHeight: 8,
                                        backgroundColor: PlColors.line,
                                        valueColor:
                                            const AlwaysStoppedAnimation(
                                                PlColors.amber),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    h.remaining <= 0
                                        ? 'Fully funded 🏆'
                                        : 'Saved \$${h.saved.toStringAsFixed(0)} of \$${h.targetPrice.toStringAsFixed(0)} — put aside \$${h.weeklySaveNeeded.toStringAsFixed(0)}/week to be ready.',
                                    style: t.bodySmall!
                                        .copyWith(color: PlColors.amber),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: 8),

        if (Toolbox.items.any((i) => i.url.isNotEmpty))
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            builder: (context, opacity, child) =>
                Opacity(opacity: opacity, child: child),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.local_offer_outlined,
                    color: PlColors.amber),
                title: Text('Deals on games you\'re saving for',
                    style: t.bodyMedium),
                subtitle: Text('Authorized stores only. Partner links labeled.',
                    style: t.bodySmall),
                trailing: const Icon(Icons.chevron_right, color: PlColors.dim),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen())),
              ),
            ),
          ),
      ],
    );
  }

  Widget _stat(TextTheme t, String label, String value, Color color) {
    return Expanded(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.9, end: 1.0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: t.labelSmall!.copyWith(fontSize: 9)),
                const SizedBox(height: 6),
                FittedBox(
                    child: Text(value,
                        style: t.headlineMedium!
                            .copyWith(fontSize: 20, color: color))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusDot(GameStatus s) {
    final color = switch (s) {
      GameStatus.playing => PlColors.magenta,
      GameStatus.beaten => PlColors.lime,
      GameStatus.abandoned => PlColors.red,
      GameStatus.wishlist => PlColors.amber,
      GameStatus.backlog => PlColors.dim,
    };
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _chip(GameStatus? s, String label) {
    final sel = _filter == s;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: ChoiceChip(
          label: Text(label),
          selected: sel,
          showCheckmark: false,
          selectedColor: PlColors.lime,
          backgroundColor: PlColors.panel,
          side: const BorderSide(color: PlColors.line),
          labelStyle: TextStyle(
              color: sel ? PlColors.void_ : PlColors.dim,
              fontWeight: FontWeight.w600,
              fontSize: 13),
          onSelected: (_) => setState(() => _filter = s),
        ),
      ),
    );
  }
}

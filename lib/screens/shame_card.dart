import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../services/store.dart';
import '../theme.dart';

/// The growth loop. Gamers have posted "pile of shame" screenshots for a
/// decade — this makes the definitive version: pile size, completion rate,
/// and the headline number (money sunk into never-launched games), styled
/// like an arcade score screen. Self-deprecating = shareable.
class ShameCardScreen extends StatefulWidget {
  const ShameCardScreen({super.key});
  @override
  State<ShameCardScreen> createState() => _ShameCardScreenState();
}

class _ShameCardScreenState extends State<ShameCardScreen> {
  final _shot = ScreenshotController();
  bool _sharing = false;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text('Shame card', style: t.titleLarge)),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Screenshot(controller: _shot, child: _card(context)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: FilledButton.icon(
              icon: _sharing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: PlColors.void_))
                  : const Icon(Icons.ios_share),
              label: Text(_sharing ? 'Preparing…' : 'Post my shame'),
              onPressed: _sharing ? null : _share,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final s = PileStore.instance;
    final money = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final pct = (s.completionRate * 100).round();
    return Container(
      width: 320,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: PlColors.void_,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: PlColors.line, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('PILE OF SHAME', style: t.labelSmall),
              Text(DateFormat('MMM yyyy').format(DateTime.now()),
                  style: t.bodySmall),
            ],
          ),
          const SizedBox(height: 24),
          Text('GAMES WAITING', style: t.labelSmall!.copyWith(fontSize: 9)),
          Text('${s.pileSize}',
              style: t.displayMedium!
                  .copyWith(fontSize: 52, color: PlColors.frost)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('COMPLETION',
                        style: t.labelSmall!.copyWith(fontSize: 9)),
                    Text('$pct%',
                        style: t.headlineMedium!
                            .copyWith(color: PlColors.lime)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SUNK, NEVER LAUNCHED',
                        style: t.labelSmall!.copyWith(fontSize: 9)),
                    Text(money.format(s.shameMoney),
                        style: t.headlineMedium!
                            .copyWith(color: PlColors.red)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: PlColors.line),
          const SizedBox(height: 14),
          Text('INSERT COIN TO CONTINUE (or just play what you own)',
              style: t.bodySmall!.copyWith(fontSize: 10.5)),
          const SizedBox(height: 4),
          Text('Tracked with Pile',
              style: t.bodySmall!
                  .copyWith(fontSize: 10.5, color: PlColors.dim)),
        ],
      ),
    );
  }

  Future<void> _share() async {
    setState(() => _sharing = true);
    try {
      final bytes = await _shot.capture(pixelRatio: 3);
      if (bytes == null) return;
      final dir = await getTemporaryDirectory();
      final f = File('${dir.path}/pile_shame.png');
      await f.writeAsBytes(bytes);
      final s = PileStore.instance;
      await Share.shareXFiles(
        [XFile(f.path)],
        text:
            '${s.pileSize} games in my backlog and \$${s.shameMoney.toStringAsFixed(0)} sunk into games I\'ve never launched. 💀 What\'s your pile of shame? Tracked with Pile.',
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }
}

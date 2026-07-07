import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/store.dart';
import '../services/toolbox.dart';
import '../theme.dart';
import 'paywall_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final store = PileStore.instance;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final tools = Toolbox.items.where((i) => i.url.isNotEmpty || !i.isPartner);
    return Scaffold(
      appBar: AppBar(title: Text('Settings', style: t.titleLarge)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('DEALS TOOLBOX', style: t.labelSmall),
          const SizedBox(height: 8),
          Text(
            'Authorized game stores only — no gray-market keys, ever. "Partner link" rows pay Pile a commission at no cost to you; it keeps the app cheap and ad-free. Check IsThereAnyDeal for the historical low before buying anything.',
            style: t.bodySmall!.copyWith(height: 1.5),
          ),
          const SizedBox(height: 12),
          if (tools.isEmpty)
            Text('Deal partners coming soon.',
                style: t.bodySmall!.copyWith(color: PlColors.dim))
          else
            ...tools.map((i) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      title: Row(children: [
                        Flexible(
                            child: Text(i.name,
                                style:
                                    t.titleLarge!.copyWith(fontSize: 15))),
                        const SizedBox(width: 8),
                        if (i.isPartner)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: PlColors.amber),
                            ),
                            child: Text('PARTNER LINK',
                                style: t.labelSmall!.copyWith(
                                    fontSize: 8, color: PlColors.amber)),
                          ),
                      ]),
                      subtitle: Text(i.pitch, style: t.bodySmall),
                      trailing: const Icon(Icons.open_in_new,
                          size: 18, color: PlColors.dim),
                      onTap: () => Toolbox.open(i),
                    ),
                  ),
                )),
          const SizedBox(height: 20),
          Text('EXPORT', style: t.labelSmall),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading:
                  const Icon(Icons.table_view_outlined, color: PlColors.lime),
              title: const Text('Export library as CSV'),
              onTap: () {
                if (!store.isPro) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const PaywallScreen()));
                  return;
                }
                _exportCsv();
              },
            ),
          ),
          const SizedBox(height: 28),
          Text('PILE PRO', style: t.labelSmall),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(store.isPro ? Icons.verified : Icons.workspace_premium,
                  color: PlColors.lime),
              title: Text(store.isPro ? 'Pro unlocked — GG' : 'Unlock Pile Pro'),
              onTap: store.isPro
                  ? null
                  : () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const PaywallScreen())),
            ),
          ),
          const SizedBox(height: 28),
          Text('PRIVACY', style: t.labelSmall),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Pile has no account, no analytics, and no server. Your library and spending live only on this device. Shame cards share your numbers only when you tap share. Partner links open in your browser and receive nothing about you. Delete the app and everything is gone.',
                style: t.bodyMedium!.copyWith(color: PlColors.dim, height: 1.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportCsv() async {
    final rows =
        StringBuffer('title,platform,status,price_paid,hours_played,rating\n');
    String q(String s) => '"${s.replaceAll('"', '""')}"';
    for (final g in store.games) {
      rows.writeln([
        q(g.title), g.platform, g.status.name,
        g.pricePaid.toStringAsFixed(2), g.hoursPlayed.toStringAsFixed(1),
        g.rating,
      ].join(','));
    }
    final dir = await getTemporaryDirectory();
    final f = File('${dir.path}/pile_library.csv');
    await f.writeAsString(rows.toString());
    await Share.shareXFiles([XFile(f.path)], text: 'Pile — library export');
  }
}

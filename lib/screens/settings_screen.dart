import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/store.dart';
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
    
    return Scaffold(
      appBar: AppBar(title: Text('Settings', style: t.titleLarge)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
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
                'Pile has no account, no analytics, and no server. Your library and spending live only on this device. Shame cards share your numbers only when you tap share. Delete the app and everything is gone.',
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
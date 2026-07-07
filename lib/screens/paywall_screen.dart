import 'package:flutter/material.dart';
import '../services/purchases.dart';
import '../services/store.dart';
import '../theme.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});
  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  final store = PileStore.instance;

  @override
  void initState() {
    super.initState();
    store.addListener(_onChange);
  }

  @override
  void dispose() {
    store.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (store.isPro && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final price = Purchases.proProduct?.price ?? '\$6.99';
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PILE PRO', style: t.labelSmall),
            const SizedBox(height: 10),
            Text('${PileStore.freeLimit} games wasn\'t\nenough. Respect.', style: t.displayMedium),
            const SizedBox(height: 8),
            Text(
                'One payment — less than one game in a sale you didn\'t need. No subscription, no account.',
                style: t.bodyLarge!.copyWith(color: PlColors.dim, height: 1.5)),
            const SizedBox(height: 32),
            _f(context, Icons.all_inclusive, 'Unlimited library',
                'Every game, every platform, no ceiling.'),
            _f(context, Icons.table_view_outlined, 'CSV & JSON export',
                'Your library, portable to any tool or AI agent.'),
            _f(context, Icons.videogame_asset_outlined, 'Fund an indie dev',
                'Built by one person. No ads, no data selling — ever.'),
            const Spacer(),
            FilledButton(
              onPressed: Purchases.buyPro,
              child: Text('Unlock Pro — $price, once'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: Purchases.restore,
              child: const Text('Restore purchase'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _f(BuildContext context, IconData icon, String title, String body) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: PlColors.lime, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: t.bodyLarge),
                Text(body, style: t.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

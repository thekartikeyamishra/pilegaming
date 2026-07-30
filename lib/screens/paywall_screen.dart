import 'dart:async';
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
  StreamSubscription<String>? _errorSubscription;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    store.addListener(_onChange);
    
    // Listen for transaction errors or store unavailability and display to the user
    _errorSubscription = Purchases.errorEvents.listen((errorMessage) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: PlColors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    store.removeListener(_onChange);
    _errorSubscription?.cancel();
    super.dispose();
  }

  void _onChange() {
    // Silently pop once the state reflects the Pro upgrade
    if (store.isPro && mounted) Navigator.pop(context);
  }

  Future<void> _handleBuyPro() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    
    // The native OS purchase modal will take over after this executes.
    await Purchases.buyPro();
    
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _handleRestore() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    
    await Purchases.restore();
    
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final price = Purchases.proProduct?.price ?? '\$6.99';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Smooth entrance animation for header
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) => Transform.translate(
                  offset: Offset(0, 15 * (1 - value)),
                  child: Opacity(opacity: value, child: child),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: PlColors.premium.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: PlColors.premium.withOpacity(0.5)),
                      ),
                      child: Text('PILE PRO',
                          style: t.labelSmall!
                              .copyWith(color: PlColors.premium)),
                    ),
                    const SizedBox(height: 16),
                    Text('Invest in your\ngaming time.', style: t.displayMedium),
                    const SizedBox(height: 12),
                    Text(
                      'A single, transparent payment to unlock your full potential. No hidden fees, no subscriptions, and absolute data privacy.',
                      style: t.bodyLarge!.copyWith(color: PlColors.dim, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              
              // Feature list highlighting outcomes, not just specs
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _f(context, Icons.all_inclusive, 'Infinite Library',
                        'Track every game across all your platforms. No ceilings, no limits.'),
                    _f(context, Icons.auto_graph, 'Master Your Backlog',
                        'Unlock deeper insights into your completion rates and gaming habits.'),
                    _f(context, Icons.table_view_outlined, 'Total Data Ownership',
                        'Export your library to CSV & JSON anytime. Your data belongs to you.'),
                    _f(context, Icons.favorite_border, 'Support Indie Development',
                        'Built by one person. Ad-free forever, and your data is never sold.'),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0, top: 12.0),
                child: Column(
                  children: [
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: PlColors.premium,
                        foregroundColor: PlColors.void_,
                      ),
                      onPressed: _isLoading ? null : _handleBuyPro,
                      child: _isLoading 
                        ? const SizedBox(
                            width: 24, 
                            height: 24, 
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5, 
                              color: PlColors.void_
                            )
                          )
                        : Text('Unlock Pro Lifetime — $price'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _isLoading ? null : _handleRestore,
                      child: _isLoading 
                        ? const SizedBox(
                            width: 24, 
                            height: 24, 
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5, 
                              color: PlColors.frost
                            )
                          )
                        : const Text('Restore previous purchase'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _f(BuildContext context, IconData icon, String title, String body) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: PlColors.panel,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: PlColors.line),
            ),
            child: Icon(icon, color: PlColors.lime, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: t.titleLarge!.copyWith(fontSize: 16)),
                const SizedBox(height: 4),
                Text(body, style: t.bodySmall!.copyWith(height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
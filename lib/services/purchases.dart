import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'store.dart';

/// One non-consumable product: lifetime Pro. No accounts, no server —
/// the store receipt IS the license. Restore works via restorePurchases().
class Purchases {
  static const proId = 'pile_pro_lifetime';
  static final _iap = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _sub;
  static ProductDetails? proProduct;

  static Future<void> init() async {
    if (!await _iap.isAvailable()) return;
    _sub ??= _iap.purchaseStream.listen(_onPurchases, onError: (_) {});
    final resp = await _iap.queryProductDetails({proId});
    if (resp.productDetails.isNotEmpty) proProduct = resp.productDetails.first;
    // Silently restore on launch so reinstalls keep Pro.
    await _iap.restorePurchases();
  }

  static Future<void> buyPro() async {
    final p = proProduct;
    if (p == null) return;
    await _iap.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: p));
  }

  static Future<void> restore() => _iap.restorePurchases();

  static Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      if (p.productID == proId &&
          (p.status == PurchaseStatus.purchased ||
              p.status == PurchaseStatus.restored)) {
        await PileStore.instance.setPro(true);
      }
      if (p.pendingCompletePurchase) {
        await _iap.completePurchase(p);
      }
    }
  }
}

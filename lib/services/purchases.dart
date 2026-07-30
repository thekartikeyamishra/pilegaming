import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'store.dart';

class Purchases {
  static const proId = 'pile_pro_lifetime';
  static final _iap = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _sub;
  static ProductDetails? proProduct;

  static final StreamController<bool> _upgradeEventController =
      StreamController<bool>.broadcast();
  static Stream<bool> get upgradeEvents => _upgradeEventController.stream;

  // NEW: Stream for error broadcasting to prevent silent UI failures
  static final StreamController<String> _errorController =
      StreamController<String>.broadcast();
  static Stream<String> get errorEvents => _errorController.stream;

  static Future<void> init() async {
    try {
      if (!await _iap.isAvailable()) return;
      
      _sub ??= _iap.purchaseStream.listen(_onPurchases, onError: (error) {
        _errorController.add('Store connection error: ${error.toString()}');
      });
      
      final resp = await _iap.queryProductDetails({proId});
      
      if (resp.error != null) {
        _errorController.add('Failed to fetch product details from the store.');
      }
      
      if (resp.productDetails.isNotEmpty) {
        proProduct = resp.productDetails.first;
      }

      await _iap.restorePurchases();
    } catch (_) {
      // Init errors are swallowed so they don't crash the app on startup
    }
  }

  static Future<void> buyPro() async {
    try {
      if (!await _iap.isAvailable()) {
        _errorController.add('App store is currently unavailable. Please check your connection.');
        return;
      }
      
      final p = proProduct;
      if (p == null) {
        _errorController.add('Pro product not found. It may still be pending review in the Store Console.');
        return;
      }
      
      await _iap.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: p));
    } catch (e) {
      _errorController.add('Purchase initiation failed. Please try again.');
    }
  }

  static Future<void> restore() async {
    try {
      if (!await _iap.isAvailable()) {
        _errorController.add('App store is currently unavailable.');
        return;
      }
      
      await _iap.restorePurchases();
      // Note: Successful restores are handled asynchronously by the _onPurchases stream
    } catch (e) {
      _errorController.add('Failed to restore purchase. Please check your store account.');
    }
  }

  static Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      if (p.status == PurchaseStatus.error) {
        _errorController.add('Transaction failed or was canceled by the user.');
      } else if (p.productID == proId &&
          (p.status == PurchaseStatus.purchased ||
              p.status == PurchaseStatus.restored)) {
              
        final bool wasPro = PileStore.instance.isPro;
        await PileStore.instance.setPro(true);

        if (!wasPro && p.status == PurchaseStatus.purchased) {
          await PileStore.instance.gainXp(500);
          _upgradeEventController.add(true);
        }
      }
      
      if (p.pendingCompletePurchase) {
        try {
          await _iap.completePurchase(p);
        } catch (e) {
          _errorController.add('Failed to complete the transaction securely.');
        }
      }
    }
  }

  static void dispose() {
    _upgradeEventController.close();
    _errorController.close();
    _sub?.cancel();
    _sub = null;
  }
}
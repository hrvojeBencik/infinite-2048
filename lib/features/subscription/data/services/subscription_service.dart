import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../../core/constants/app_constants.dart';

class SubscriptionService {
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      final apiKey = Platform.isIOS
          ? AppConstants.revenueCatAppleApiKey
          : AppConstants.revenueCatGoogleApiKey;
      final config = PurchasesConfiguration(apiKey);
      await Purchases.configure(config);
      _initialized = true;
    } catch (e) {
      debugPrint('RevenueCat init failed: $e');
    }
  }

  Future<Offerings?> getOfferings() async {
    if (!_initialized) return null;
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('Failed to get offerings: $e');
      return null;
    }
  }

  Future<void> purchasePackage(Package package) async {
    try {
      await Purchases.purchase(PurchaseParams.package(package));
    } catch (e) {
      debugPrint('Purchase failed: $e');
      rethrow;
    }
  }

  Future<void> restorePurchases() async {
    try {
      await Purchases.restorePurchases();
    } catch (e) {
      debugPrint('Restore failed: $e');
      rethrow;
    }
  }

  Future<bool> isPremium() async {
    if (!_initialized) return false;
    try {
      final info = await Purchases.getCustomerInfo();
      return info.entitlements.active
          .containsKey(AppConstants.premiumEntitlementId);
    } catch (e) {
      return false;
    }
  }
}

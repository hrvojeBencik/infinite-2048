import 'dart:io';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/subscription_status.dart';
import '../../domain/repositories/subscription_repository.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  bool _isInitialized = false;

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    try {
      final apiKey = Platform.isIOS
          ? AppConstants.revenueCatApiKeyIos
          : AppConstants.revenueCatApiKeyAndroid;

      if (apiKey.startsWith('YOUR_')) return;

      await Purchases.configure(PurchasesConfiguration(apiKey));
      _isInitialized = true;
    } catch (_) {
      // RevenueCat not configured
    }
  }

  @override
  Future<SubscriptionStatus> getSubscriptionStatus() async {
    await _ensureInitialized();
    if (!_isInitialized) return const SubscriptionStatus();

    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final entitlement =
          customerInfo.entitlements.all[AppConstants.revenueCatEntitlementId];

      if (entitlement != null && entitlement.isActive) {
        return SubscriptionStatus(
          tier: SubscriptionTier.premium,
          expiresAt: entitlement.expirationDate != null
              ? DateTime.parse(entitlement.expirationDate!)
              : null,
        );
      }
      return const SubscriptionStatus();
    } catch (_) {
      return const SubscriptionStatus();
    }
  }

  @override
  Future<List<SubscriptionOffering>> getOfferings() async {
    await _ensureInitialized();
    if (!_isInitialized) {
      return [
        const SubscriptionOffering(
          id: 'monthly',
          title: 'Monthly',
          price: '\$3.99/mo',
          period: 'month',
        ),
        const SubscriptionOffering(
          id: 'yearly',
          title: 'Yearly',
          price: '\$29.99/yr',
          period: 'year',
          isMostPopular: true,
        ),
      ];
    }

    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null) return [];

      return current.availablePackages.map((pkg) {
        return SubscriptionOffering(
          id: pkg.identifier,
          title: pkg.storeProduct.title,
          price: pkg.storeProduct.priceString,
          period: pkg.packageType == PackageType.annual ? 'year' : 'month',
          isMostPopular: pkg.packageType == PackageType.annual,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<SubscriptionStatus> purchaseSubscription(String offeringId) async {
    await _ensureInitialized();
    if (!_isInitialized) {
      throw Exception('Subscription service not configured');
    }

    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null) throw Exception('No offerings available');

      final package = current.availablePackages.firstWhere(
        (p) => p.identifier == offeringId,
      );

      await Purchases.purchase(PurchaseParams.package(package));
      return getSubscriptionStatus();
    } catch (e) {
      throw Exception('Purchase failed: $e');
    }
  }

  @override
  Future<SubscriptionStatus> restorePurchases() async {
    await _ensureInitialized();
    if (!_isInitialized) return const SubscriptionStatus();

    try {
      await Purchases.restorePurchases();
      return getSubscriptionStatus();
    } catch (e) {
      throw Exception('Restore failed: $e');
    }
  }
}

import '../entities/subscription_status.dart';

class SubscriptionOffering {
  final String id;
  final String title;
  final String price;
  final String period;
  final bool isMostPopular;

  const SubscriptionOffering({
    required this.id,
    required this.title,
    required this.price,
    required this.period,
    this.isMostPopular = false,
  });
}

abstract class SubscriptionRepository {
  Future<SubscriptionStatus> getSubscriptionStatus();
  Future<List<SubscriptionOffering>> getOfferings();
  Future<SubscriptionStatus> purchaseSubscription(String offeringId);
  Future<SubscriptionStatus> restorePurchases();
}

import 'package:purchases_flutter/purchases_flutter.dart';

sealed class SubscriptionEvent {
  const SubscriptionEvent();
}

final class SubscriptionCheckRequested extends SubscriptionEvent {
  const SubscriptionCheckRequested();
}

final class SubscriptionLoadOfferings extends SubscriptionEvent {
  const SubscriptionLoadOfferings();
}

final class SubscriptionPurchaseRequested extends SubscriptionEvent {
  final Package package;
  const SubscriptionPurchaseRequested(this.package);
}

final class SubscriptionRestoreRequested extends SubscriptionEvent {
  const SubscriptionRestoreRequested();
}

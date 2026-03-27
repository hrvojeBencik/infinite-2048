import 'package:purchases_flutter/purchases_flutter.dart';

sealed class SubscriptionState {
  final bool isPremium;
  final Offerings? offerings;
  final String? errorMessage;

  const SubscriptionState({
    this.isPremium = false,
    this.offerings,
    this.errorMessage,
  });
}

final class SubscriptionInitial extends SubscriptionState {
  const SubscriptionInitial() : super();
}

final class SubscriptionLoading extends SubscriptionState {
  const SubscriptionLoading({
    super.isPremium,
    super.offerings,
  });
}

final class SubscriptionLoaded extends SubscriptionState {
  const SubscriptionLoaded({
    super.isPremium,
    super.offerings,
    super.errorMessage,
  });
}

final class SubscriptionPurchasing extends SubscriptionState {
  const SubscriptionPurchasing({
    super.isPremium,
    super.offerings,
  });
}

final class SubscriptionError extends SubscriptionState {
  const SubscriptionError({
    required String errorMessage,
    super.isPremium,
    super.offerings,
  }) : super(errorMessage: errorMessage);
}

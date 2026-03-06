import 'package:equatable/equatable.dart';

enum SubscriptionTier { free, premium }

class SubscriptionStatus extends Equatable {
  final SubscriptionTier tier;
  final DateTime? expiresAt;
  final bool isTrialing;

  const SubscriptionStatus({
    this.tier = SubscriptionTier.free,
    this.expiresAt,
    this.isTrialing = false,
  });

  bool get isPremium => tier == SubscriptionTier.premium;
  bool get isFree => tier == SubscriptionTier.free;

  bool get isActive {
    if (tier == SubscriptionTier.free) return false;
    if (expiresAt == null) return true;
    return DateTime.now().isBefore(expiresAt!);
  }

  @override
  List<Object?> get props => [tier, expiresAt, isTrialing];
}

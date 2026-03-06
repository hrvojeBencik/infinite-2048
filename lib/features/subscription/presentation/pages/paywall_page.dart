import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../../../core/widgets/glass_card.dart';
import '../bloc/subscription_bloc.dart';

class PaywallPage extends StatelessWidget {
  const PaywallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: AppColors.textSecondary),
                      onPressed: () => context.pop(),
                    ),
                  ),
                  const Icon(
                    Icons.workspace_premium_rounded,
                    size: 64,
                    color: AppColors.secondary,
                  ).animate().scale(delay: 200.ms, duration: 500.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 16),
                  const Text(
                    'Go Premium',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 8),
                  const Text(
                    'Unlock the full Infinite 2048 experience',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 32),
                  // Features
                  ..._features.asMap().entries.map((entry) {
                    return _FeatureRow(
                      icon: entry.value.$1,
                      text: entry.value.$2,
                    )
                        .animate(delay: (500 + entry.key * 100).ms)
                        .fadeIn()
                        .slideX(begin: 0.1);
                  }),
                  const SizedBox(height: 32),
                  // Offerings
                  BlocBuilder<SubscriptionBloc, SubscriptionState>(
                    builder: (context, state) {
                      if (state is SubscriptionLoaded && state.isPremium) {
                        return _AlreadyPremium();
                      }
                      if (state is SubscriptionLoaded) {
                        return Column(
                          children: [
                            ...state.offerings.map((offering) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _OfferingCard(
                                  offering: offering,
                                  onTap: () => context
                                      .read<SubscriptionBloc>()
                                      .add(PurchaseSubscription(offering.id)),
                                ),
                              );
                            }),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => context
                                  .read<SubscriptionBloc>()
                                  .add(const RestorePurchases()),
                              child: const Text(
                                'Restore Purchases',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      if (state is SubscriptionPurchasing) {
                        return const Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(
                              color: AppColors.primary),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Subscriptions auto-renew unless cancelled.\nCancel anytime in your device settings.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static const _features = [
    (Icons.block_rounded, 'Ad-free experience'),
    (Icons.undo_rounded, 'Unlimited undos'),
    (Icons.shuffle_rounded, 'Shuffle & Merge Boost power-ups'),
    (Icons.gavel_rounded, '5 Hammers per level'),
    (Icons.palette_rounded, 'Premium tile themes & backgrounds'),
    (Icons.star_rounded, 'Exclusive profile badge'),
  ];
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Icon(Icons.check_rounded, color: AppColors.success, size: 20),
        ],
      ),
    );
  }
}

class _OfferingCard extends StatelessWidget {
  final dynamic offering;
  final VoidCallback onTap;

  const _OfferingCard({required this.offering, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPopular = offering.isMostPopular;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isPopular
              ? AppColors.primary.withAlpha(20)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPopular ? AppColors.primary : AppColors.cardBorder,
            width: isPopular ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        offering.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isPopular
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (isPopular) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'BEST VALUE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    offering.price,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedButton(
              onPressed: onTap,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              gradient: isPopular ? AppColors.premiumGradient : AppColors.primaryGradient,
              child: Text(
                'Subscribe',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isPopular ? AppColors.background : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlreadyPremium extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: AppColors.secondary.withAlpha(100),
      child: Column(
        children: [
          const Icon(Icons.check_circle_rounded,
              color: AppColors.success, size: 48),
          const SizedBox(height: 12),
          const Text(
            "You're Premium!",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'All premium features are unlocked.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

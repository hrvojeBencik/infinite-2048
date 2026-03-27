import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/di.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/remote_config_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/subscription_bloc.dart';
import '../bloc/subscription_event.dart';
import '../bloc/subscription_state.dart';

class PaywallPage extends StatefulWidget {
  final String? source;

  const PaywallPage({super.key, this.source});

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  @override
  void initState() {
    super.initState();
    context.read<SubscriptionBloc>().add(const SubscriptionLoadOfferings());
    sl<AnalyticsService>().logPaywallOpened(source: widget.source);
  }

  @override
  void dispose() {
    sl<AnalyticsService>().logPaywallDismissed(source: widget.source);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textSecondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<SubscriptionBloc, SubscriptionState>(
        listener: _handleStateChanges,
        builder: (context, state) {
          final offerings = state.offerings;
          final currentPackage = offerings?.current?.availablePackages.firstOrNull;
          return _buildBody(context, state, currentPackage);
        },
      ),
    );
  }

  void _handleStateChanges(BuildContext context, SubscriptionState state) {
    if (state is SubscriptionLoaded && state.isPremium) {
      final package = state.offerings?.current?.availablePackages.firstOrNull;
      if (package != null) {
        sl<AnalyticsService>()
            .logPurchaseCompleted(productId: package.storeProduct.identifier);
      }
      Navigator.of(context).pop();
    } else if (state is SubscriptionLoaded && state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage!),
          backgroundColor: AppColors.error,
        ),
      );
    } else if (state is SubscriptionError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildBody(
    BuildContext context,
    SubscriptionState state,
    Package? package,
  ) {
    final isLoading =
        state is SubscriptionLoading || state is SubscriptionPurchasing;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _PaywallHeader(),
          const SizedBox(height: 24),
          const _FeatureList(),
          const SizedBox(height: 24),
          _PricingCard(package: package),
          const SizedBox(height: 24),
          _buildCtaButton(context, package, isLoading),
          const SizedBox(height: 12),
          _buildRestoreButton(context, isLoading),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Cancel anytime in your App Store settings',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          const _LegalLinksRow(),
        ],
      ),
    );
  }

  Widget _buildCtaButton(
    BuildContext context,
    Package? package,
    bool isLoading,
  ) {
    final introPrice = package?.storeProduct.introductoryPrice;
    final hasFreeTrial = introPrice != null && introPrice.price == 0;
    final label = hasFreeTrial ? 'Start Free Trial' : 'Unlock Premium';
    return ElevatedButton(
      onPressed: isLoading || package == null
          ? null
          : () {
              sl<AnalyticsService>().logPurchaseStarted(
                productId: package.storeProduct.identifier,
              );
              context
                  .read<SubscriptionBloc>()
                  .add(SubscriptionPurchaseRequested(package));
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  Widget _buildRestoreButton(BuildContext context, bool isLoading) {
    return TextButton(
      onPressed: isLoading
          ? null
          : () => context
              .read<SubscriptionBloc>()
              .add(const SubscriptionRestoreRequested()),
      child: const Text(
        'Restore Purchase',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private widgets
// ---------------------------------------------------------------------------

class _PaywallHeader extends StatelessWidget {
  const _PaywallHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppColors.premiumGradient,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.workspace_premium,
            color: Colors.white,
            size: 44,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Unlock Premium',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'The full 2048 experience, unlimited.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _FeatureList extends StatelessWidget {
  const _FeatureList();

  @override
  Widget build(BuildContext context) {
    const features = [
      'No ads — pure, uninterrupted gameplay',
      'Unlock all premium tile themes',
      'Access all zones and bonus levels',
      'Unlimited high-score tracking',
    ];
    return Column(
      children: features.map((f) => _FeatureRow(label: f)).toList(),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String label;
  const _FeatureRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.secondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PricingCard extends StatelessWidget {
  final Package? package;

  const _PricingCard({required this.package});

  @override
  Widget build(BuildContext context) {
    final product = package?.storeProduct;
    final priceString = product?.priceString ?? '—';
    final monthlyEquiv = product != null
        ? _monthlyEquivalent(product.price)
        : null;
    final introPrice = product?.introductoryPrice;
    final trialDays = introPrice?.periodNumberOfUnits;
    final hasFreeTrial = introPrice != null && introPrice.price == 0 &&
        trialDays != null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Premium — Annual',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            priceString,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (monthlyEquiv != null) ...[
            const SizedBox(height: 4),
            Text(
              '$monthlyEquiv / month',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
          if (hasFreeTrial) ...[
            const SizedBox(height: 12),
            Text(
              'Try free for $trialDays days, then $priceString/year',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _monthlyEquivalent(double annualPrice) {
    final monthly = annualPrice / 12;
    return '\$${monthly.toStringAsFixed(2)}';
  }
}

class _LegalLinksRow extends StatelessWidget {
  const _LegalLinksRow();

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final remoteConfig = sl<RemoteConfigService>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegalLink(
          label: 'Terms of Service',
          onTap: () => _open(remoteConfig.termsOfServiceUrl),
        ),
        const SizedBox(width: 24),
        _LegalLink(
          label: 'Privacy Policy',
          onTap: () => _open(remoteConfig.privacyPolicyUrl),
        ),
      ],
    );
  }
}

class _LegalLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _LegalLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 44,
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 14,
            decoration: TextDecoration.underline,
            decorationColor: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

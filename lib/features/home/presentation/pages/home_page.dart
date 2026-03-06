import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/premium_badge.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../achievements/presentation/bloc/achievements_bloc.dart';
import '../../../subscription/presentation/bloc/subscription_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<AchievementsBloc>().add(const LoadAchievements());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _Header(),
                const SizedBox(height: 32),
                _PlayButton().animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                const SizedBox(height: 20),
                _DailyChallengeCard()
                    .animate()
                    .fadeIn(delay: 400.ms)
                    .slideY(begin: 0.2),
                const SizedBox(height: 20),
                _QuickActions()
                    .animate()
                    .fadeIn(delay: 600.ms)
                    .slideY(begin: 0.2),
                const SizedBox(height: 20),
                _PremiumBanner()
                    .animate()
                    .fadeIn(delay: 800.ms)
                    .slideY(begin: 0.2),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'INFINITE',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: 4,
                ),
              ),
              const Text(
                '2048',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return GestureDetector(
              onTap: () => context.push('/profile'),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.surface,
                backgroundImage: state is AuthAuthenticated && state.user.photoUrl != null
                    ? NetworkImage(state.user.photoUrl!)
                    : null,
                child: state is! AuthAuthenticated || state.user.photoUrl == null
                    ? const Icon(Icons.person_outline_rounded,
                        color: AppColors.textTertiary, size: 22)
                    : null,
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.settings_rounded, color: AppColors.textSecondary),
          onPressed: () => context.push('/settings'),
        ),
      ],
    );
  }
}

class _PlayButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onPressed: () => context.push('/zones'),
      gradient: AppColors.primaryGradient,
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: const Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow_rounded, size: 32, color: Colors.white),
            SizedBox(width: 12),
            Text(
              'PLAY',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyChallengeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AchievementsBloc, AchievementsState>(
      builder: (context, state) {
        if (state is! AchievementsLoaded || state.dailyChallenge == null) {
          return const SizedBox.shrink();
        }
        final challenge = state.dailyChallenge!;
        final isCompleted = challenge.isCompleted;

        return GlassCard(
          onTap: isCompleted
              ? null
              : () {
                  context.push('/challenge/daily').then((_) {
                    if (context.mounted) {
                      context.read<AchievementsBloc>().add(const LoadAchievements());
                    }
                  });
                },
          borderColor: isCompleted
              ? AppColors.success.withAlpha(40)
              : AppColors.secondary.withAlpha(40),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: isCompleted
                      ? LinearGradient(colors: [
                          AppColors.success,
                          AppColors.success.withAlpha(180),
                        ])
                      : AppColors.premiumGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isCompleted ? Icons.check_rounded : Icons.today_rounded,
                  color: AppColors.background,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCompleted ? 'Challenge Complete!' : 'Daily Challenge',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isCompleted ? AppColors.success : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isCompleted
                          ? 'Come back tomorrow for a new challenge'
                          : challenge.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isCompleted)
                const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary)
              else
                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
            ],
          ),
        );
      },
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.emoji_events_rounded,
            label: 'Achievements',
            color: AppColors.secondary,
            onTap: () => context.push('/achievements'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            icon: Icons.leaderboard_rounded,
            label: 'Leaderboard',
            color: AppColors.success,
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        if (state is SubscriptionLoaded && state.isPremium) {
          return const SizedBox.shrink();
        }
        return GestureDetector(
          onTap: () => context.push('/paywall'),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.secondary.withAlpha(20),
                  AppColors.primary.withAlpha(20),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.secondary.withAlpha(40),
              ),
            ),
            child: Row(
              children: [
                const PremiumBadge(size: 24),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upgrade to Premium',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Ad-free, unlimited undos & more',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.secondary),
              ],
            ),
          ),
        );
      },
    );
  }
}

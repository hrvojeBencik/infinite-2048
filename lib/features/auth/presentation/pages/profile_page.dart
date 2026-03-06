import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/premium_badge.dart';
import '../bloc/auth_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is AuthAuthenticated) {
                      return _AuthenticatedProfile(user: state.user);
                    }
                    if (state is AuthLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                      );
                    }
                    return _UnauthenticatedProfile();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthenticatedProfile extends StatelessWidget {
  final dynamic user;

  const _AuthenticatedProfile({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: AppColors.primary,
          backgroundImage:
              user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
          child: user.photoUrl == null
              ? Text(
                  (user.displayName ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                )
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          user.displayName ?? 'Player',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        if (user.email != null) ...[
          const SizedBox(height: 4),
          Text(
            user.email!,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: 24),
        GlassCard(
          child: Column(
            children: [
              _ProfileOption(
                icon: Icons.workspace_premium_rounded,
                label: 'Subscription',
                trailing: const PremiumBadge(size: 18),
                onTap: () => context.push('/paywall'),
              ),
              const Divider(color: AppColors.divider),
              _ProfileOption(
                icon: Icons.cloud_sync_rounded,
                label: 'Cloud Sync',
                trailing: const Text('Enabled',
                    style: TextStyle(color: AppColors.success, fontSize: 13)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () =>
              context.read<AuthBloc>().add(const AuthSignOutRequested()),
          icon: const Icon(Icons.logout_rounded, color: AppColors.error),
          label:
              const Text('Sign Out', style: TextStyle(color: AppColors.error)),
        ),
      ],
    );
  }
}

class _UnauthenticatedProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 44,
          backgroundColor: AppColors.surface,
          child: Icon(Icons.person_outline_rounded,
              size: 44, color: AppColors.textTertiary),
        ),
        const SizedBox(height: 16),
        const Text(
          'Guest Player',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Sign in to save progress across devices\nand unlock cloud sync.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 32),
        AnimatedButton(
          onPressed: () =>
              context.read<AuthBloc>().add(const AuthGoogleSignInRequested()),
          backgroundColor: Colors.white,
          gradient: null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                width: 20,
                height: 20,
                errorBuilder: (_, _, _) =>
                    const Icon(Icons.g_mobiledata, size: 20, color: Colors.black87),
              ),
              const SizedBox(width: 12),
              const Text(
                'Continue with Google',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (Platform.isIOS)
          AnimatedButton(
            onPressed: () =>
                context.read<AuthBloc>().add(const AuthAppleSignInRequested()),
            backgroundColor: Colors.white,
            gradient: null,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.apple, size: 22, color: Colors.black87),
                SizedBox(width: 12),
                Text(
                  'Continue with Apple',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _ProfileOption({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(label,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary)),
      trailing: trailing ??
          const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
    );
  }
}

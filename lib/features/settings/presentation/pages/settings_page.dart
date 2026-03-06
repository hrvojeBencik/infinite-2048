import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Box _settingsBox;
  bool _soundEnabled = true;
  bool _hapticsEnabled = true;

  @override
  void initState() {
    super.initState();
    _settingsBox = Hive.box(AppConstants.hiveSettingsBox);
    _soundEnabled = _settingsBox.get('soundEnabled', defaultValue: true) as bool;
    _hapticsEnabled = _settingsBox.get('hapticsEnabled', defaultValue: true) as bool;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        onPressed: () => context.pop(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('GAMEPLAY'),
                      GlassCard(
                        child: Column(
                          children: [
                            _SettingsTile(
                              icon: Icons.volume_up_rounded,
                              title: 'Sound Effects',
                              trailing: Switch.adaptive(
                                value: _soundEnabled,
                                onChanged: (v) {
                                  setState(() => _soundEnabled = v);
                                  _settingsBox.put('soundEnabled', v);
                                },
                                activeTrackColor: AppColors.primary,
                              ),
                            ),
                            const Divider(color: AppColors.divider, height: 1),
                            _SettingsTile(
                              icon: Icons.vibration_rounded,
                              title: 'Haptic Feedback',
                              trailing: Switch.adaptive(
                                value: _hapticsEnabled,
                                onChanged: (v) {
                                  setState(() => _hapticsEnabled = v);
                                  _settingsBox.put('hapticsEnabled', v);
                                },
                                activeTrackColor: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _sectionTitle('ACCOUNT'),
                      GlassCard(
                        child: Column(
                          children: [
                            _SettingsTile(
                              icon: Icons.person_outline_rounded,
                              title: 'Profile',
                              onTap: () => context.push('/profile'),
                            ),
                            const Divider(color: AppColors.divider, height: 1),
                            _SettingsTile(
                              icon: Icons.workspace_premium_rounded,
                              title: 'Subscription',
                              onTap: () => context.push('/paywall'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _sectionTitle('ABOUT'),
                      GlassCard(
                        child: Column(
                          children: [
                            const _SettingsTile(
                              icon: Icons.info_outline_rounded,
                              title: 'Version',
                              subtitle: AppConstants.appVersion,
                            ),
                            const Divider(color: AppColors.divider, height: 1),
                            _SettingsTile(
                              icon: Icons.description_outlined,
                              title: 'Privacy Policy',
                              onTap: () {},
                            ),
                            const Divider(color: AppColors.divider, height: 1),
                            _SettingsTile(
                              icon: Icons.gavel_outlined,
                              title: 'Terms of Service',
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textTertiary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
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
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textTertiary))
          : null,
      trailing: trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textTertiary)
              : null),
    );
  }
}

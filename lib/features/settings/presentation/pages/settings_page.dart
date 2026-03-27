import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/di.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/remote_config_service.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _hapticsEnabled = true;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _hapticsEnabled = sl<HapticService>().isEnabled;
    _loadVersion();
    try { sl<AnalyticsService>().logScreenView('settings'); } catch (_) {}
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() => _appVersion = info.version);
    }
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
                            // _SettingsTile(
                            //   icon: Icons.volume_up_rounded,
                            //   title: 'Sound Effects',
                            //   trailing: Switch.adaptive(
                            //     value: _soundEnabled,
                            //     onChanged: (v) {
                            //       setState(() => _soundEnabled = v);
                            //       sl<SoundService>().setSoundEnabled(v);
                            //     },
                            //     activeTrackColor: AppColors.primary,
                            //   ),
                            // ),
                            // const Divider(color: AppColors.divider, height: 1),
                            _SettingsTile(
                              icon: Icons.vibration_rounded,
                              title: 'Haptic Feedback',
                              trailing: Switch.adaptive(
                                value: _hapticsEnabled,
                                onChanged: (v) {
                                  setState(() => _hapticsEnabled = v);
                                  sl<HapticService>().setEnabled(v);
                                  try { sl<AnalyticsService>().logSettingChanged(setting: 'haptics', value: v.toString()); } catch (_) {}
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _sectionTitle('SUPPORT'),
                      GlassCard(
                        child: _SettingsTile(
                          icon: Icons.feedback_rounded,
                          title: 'Send Feedback',
                          subtitle: 'Report bugs or suggest features',
                          onTap: () => context.push('/feedback'),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _sectionTitle('ABOUT'),
                      GlassCard(
                        child: Column(
                          children: [
                            _SettingsTile(
                              icon: Icons.info_outline_rounded,
                              title: 'Version',
                              subtitle: _appVersion.isEmpty
                                  ? '...'
                                  : _appVersion,
                            ),
                            const Divider(color: AppColors.divider, height: 1),
                            _SettingsTile(
                              icon: Icons.description_outlined,
                              title: 'Privacy Policy',
                              onTap: () => _openUrl(
                                sl<RemoteConfigService>().privacyPolicyUrl,
                              ),
                            ),
                            const Divider(color: AppColors.divider, height: 1),
                            _SettingsTile(
                              icon: Icons.gavel_outlined,
                              title: 'Terms of Service',
                              onTap: () => _openUrl(
                                sl<RemoteConfigService>().termsOfServiceUrl,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (kDebugMode) ...[
                        const SizedBox(height: 24),
                        _sectionTitle('DEVELOPER'),
                        GlassCard(
                          borderColor: AppColors.warning.withAlpha(40),
                          child: _SettingsTile(
                            icon: Icons.bug_report_rounded,
                            title: 'Dev Options',
                            subtitle: 'Debug tools & sandbox',
                            onTap: () => context.push('/dev'),
                          ),
                        ),
                      ],
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

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
          ? Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            )
          : null,
      trailing:
          trailing ??
          (onTap != null
              ? const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textTertiary,
                )
              : null),
    );
  }
}

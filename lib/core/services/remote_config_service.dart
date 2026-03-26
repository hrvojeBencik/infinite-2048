import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  static const _keyPrivacyPolicy = 'privacy_policy_url';
  static const _keyTermsOfService = 'terms_of_service_url';
  static const _keyAdFrequency = 'ad_frequency_level_count';

  static const _defaultPrivacyPolicy =
      'https://hrvojebencik.github.io/infinite-2048/privacy-policy.html';
  static const _defaultTermsOfService =
      'https://hrvojebencik.github.io/infinite-2048/terms-of-service.html';
  static const _defaultAdFrequency = 3;

  FirebaseRemoteConfig? _remoteConfig;

  Future<void> initialize() async {
    try {
      _remoteConfig = FirebaseRemoteConfig.instance;
      await _remoteConfig!.setDefaults({
        _keyPrivacyPolicy: _defaultPrivacyPolicy,
        _keyTermsOfService: _defaultTermsOfService,
        _keyAdFrequency: _defaultAdFrequency,
      });
      await _remoteConfig!.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: kDebugMode
              ? const Duration(minutes: 5)
              : const Duration(hours: 12),
        ),
      );
      await _remoteConfig!.fetchAndActivate();
    } catch (e) {
      debugPrint('Remote Config init failed: $e');
    }
  }

  String get privacyPolicyUrl {
    return _remoteConfig?.getString(_keyPrivacyPolicy) ?? _defaultPrivacyPolicy;
  }

  String get termsOfServiceUrl {
    return _remoteConfig?.getString(_keyTermsOfService) ??
        _defaultTermsOfService;
  }

  int get adFrequencyLevelCount =>
      _remoteConfig?.getInt(_keyAdFrequency) ?? _defaultAdFrequency;
}

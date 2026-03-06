import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  static const _keyPrivacyPolicy = 'privacy_policy_url';
  static const _keyTermsOfService = 'terms_of_service_url';

  static const _defaultPrivacyPolicy = 'https://example.com/privacy';
  static const _defaultTermsOfService = 'https://example.com/terms';

  FirebaseRemoteConfig? _remoteConfig;

  Future<void> initialize() async {
    try {
      _remoteConfig = FirebaseRemoteConfig.instance;
      await _remoteConfig!.setDefaults({
        _keyPrivacyPolicy: _defaultPrivacyPolicy,
        _keyTermsOfService: _defaultTermsOfService,
      });
      await _remoteConfig!.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval:
            kDebugMode ? const Duration(minutes: 5) : const Duration(hours: 12),
      ));
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
}

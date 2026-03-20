import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../constants/app_constants.dart';

class AdService {
  static bool _initialized = false;
  InterstitialAd? _interstitialAd;
  int _levelsCompletedSinceAd = 0;

  Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      _loadInterstitialAd();
    } catch (e) {
      debugPrint('AdService: MobileAds init failed: $e');
    }
  }

  String get _interstitialAdId => Platform.isIOS
      ? AppConstants.adMobInterstitialIdIos
      : AppConstants.adMobInterstitialIdAndroid;

  String get _bannerAdId => Platform.isIOS
      ? AppConstants.adMobBannerIdIos
      : AppConstants.adMobBannerIdAndroid;

  String get _rewardedAdId => Platform.isIOS
      ? AppConstants.adMobRewardedIdIos
      : AppConstants.adMobRewardedIdAndroid;

  void _loadInterstitialAd() {
    if (!_initialized) return;
    InterstitialAd.load(
      adUnitId: _interstitialAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) => _interstitialAd = null,
      ),
    );
  }

  void onLevelCompleted() {
    if (!_initialized) return;
    _levelsCompletedSinceAd++;
    if (_levelsCompletedSinceAd >= 3) {
      showInterstitial();
      _levelsCompletedSinceAd = 0;
    }
  }

  void showInterstitial() {
    _interstitialAd?.show();
    _interstitialAd = null;
    _loadInterstitialAd();
  }

  BannerAd? createBannerAd({VoidCallback? onLoaded, VoidCallback? onFailed}) {
    if (!_initialized) return null;
    return BannerAd(
      adUnitId: _bannerAdId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => onLoaded?.call(),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          onFailed?.call();
        },
      ),
    )..load();
  }

  void loadRewardedAd({required void Function() onRewarded}) {
    if (!_initialized) return;
    RewardedAd.load(
      adUnitId: _rewardedAdId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.show(onUserEarnedReward: (_, _) => onRewarded());
        },
        onAdFailedToLoad: (_) {},
      ),
    );
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}

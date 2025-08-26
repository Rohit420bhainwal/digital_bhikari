

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';

class InterstitialAdManager with WidgetsBindingObserver {
  InterstitialAd? _interstitialAd;
  DateTime? _adLoadedTime;
  final String adUnitId;

  InterstitialAdManager({required this.adUnitId}) {
    WidgetsBinding.instance.addObserver(this);
    _loadAd();
  }

  void _loadAd() {
    var testAdUnit = "ca-app-pub-3940256099942544/1033173712";
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _adLoadedTime = DateTime.now();
          debugPrint("✅ Interstitial Ad Loaded");
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialAd = null;
          debugPrint("❌ Failed to load interstitial ad: $error");
        },
      ),
    );
  }

  bool _isAdFresh() {
    if (_adLoadedTime == null) return false;
    return DateTime.now().difference(_adLoadedTime!).inMinutes < 120; // < 2 hours
  }

  void showAd() {
    if (_interstitialAd != null && _isAdFresh()) {
      _interstitialAd!.show();
      _interstitialAd = null;
      _loadAd(); // Preload next ad
    } else {
      debugPrint("⚠️ Ad expired or not loaded. Reloading...");
      _loadAd();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!_isAdFresh()) {
        debugPrint("🔄 Reloading ad after resume (expired)");
        _loadAd();
      }
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _interstitialAd?.dispose();
  }
}

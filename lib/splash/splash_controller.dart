import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../auth/auth_controller.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../downtime/downtime_screen.dart';

class SplashController extends GetxController {
  InterstitialAd? _interstitialAd;

  @override
  void onInit() {
    super.onInit();
    _loadAd();
    _handleSplashLogic();
  }

  Future<void> _handleSplashLogic() async {
    // Wait for splash animation or minimum time
    await Future.delayed(const Duration(seconds: 2));

    // Fetch config
    final versionDoc = await FirebaseFirestore.instance.collection('app_config').doc('version').get();
    final data = versionDoc.data() ?? {};

    // Downtime check
    if (data['downtime'] == true) {
      // Show downtime screen and ad
      Get.offAll(() => DowntimeScreen(
        message: data['downtime_message'] ?? "We are under maintenance. Please try again later.",
        ad: _interstitialAd,
      ));
      return;
    }

    // Version check as before
    final shouldProceed = await checkAppVersion(Get.context!);
    if (!shouldProceed) return;

    // Show ad if loaded
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      await Future.delayed(const Duration(seconds: 2));
    }

    // Navigate to next screen
    final auth = Get.find<AuthController>();
    if (auth.isLoggedIn.value) {
      Get.offAllNamed('/base');
    } else {
      Get.offAllNamed('/login');
    }
  }

  void _loadAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-5357447465713123/4529461813',
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) => _interstitialAd = null,
      ),
    );
  }

  @override
  void onClose() {
    _interstitialAd?.dispose();
    super.onClose();
  }
}

// Return true if user can proceed, false if forced update
Future<bool> checkAppVersion(BuildContext context) async {
  final versionDoc = await FirebaseFirestore.instance.collection('app_config').doc('version').get();
  final data = versionDoc.data() ?? {};

  final PackageInfo packageInfo = await PackageInfo.fromPlatform();
  final int currentVersion = int.tryParse(packageInfo.buildNumber) ?? 1;

  final int minVersion = data['android_min'] ?? 1;
  final int latestVersion = data['android_latest'] ?? minVersion;
  final String updateMessage = data['update_message'] ?? "A new version is available!";
  final String forceUpdateMessage = data['force_update_message'] ?? "Please update to continue.";
  final String playStoreUrl = data['play_store_url'] ?? "";

  print("minVersion: $minVersion");
  print("latestVersion: $latestVersion");
  print("currentVersion: $currentVersion");

  if (currentVersion < minVersion) {
    // Force update
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text("Update Required"),
        content: Text(forceUpdateMessage),
        actions: [
          ElevatedButton(
            onPressed: () {
              launchUrl(Uri.parse(playStoreUrl));
            },
            child: Text("Update Now"),
          ),
        ],
      ),
    );
    return false; // Don't proceed
  } else if (currentVersion < latestVersion) {
    // Optional update
    bool proceed = true;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Update Available"),
        content: Text(updateMessage),
        actions: [
          TextButton(
            onPressed: () {
              proceed = true;
              Navigator.of(context).pop();
            },
            child: Text("Later"),
          ),
          ElevatedButton(
            onPressed: () {
              launchUrl(Uri.parse(playStoreUrl));
            },
            child: Text("Update"),
          ),
        ],
      ),
    );
    return proceed;
  }
  return true;
}
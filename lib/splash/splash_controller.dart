import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../auth/auth_controller.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../downtime/downtime_screen.dart';
import '../utils/interstitialad_manager.dart';

class SplashController extends GetxController {
  InterstitialAd? _interstitialAd;
  final Completer<void> _adLoadCompleter = Completer<void>();
  late InterstitialAdManager adManager;
  @override
  void onInit() {
    super.onInit();
    adManager = InterstitialAdManager(adUnitId: 'ca-app-pub-5357447465713123/4529461813');

    _startSplashLogic();
  }


  @override
  void dispose() {
    adManager.dispose();
    super.dispose();
  }
  Future<void> _startSplashLogic() async {
    await Future.delayed(const Duration(seconds: 2));
    await _handleSplashLogic();
  }

  Future<void> _handleSplashLogic() async {
    await Future.delayed(const Duration(seconds: 2));

    final versionDoc = await FirebaseFirestore.instance.collection('app_config').doc('version').get();
    final data = versionDoc.data() ?? {};

    final shouldProceed = await checkAppVersion(Get.context!);
    if (!shouldProceed) return;

    // ✅ Load ad fresh just before showing
   // await _loadAd();
    adManager.showAd();

/*
    if (_interstitialAd != null) {
      print("InterstitialAd is not null. Showing ad...");
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          print("Ad dismissed. Disposing...");
          ad.dispose();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print("Ad failed to show: $error");
          ad.dispose();
        },
      );

      _interstitialAd!.show();
      _interstitialAd = null;
      await Future.delayed(const Duration(seconds: 2));
    } else {
      print("InterstitialAd is null. Skipping ad.");
    }
*/

    final auth = Get.find<AuthController>();
    if (auth.isLoggedIn.value) {
      if (data['downtime'] == true) {
        Get.offAll(() => DowntimeScreen(
          message: data['downtime_message'] ?? "We are under maintenance. Please try again later.",
          title: data['downtime_title'] ?? "Downtime",
        ));
        return;
      }
      Get.offAllNamed('/base');
    } else {
      Get.offAllNamed('/login');
    }
  }
  /// ✅ Load ad fresh before use
  Future<void> _loadAd() async {
    final completer = Completer<void>();

    InterstitialAd.load(
      adUnitId: 'ca-app-pub-5357447465713123/4529461813',
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          Fluttertoast.showToast(
            msg: "Interstitial Ad loaded!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          completer.complete();
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          Fluttertoast.showToast(
            msg: "Ad failed to load!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          print("InterstitialAd failed to load: $error");
          completer.complete();
        },
      ),
    );

    return completer.future;
  }


  @override
  void onClose() {
    _interstitialAd?.dispose();
    super.onClose();
  }
}


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
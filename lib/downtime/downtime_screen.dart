import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

import '../utils/interstitialad_manager.dart';

class DowntimeScreen extends StatefulWidget {
  final String message;
  final String title;
 /* final InterstitialAd? ad;*/
  const DowntimeScreen({Key? key, required this.message/*, this.ad*/, required this.title}) : super(key: key);

  @override
  State<DowntimeScreen> createState() => _DowntimeScreenState();
}

class _DowntimeScreenState extends State<DowntimeScreen> {
  InterstitialAd? _interstitialAd;
  late InterstitialAdManager adManager;
  @override
  void initState() {
    super.initState();
   // adManager = InterstitialAdManager(adUnitId: 'ca-app-pub-5357447465713123/4529461813');

    // Show ad if available
   /* if (widget.ad != null) {
      widget.ad!.show();
    }*/

  }

  @override
  void dispose(){
    //adManager.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    // Exit the app
    exit(0);
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.blue.shade900,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.yellow, size: 80),
                SizedBox(height: 24),
                Text(
                  "Downtime",
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  widget.message,
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                Text(
                  "Please try again later.",
                  style: TextStyle(color: Colors.white54),
                ),

                /*ElevatedButton.icon(
                  icon: Icon(Icons.ads_click),
                  label: Text('click ads'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onPressed: (){
                   // adManager.showAd();
                  //  loadInterstitialAd();
                  },
                ),*/
              ],
            ),
          ),
        ),
      ),
    );
  }

  void loadInterstitialAd()  {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-5357447465713123/4529461813',
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) async {
          _interstitialAd = ad;
          await Future.delayed(const Duration(seconds: 2));
          showInterstitialAd();
          print('Interstitial Ad Loaded');
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Interstitial Ad Failed to Load: $error');
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      print('Ad not ready or expired');
    }
  }
}
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../auth/auth_controller.dart';

class SplashController extends GetxController {
  InterstitialAd? _interstitialAd;

  @override
  void onInit() {
    super.onInit();
    _loadAd();
    Future.delayed(const Duration(seconds: 3), () async {
      if (_interstitialAd != null) {
        _interstitialAd!.show();
        await Future.delayed(const Duration(seconds: 2)); // Wait for ad to close
      }
      final auth = Get.find<AuthController>();
      if (auth.isLoggedIn.value) {
        Get.offAllNamed('/base');
      } else {
        Get.offAllNamed('/login');
      }
    });
  }

  void _loadAd() {
    //ca-app-pub-3940256099942544/1033173712 test id
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-5357447465713123/4529461813', // Test ID, replace with your own
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
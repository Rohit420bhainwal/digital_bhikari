import 'package:get/get.dart';
import '../auth/auth_controller.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(seconds: 2), () {
      final auth = Get.find<AuthController>();
      if (auth.isLoggedIn.value) {
     //   Get.offAllNamed('/base');
        Get.toNamed('/upi');
      } else {
        Get.offAllNamed('/login');
      }
    });
  }
}
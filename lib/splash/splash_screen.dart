import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'splash_controller.dart';


class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Get.put(SplashController());
    return Scaffold(
      body: Center(
        child: Text('Splash Screen', style: TextStyle(fontSize: 32)),
      ),
    );
  }
}
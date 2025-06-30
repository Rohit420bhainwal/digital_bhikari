import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_controller.dart';

class GoogleSignInPage extends StatelessWidget {
  final AuthController controller = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          icon: Icon(Icons.login),
          label: Text('Sign in with Google'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          onPressed: controller.signInWithGoogle,
        ),
      ),
    );
  }
}
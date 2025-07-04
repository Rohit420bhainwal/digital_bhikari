/*
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController extends GetxController {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final box = GetStorage();
  var isLoggedIn = false.obs;
  var userName = ''.obs;
  var userEmail = ''.obs;
  var profilePicture = ''.obs;
  var createdAt = ''.obs;

  @override
  void onInit() {
    super.onInit();
    isLoggedIn.value = box.read('isLoggedIn') ?? false;
    userName.value = box.read('userName') ?? '';
    userEmail.value = box.read('userEmail') ?? '';
    profilePicture.value = box.read('profilePicture') ?? '';
    createdAt.value = box.read('createdAt') ?? '';
  }

  Future<void> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        isLoggedIn.value = true;
        userName.value = account.displayName ?? '';
        userEmail.value = account.email;

        box.write('isLoggedIn', true);
        box.write('userName', userName.value);
        box.write('userEmail', userEmail.value);

        // Store only name and email in Firestore
        await FirebaseFirestore.instance.collection('users').doc(userEmail.value).set({
          'name': userName.value,
          'email': userEmail.value,
        }, SetOptions(merge: true));

        Get.offAllNamed('/base');
      }
    } catch (e) {
      print('Google Sign-In error: $e');
      Get.snackbar('Error', 'Google Sign-In failed');
    }
  }

  void signOut() async {
    await _googleSignIn.signOut();
    isLoggedIn.value = false;
    box.erase();
    Get.offAllNamed('/login');
  }
}*/


import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';

class AuthController extends GetxController {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final box = GetStorage();
  var isLoggedIn = false.obs;
  var userName = ''.obs;
  var userEmail = ''.obs;
  var profilePicture = ''.obs;
  var createdAt = ''.obs;

  @override
  void onInit() {
    super.onInit();
    isLoggedIn.value = box.read('isLoggedIn') ?? false;
    userName.value = box.read('userName') ?? '';
    userEmail.value = box.read('userEmail') ?? '';
    profilePicture.value = box.read('profilePicture') ?? '';
    createdAt.value = box.read('createdAt') ?? '';

    if (isLoggedIn.value && userEmail.value.isNotEmpty) {
      _validateDevice(userEmail.value);
    }
  }

  Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id ?? 'unknown';
  }

  Future<void> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        final deviceId = await _getDeviceId();
        final userDoc = FirebaseFirestore.instance.collection('users').doc(account.email);
        final doc = await userDoc.get();

        final storedDeviceId = doc.data()?['currentDeviceId'];
        if (storedDeviceId != null && storedDeviceId != deviceId) {
          Get.snackbar('Login Blocked', 'This account is already logged in on another device.');
          return;
        }

        // Save locally
        isLoggedIn.value = true;
        userName.value = account.displayName ?? '';
        userEmail.value = account.email;

        box.write('isLoggedIn', true);
        box.write('userName', userName.value);
        box.write('userEmail', userEmail.value);

        // Store to Firestore
        await userDoc.set({
          'name': userName.value,
          'email': userEmail.value,
          'currentDeviceId': deviceId,
        }, SetOptions(merge: true));

        Get.offAllNamed('/base');
      }
    } catch (e) {
      print('Google Sign-In error: $e');
      Get.snackbar('Error', 'Google Sign-In failed');
    }
  }

  Future<void> _validateDevice(String email) async {
    final deviceId = await _getDeviceId();
    final doc = await FirebaseFirestore.instance.collection('users').doc(email).get();
    final storedDeviceId = doc.data()?['currentDeviceId'];

    if (storedDeviceId != deviceId) {
      await signOut(force: true);
      Get.snackbar("Logged Out", "Account logged in from another device.");
    }
  }

  Future<void> signOut({bool force = false}) async {
    if (!force) {
      final deviceId = await _getDeviceId();
      final doc = await FirebaseFirestore.instance.collection('users').doc(userEmail.value).get();
      if (doc.exists && doc.data()?['currentDeviceId'] == deviceId) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userEmail.value)
            .update({'currentDeviceId': FieldValue.delete()});
      }
    }

    await _googleSignIn.signOut();
    isLoggedIn.value = false;
    box.erase();
    Get.offAllNamed('/login');
  }
}


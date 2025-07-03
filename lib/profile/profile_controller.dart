import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../auth/auth_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileController extends GetxController {
  var userName = ''.obs;
  var userEmail = ''.obs;
  var profilePicture = ''.obs;
  var status = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final auth = Get.find<AuthController>();
    userEmail.value = auth.userEmail.value;
    fetchProfile();
  }

  void fetchProfile() async {
    if (userEmail.value.isEmpty) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(userEmail.value).get();
    final data = doc.data();
    if (data != null) {
      userName.value = data['name'] ?? '';
      profilePicture.value = data['profilePicture'] ?? '';
      status.value = data['status'] ?? '';
      // Sync with AuthController for drawer update
      final auth = Get.find<AuthController>();
      auth.profilePicture.value = profilePicture.value;
      auth.userName.value = userName.value;
    }
  }

  Future<void> updateProfile({String? name, String? status, String? profilePicture}) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (status != null) updates['status'] = status;
    if (profilePicture != null) updates['profilePicture'] = profilePicture;
    if (updates.isNotEmpty) {
      await FirebaseFirestore.instance.collection('users').doc(userEmail.value).update(updates);
      fetchProfile();
    }
  }

  Future<void> pickAndUploadImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 70);
    if (picked != null) {
      final file = File(picked.path);
      final url = await uploadProfileImageToCloudinary(file);
      if (url != null) {
        await updateProfile(profilePicture: url);
        profilePicture.value = url; // Update local observable
        // Also update in AuthController for drawer
        final auth = Get.find<AuthController>();
        auth.profilePicture.value = url;
      } else {
        Get.snackbar('Error', 'Image upload failed. Please try again.');
      }
    }
  }

  Future<String?> uploadProfileImageToCloudinary(File imageFile) async {
    try {
      final cloudName = 'djfkguxxc';
      final uploadPreset = 'digital_bhikari_unsigned'; // Your unsigned preset
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      final response = await request.send();
      final resStr = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        final data = json.decode(resStr);
        return data['secure_url'];
      } else {
        Get.snackbar('Image Upload Failed', 'Cloudinary error: $resStr');
        return null;
      }
    } catch (e) {
      Get.snackbar('Image Upload Failed', e.toString());
      return null;
    }
  }
}
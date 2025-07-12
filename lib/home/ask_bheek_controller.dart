import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../auth/auth_controller.dart';
import '../utils/bheek_messages.dart';

class AskBheekController extends GetxController {
  final messageController = TextEditingController();
  final upiIdController = TextEditingController();
  var hasUpiId = false.obs;
  var funnyMessages = <String>[].obs;
  var selectedImage = Rxn<File>();
  var imageUrl = ''.obs;
  final auth = Get.find<AuthController>();
  InterstitialAd? _interstitialAd;
  final Color primaryColor = const Color(0xFF1976D2);
  final Color accentColor = const Color(0xFFFFC107);
  var isSubmitting = false.obs;

  static final List<String> staticFunnyMessages = [
    "Bhai, lunch ke liye ₹50 bhej de, bhookh lagi hai!",
    "UPI bhej, chai peene jana hai!",
    "Aaj mood nahi hai, bheek de!",
    "Mujhe bhi influencer banna hai, bheek do!",
    "Paise nahi hai, par attitude full hai!",
    "Aaj ka target: ₹100 bheek!",
    "Bhai, recharge karwana hai, bheek de!",
    "Petrol khatam ho gaya, bheek de!",
    "Aaj ghar pe sabzi nahi bani, bheek de!",
    "Bhai, treat chahiye, bheek de!",
    "UPI bhej, dosti nibha!",
    "Aaj salary nahi aayi, bheek de!",
    "Bhai, Netflix renew karna hai!",
    "Aaj ka lunch sponsor kar de!",
    "Bhai, date pe jaana hai, bheek de!",
    "Aaj ka motivation: bheek mil jaye!",
    "Bhai, shopping karni hai, bheek de!",
    "Aaj ka challenge: 1 rupee bheek!",
    "Bhai, nayi movie dekhni hai, bheek de!",
    "Aaj ka swag: bheek mangna!",
    "Bhai, nayi game kharidni hai, bheek de!",
    "Aaj ka mood: bheek mangne ka!",
    "Bhai, party karni hai, bheek de!",
    "Aaj ka plan: bheek se khana!",
    "Bhai, nayi shirt chahiye, bheek de!",
    "Aaj ka goal: 10 logon se bheek!",
    "Bhai, mobile data khatam ho gaya!",
    "Aaj ka status: bheek on!",
    "Bhai, nayi bike chahiye, bheek de!",
    "Aaj ka dream: bheek se trip!",
    "Bhai, exam fees deni hai, bheek de!",
    "Aaj ka hope: bheek mil jaye!",
    "Bhai, nayi shoes chahiye, bheek de!",
    "Aaj ka wish: bheek se pizza!",
    "Bhai, birthday gift chahiye, bheek de!",
    "Aaj ka funda: bheek mang!",
    "Bhai, nayi book chahiye, bheek de!",
    "Aaj ka scene: bheek se survive!",
    "Bhai, nayi watch chahiye, bheek de!",
    "Aaj ka plan: bheek se recharge!",
    "Bhai, nayi specs chahiye, bheek de!",
    "Aaj ka target: bheek se treat!",
    "Bhai, nayi bag chahiye, bheek de!",
    "Aaj ka mood: bheek se khushi!",
    "Bhai, nayi pen chahiye, bheek de!",
    "Aaj ka aim: bheek se shopping!",
    "Bhai, nayi cap chahiye, bheek de!",
    "Aaj ka swag: bheek se style!",
    "Bhai, nayi jeans chahiye, bheek de!",
    "Aaj ka wish: bheek se movie!",
  ];

  /*final List<String> bheekSuccessMessages = [
    "Bheek ka request gaya... ab toh Ambani bhi dar gaya! 💸😂",
    "Server hil gaya re baba... tere request se! 😂🙏",
    "Tumne bheek maangi... aur universe ne suna! 🌌💰",
    "Request gaya... ab paisa aane ka intezaar karo! 📩💸",
    "Digital Bhikari bhi impressed ho gaya tumse! 😎🧢",
    "System bolta: Bheek requested successfully... aur mast style mein! 😁🪙",
    "UPI ready ho gaya... ab bhagwan hi bheek bheje! 🙏📱",
    "Tumne button dabaya... aur bhikari ka sapna saj gaya! 🎉😄",
    "Aree bhai, aise bheek maangoge toh Oscar bhi milega! 🏆😂",
    "Yeh hui na baat! Digital bhikh bhi fashion ban gaya! 🤳🧢"
  ];*/


  @override
  void onInit() {
    super.onInit();
    _loadUpiId();
    fetchFunnyMessages();
    _loadAd();
  }

  Future<void> fetchFunnyMessages() async {
    final snapshot = await FirebaseFirestore.instance.collection('funny_messages').get();
    funnyMessages.value = snapshot.docs.map((doc) => doc['text'] as String).toList();
  }

  Future<void> _loadUpiId() async {
    final auth = Get.find<AuthController>();
    final doc = await FirebaseFirestore.instance.collection('users').doc(auth.userEmail.value).get();
    if (doc.exists && doc.data()?['upiId'] != null && doc.data()!['upiId'].toString().isNotEmpty) {
      upiIdController.text = doc.data()!['upiId'];
      hasUpiId.value = true;
    } else {
      hasUpiId.value = false;
    }
  }

  Future<void> saveUpiId() async {
    final upiId = upiIdController.text.trim();
    if (upiId.isEmpty) {
      Get.snackbar('Error', 'Please enter your UPI ID');
      return;
    }
    final auth = Get.find<AuthController>();
    await FirebaseFirestore.instance.collection('users').doc(auth.userEmail.value).set({
      'upiId': upiId,
    }, SetOptions(merge: true));
    hasUpiId.value = true;
    Get.snackbar('Success', 'UPI ID saved!');
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      selectedImage.value = File(picked.path);
    }
  }

  Future<String?> uploadImage(String userEmail) async {
    if (selectedImage.value == null) return null;
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('feed_images')
          .child('${userEmail}_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(selectedImage.value!);
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      Get.snackbar('Image Upload Failed', e.message ?? 'Unknown error');
      return null;
    } catch (e) {
      Get.snackbar('Image Upload Failed', e.toString());
      return null;
    }
  }

  Future<String?> uploadImageToCloudinary(File imageFile) async {
    const int maxImageSizeInMB = 5;

    final int fileSizeInBytes = await imageFile.length();
    final double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

    if (fileSizeInMB > maxImageSizeInMB) {
      Get.snackbar(
        'File Too Large',
        'Please upload an image smaller than $maxImageSizeInMB MB.',
      );
      return null;
    }

    try {
      final cloudName = 'djfkguxxc';
      final uploadPreset = 'digital_bhikari_unsigned';

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



  /*void askBheek() async {
    if (isSubmitting.value) return; // Avoid double tap
    isSubmitting.value = true;

    final message = messageController.text.trim();
    if (message.isEmpty) {
      Get.snackbar('Error', 'Please enter a message');
      return;
    }
    final auth = Get.find<AuthController>();
    final upiId = upiIdController.text.trim();

    // --- Restriction: Only 3 requests per week ---
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(Duration(days: 7));
    final userFeeds = await FirebaseFirestore.instance
        .collection('feeds')
        .where('email', isEqualTo: auth.userEmail.value)
        .where('createdAt', isGreaterThan: Timestamp.fromDate(oneWeekAgo))
        .get();

    if (userFeeds.docs.length >= 3) {
      Get.defaultDialog(
        title: 'Limit Reached!',
        titleStyle: TextStyle(
          color: Colors.red.shade700,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
        content: Column(
          children: [
            Icon(Icons.lock_clock, color: Colors.red.shade400, size: 48),
            SizedBox(height: 16),
            Text(
              'You can only create 3 Bheek requests per week.\n\nTry again next week!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
          ],
        ),
        confirm: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text('OK', style: TextStyle(color: Colors.white)),
          onPressed: () => Get.back(),
        ),
        radius: 16,
      );
      return;
    }
    // --- End Restriction ---

    String? uploadedImageUrl;
    if (selectedImage.value != null) {
      uploadedImageUrl = await uploadImageToCloudinary(selectedImage.value!);
      if (uploadedImageUrl == null) {
        Get.snackbar('Error', 'Image upload failed. Please try again.');
        return;
      }
    }

    await FirebaseFirestore.instance.collection('feeds').add({
      'name': auth.userName.value,
      'email': auth.userEmail.value,
      'upi': upiId,
      'message': message,
      'imageUrl': uploadedImageUrl ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
    _showAskBheekSuccess(message);
    messageController.clear();
    selectedImage.value = null;
    await Future.delayed(Duration(seconds: 1));
    _showAd();
  }*/

  void askBheek() async {
    if (isSubmitting.value) return; // Prevent multiple submissions
    isSubmitting.value = true;

    try {
      final message = messageController.text.trim();
      if (message.isEmpty) {
        Get.snackbar('Error', 'Please enter a message');
        return;
      }

      final auth = Get.find<AuthController>();
      final upiId = upiIdController.text.trim();

      // --- Restriction: Only 3 requests per week ---
      final now = DateTime.now();
      final oneWeekAgo = now.subtract(const Duration(days: 7));
      final userFeeds = await FirebaseFirestore.instance
          .collection('feeds')
          .where('email', isEqualTo: auth.userEmail.value)
          .where('createdAt', isGreaterThan: Timestamp.fromDate(oneWeekAgo))
          .get();

      if (userFeeds.docs.length >= 3) {
        Get.defaultDialog(
          title: 'Limit Reached!',
          titleStyle: TextStyle(
            color: Colors.red.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
          content: Column(
            children: [
              Icon(Icons.lock_clock, color: Colors.red.shade400, size: 48),
              const SizedBox(height: 16),
              Text(
                'You can only create 3 Bheek requests per week.\n\nTry again next week!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
            ],
          ),
          confirm: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
            onPressed: () => Get.back(),
          ),
          radius: 16,
        );
        return;
      }
      // --- End Restriction ---

      String? uploadedImageUrl;
      if (selectedImage.value != null) {
        uploadedImageUrl = await uploadImageToCloudinary(selectedImage.value!);
        if (uploadedImageUrl == null) {
          Get.snackbar('Error', 'Image upload failed. Please try again.');
          return;
        }
      }

      await FirebaseFirestore.instance.collection('feeds').add({
        'name': auth.userName.value,
        'email': auth.userEmail.value,
        'upi': upiId,
        'message': message,
        'imageUrl': uploadedImageUrl ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showAskBheekSuccess(message);
      messageController.clear();
      selectedImage.value = null;

      await Future.delayed(const Duration(seconds: 1));
      _showAd();

    } catch (e) {
      Get.snackbar('Error', 'Something went wrong: $e');
    } finally {
      isSubmitting.value = false;
    }
  }


  void _showAskBheekSuccess(String message) {

    final funnyMessage = BheekMessages.getRandomMessage();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.emoji_emotions, color: accentColor, size: 60),
              const SizedBox(height: 16),
              Text(
                funnyMessage,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('OK', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }



  void _loadAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-5357447465713123/4529461813', // Replace with your actual Ad Unit ID
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          print('Interstitial ad loaded');
        },
        onAdFailedToLoad: (error) {
          print('Interstitial ad failed to load: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  void _showAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadAd(); // Preload next ad
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _loadAd(); // Try loading again
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null; // Avoid showing the same ad again
    } else {
      print('Interstitial ad not ready yet');
    }
  }


  Future<void> uploadFunnyMessages() async {
    final batch = FirebaseFirestore.instance.batch();
    final collection = FirebaseFirestore.instance.collection('funny_messages');
    for (final msg in staticFunnyMessages) {
      final doc = collection.doc();
      batch.set(doc, {'text': msg});
    }
    await batch.commit();
    Get.snackbar('Success', 'Funny messages uploaded!');
  }

  List<String> get randomFunnyMessages {
    final list = List<String>.from(funnyMessages);
    list.shuffle(Random());
    return list.take(10).toList();
  }

  @override
  void onClose() {
    messageController.dispose();
    upiIdController.dispose();
    _interstitialAd?.dispose();
    super.onClose();
  }
}

Future<void> updateBheekStats({
  required String donorEmail,
  required String receiverEmail,
  required int amount,
}) async {
  final users = FirebaseFirestore.instance.collection('users');

  // Update donor's totalBheekGiven
  await users.doc(donorEmail).set({
    'totalBheekGiven': FieldValue.increment(amount),
  }, SetOptions(merge: true));

  // Update receiver's totalBheekReceived
  await users.doc(receiverEmail).set({
    'totalBheekReceived': FieldValue.increment(amount),
  }, SetOptions(merge: true));
}

Future<void> processDonation({
  required String feedOwnerEmail,
  required int donatedAmount,
}) async {
  final auth = Get.find<AuthController>();
  final currentUserEmail = auth.userEmail.value;

  // 1. Your payment logic here (e.g., open UPI intent, wait for success)
  // ...

  // 2. After payment is successful, update stats:
  await updateBheekStats(
    donorEmail: currentUserEmail,
    receiverEmail: feedOwnerEmail,
    amount: donatedAmount,
  );

  // 3. Optionally, show a success message or update UI
  Get.snackbar('Thank you!', 'Your donation was successful.');
}


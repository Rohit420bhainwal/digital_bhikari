import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/auth_controller.dart';

class AskBheekController extends GetxController {
  final messageController = TextEditingController();
  final upiIdController = TextEditingController();
  var hasUpiId = false.obs;
  var funnyMessages = <String>[].obs;

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

  @override
  void onInit() {
    super.onInit();
    _loadUpiId();
    fetchFunnyMessages();
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

  void askBheek() async {
    final message = messageController.text.trim();
    if (message.isEmpty) {
      Get.snackbar('Error', 'Please enter a message');
      return;
    }
    final auth = Get.find<AuthController>();
    final upiId = upiIdController.text.trim();

    // Add feed to Firestore
    await FirebaseFirestore.instance.collection('feeds').add({
      'name': auth.userName.value,
      'email': auth.userEmail.value,
      'upi': upiId,
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
    });

    Get.snackbar(
      'Request Sent',
      'Message: $message',
      backgroundColor: Colors.green.shade100,
      colorText: Colors.black,
      duration: Duration(seconds: 2),
    );
    messageController.clear();
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
    super.onClose();
  }
}


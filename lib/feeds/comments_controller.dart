import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CommentsController extends GetxController {
  final String postId;
  CommentsController(this.postId);

  var comments = <Map<String, dynamic>>[].obs;
  final commentController = TextEditingController();
  var isSending = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchComments();
  }

  void fetchComments() {
    FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((snapshot) {
      comments.value = snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  Future<void> sendComment(String userName, String userEmail) async {
    final text = commentController.text.trim();
    if (text.isEmpty) return;
    isSending.value = true;
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .add({
        'userName': userName,
        'userId': userEmail,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      commentController.clear();
      Get.snackbar('Success', 'Comment sent!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to send comment');
    }
    isSending.value = false;
  }
}
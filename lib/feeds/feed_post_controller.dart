import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FeedPostController extends GetxController {
  final String postId;
  final String userId;
  FeedPostController({required this.postId, required this.userId});

  var likesCount = 0.obs;
  var isLiked = false.obs;
  var comments = <Map<String, dynamic>>[].obs;
  final commentText = ''.obs; // 🔹 Add this line
  final commentController = TextEditingController();
  var isSending = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLikes();
    fetchComments();
  }

  void fetchLikes() {
    FirebaseFirestore.instance
        .collection('feeds')
        .doc(postId)
        .collection('likes')
        .snapshots()
        .listen((snapshot) {
      likesCount.value = snapshot.size;
      isLiked.value = snapshot.docs.any((doc) => doc.id == userId);
    });
  }

  Future<void> toggleLike() async {
    final likeRef = FirebaseFirestore.instance
        .collection('feeds')
        .doc(postId)
        .collection('likes')
        .doc(userId);

    if (isLiked.value) {
      await likeRef.delete();
    } else {
      await likeRef.set({'likedAt': FieldValue.serverTimestamp()});
    }
  }

  void fetchComments() {
    FirebaseFirestore.instance
        .collection('feeds')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((snapshot) {
      comments.value = snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  Future<void> sendComment(String userName, String userEmail) async {
 //   final text = commentController.text.trim();
    final text = commentText.value.trim();
    if (text.isEmpty) return;
    isSending.value = true;
    try {
      await FirebaseFirestore.instance
          .collection('feeds')
          .doc(postId)
          .collection('comments')
          .add({
        'userName': userName,
        'userId': userEmail,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      commentController.clear();
    } catch (e) {
      Get.snackbar('Error', 'Failed to send comment');
    }
    isSending.value = false;
  }
}
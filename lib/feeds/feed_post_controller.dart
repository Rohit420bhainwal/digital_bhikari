import 'package:get/get.dart';
import 'package:flutter/material.dart';

class FeedPostController extends GetxController {
  var likes = 0.obs;
  var isLiked = false.obs;

  void toggleLike() {
    if (isLiked.value) {
      likes.value--;
      isLiked.value = false;
    } else {
      likes.value++;
      isLiked.value = true;
    }
  }

  void pay() {
    Get.snackbar(
      'Payment',
      'You have chosen to pay for this bheek request.',
      backgroundColor: Colors.green.shade100,
      colorText: Colors.black,
      duration: Duration(seconds: 2),
    );
  }
}
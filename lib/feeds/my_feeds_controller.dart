import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyFeedsController extends GetxController {
  var myFeeds = <QueryDocumentSnapshot>[].obs;
  var isLoading = true.obs;

  void fetchMyFeeds(String email) {
    isLoading.value = true;
    FirebaseFirestore.instance
        .collection('feeds')
        .where('email', isEqualTo: email)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      myFeeds.value = snapshot.docs;
      isLoading.value = false;
    });
  }
}
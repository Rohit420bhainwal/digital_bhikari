import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  var notifications = [].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      final snapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .get();

      notifications.value = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'title': doc['title'],
          'message': doc['message'],
          'timestamp': doc['timestamp']
        };
      }).toList();
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch notifications");
    } finally {
      isLoading.value = false;
    }
  }
}

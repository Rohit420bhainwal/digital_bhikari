import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/auth_controller.dart';

class Leader {
  final String name;
  final int amount; // amount earned in ₹
  final String userId;

  Leader({required this.name, required this.amount, required this.userId});
}

class LeaderboardController extends GetxController {
  final leaders = <Leader>[].obs; // Top Bhikhari
  final donors = <Leader>[].obs;  // Top Donors
  final currentUserId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final auth = Get.find<AuthController>();
    currentUserId.value = auth.userEmail.value;
    fetchLeaders();
    fetchDonors();
  }

  void fetchLeaders() async {
    FirebaseFirestore.instance
        .collection('users')
        .orderBy('totalBheekReceived', descending: true)
        .limit(20)
        .snapshots()
        .listen((snapshot) {
      leaders.value = snapshot.docs.map((doc) {
        final data = doc.data();
        return Leader(
          name: data['name'] ?? doc.id,
          amount: (data['totalBheekReceived'] ?? 0).toInt(),
          userId: doc.id,
        );
      }).toList();
    });
  }

  void fetchDonors() async {
    FirebaseFirestore.instance
        .collection('users')
        .orderBy('totalBheekGiven', descending: true)
        .limit(20)
        .snapshots()
        .listen((snapshot) {
      donors.value = snapshot.docs.map((doc) {
        final data = doc.data();
        return Leader(
          name: data['name'] ?? doc.id,
          amount: (data['totalBheekGiven'] ?? 0).toInt(),
          userId: doc.id,
        );
      }).toList();
    });
  }

  int get currentUserPosition {
    final idx = leaders.indexWhere((l) => l.userId == currentUserId.value);
    return idx == -1 ? -1 : idx + 1;
  }

  int get currentUserDonorPosition {
    final idx = donors.indexWhere((l) => l.userId == currentUserId.value);
    return idx == -1 ? -1 : idx + 1;
  }
}
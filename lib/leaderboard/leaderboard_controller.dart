import 'package:get/get.dart';

class Leader {
  final String name;
  final int amount; // amount earned in ₹

  Leader({required this.name, required this.amount});
}

class LeaderboardController extends GetxController {
  final leaders = <Leader>[].obs;
  final String currentUser = 'You';

  @override
  void onInit() {
    super.onInit();
    // Dummy data for top 50
    leaders.value = List.generate(
      50,
      (i) => Leader(
        name: i == 24 ? currentUser : 'User ${i + 1}',
        amount: 1000 - i * 10, // Amount in ₹
      ),
    );
  }

  int get currentUserPosition =>
      leaders.indexWhere((l) => l.name == currentUser) + 1;
}
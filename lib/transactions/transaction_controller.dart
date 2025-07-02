import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionController extends GetxController {
  var transactions = [].obs;
  var total = 0.obs;

  void fetchTransactions(String userEmail) async {
    FirebaseFirestore.instance
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      final txs = snapshot.docs
          .where((doc) =>
              doc['fromUserId'] == userEmail || doc['toUserId'] == userEmail)
          .toList();
      transactions.value = txs;
      total.value = txs.length;
    });
  }
}
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionController extends GetxController {
  var transactions = [].obs;
  var total = 0.obs;
  Map<String, String> userNames = {};

  Future<void> fetchUserNames(List<String> emails) async {
    final usersRef = FirebaseFirestore.instance.collection('users');

    for (final email in emails) {
      if (userNames.containsKey(email)) continue; // skip already fetched

      final doc = await usersRef.doc(email).get();
      if (doc.exists) {
        userNames[email] = doc['name'] ?? email;
      } else {
        userNames[email] = email;
      }
    }
  }
  void fetchTransactions(String userEmail) async {
    FirebaseFirestore.instance
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .limit(11)
        .snapshots()
        .listen((snapshot) async {
      final txs = snapshot.docs
          .where((doc) =>
      doc['fromUserId'] == userEmail || doc['toUserId'] == userEmail)
          .toList();

      final emailsToFetch = txs
          .map((doc) => [doc['fromUserId'], doc['toUserId']])
          .expand((list) => list)
          .toSet()
          .toList();

      await fetchUserNames(emailsToFetch.cast<String>());

      transactions.value = txs;
      total.value = txs.length;
    });
  }
 /* void fetchTransactions(String userEmail) async {
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
  }*/
}
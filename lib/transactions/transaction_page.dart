import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../auth/auth_controller.dart';
import 'transaction_controller.dart';
import 'package:intl/intl.dart';

class TransactionPage extends StatelessWidget {
  final TransactionController controller = Get.put(TransactionController());
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    controller.fetchTransactions(authController.userEmail.value);

    return Obx(() {
      final txs = controller.transactions;
      return Column(
        children: [
          SizedBox(height: 24),
          Text(
            'Bheek Ka Hisab: ${controller.total}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
          ),
          SizedBox(height: 8),
          Expanded(
            child: txs.isEmpty
                ? Center(child: Text('No transactions found.', style: TextStyle(fontSize: 16)))
                : ListView.builder(
                    itemCount: txs.length,
                    itemBuilder: (context, index) {
                      final tx = txs[index];
                      final isDonor = tx['fromUserId'] == authController.userEmail.value;
                      final amount = tx['amount'] ?? 0;
                      final name = isDonor
                          ? (controller.userNames[tx['toUserId']] ?? tx['toUserId'])
                          : (controller.userNames[tx['fromUserId']] ?? tx['fromUserId']);
                      final date = tx['timestamp'] != null
                          ? DateFormat('dd MMM yyyy, hh:mm a').format(
                              (tx['timestamp'] as Timestamp).toDate())
                          : 'N/A';
                      final paymentId = tx['paymentId'] ?? '';

                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDonor
                                ? [Colors.blue.shade50, Colors.blue.shade100]
                                : [Colors.green.shade50, Colors.green.shade100],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 26,
                            backgroundColor: isDonor ? Colors.blue : Colors.green,
                            child: Icon(
                              isDonor ? Icons.north_east_rounded : Icons.south_west_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          title: Text(
                            isDonor ? 'Bheek Di ₹$amount' : 'Bheek Mili ₹$amount',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDonor ? Colors.blue : Colors.green,
                              fontSize: 17,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isDonor ? 'To: $name' : 'From: $name',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                                ),
                                SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 13, color: Colors.grey[500]),
                                    SizedBox(width: 4),
                                    Text(
                                      date,
                                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(Icons.confirmation_number, size: 13, color: Colors.grey[500]),
                                    SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        'ID: $paymentId',
                                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          trailing: Icon(
                            Icons.receipt_long_rounded,
                            color: Colors.blueAccent,
                            size: 28,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    });
  }
}
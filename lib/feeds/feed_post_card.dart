import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:lottie/lottie.dart';
import 'feed_post_controller.dart';

class FeedPostCard extends StatefulWidget {
  final String name;
  final String upi;
  final String message;
  final int amount;
  final String toUserId;   // Add this
  final String fromUserId; // Add this

  FeedPostCard({
    required this.name,
    required this.upi,
    required this.message,
    required this.amount,
    required this.toUserId,   // Add this
    required this.fromUserId, // Add this
    Key? key,
  }) : super(key: key);

  @override
  _FeedPostCardState createState() => _FeedPostCardState();
}

class _FeedPostCardState extends State<FeedPostCard> {
  late Razorpay _razorpay;
  final FeedPostController controller = Get.put(FeedPostController(), tag: UniqueKey().toString());
  double _lastPaidAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // Show animation dialog and auto-dismiss after 2 seconds
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/animations/success.json',
              width: 120,
              repeat: false,
            ),
            SizedBox(height: 16),
            Text(
              'Bheek given successfully!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );

    await Future.delayed(Duration(seconds: 2));
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    // Add transaction to Firestore
    await FirebaseFirestore.instance.collection('transactions').add({
      'amount': _lastPaidAmount,
      'toUserId': widget.toUserId,
      'fromUserId': widget.fromUserId,
      'timestamp': FieldValue.serverTimestamp(),
      'paymentId': response.paymentId,
    });

    await FirebaseFirestore.instance
  .collection('users')
  .doc(widget.toUserId)
  .update({'totalBheekReceived': FieldValue.increment(_lastPaidAmount)});

   // Get.snackbar('Success', 'Payment successful! Payment ID: ${response.paymentId}');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Get.snackbar('Failed', 'Payment failed! Reason: ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Get.snackbar('Wallet', 'External wallet selected: ${response.walletName}');
  }

  Future<void> payWithRazorpay(BuildContext context) async {
    final amountController = TextEditingController();

    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Amount'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Amount (INR)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final entered = double.tryParse(amountController.text);
              if (entered != null && entered > 0) {
                Navigator.of(context).pop(entered);
              } else {
                Get.snackbar('Invalid', 'Please enter a valid amount');
              }
            },
            child: Text('Pay'),
          ),
        ],
      ),
    );

    if (result == null) return;

    _lastPaidAmount = result; // Store for Firestore

    var options = {
      'key': 'rzp_test_1DP5mmOlF5G5ag',
      'amount': (result * 100).toInt(),
      'name': widget.name,
      'description': widget.message,
      'prefill': {
        'contact': '',
        'email': '',
      },
      'method': {
        'upi': true,
        'card': false,
        'netbanking': false,
        'wallet': false,
        'emi': false,
        'paylater': false,
        'cardless_emi': false,
        'bank_transfer': false,
      },
      'theme': {
        'color': '#3399cc'
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      Get.snackbar('Error', 'Unable to open Razorpay: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 6,
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.blue.shade200,
                  child: Text(
                    '🤲',
                    style: TextStyle(fontSize: 28),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Mujhe bheek chahiye!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blueGrey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                Obx(() => Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            controller.isLiked.value
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: controller.isLiked.value
                                ? Colors.pink
                                : Colors.blueAccent,
                            size: 28,
                          ),
                          onPressed: controller.toggleLike,
                        ),
                        Text(
                          '${controller.likes.value}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    )),
              ],
            ),
            SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.message,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            SizedBox(height: 18),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                icon: Icon(Icons.currency_rupee),
                label: Text('Bheek Do'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  elevation: 2,
                ),
                onPressed: () => payWithRazorpay(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
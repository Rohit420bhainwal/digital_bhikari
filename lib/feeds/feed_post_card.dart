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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(widget.name, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('UPI: ${widget.upi}'),
            ),
            SizedBox(height: 12),
            Text(
              widget.message,
              style: TextStyle(fontSize: 16),
            ),
            
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            controller.isLiked.value
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: controller.isLiked.value
                                ? Colors.red
                                : Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: controller.toggleLike,
                        ),
                        Text('${controller.likes.value}'),
                      ],
                    )),
                ElevatedButton.icon(
                  icon: Icon(Icons.currency_rupee),
                  label: Text('Pay'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () => payWithRazorpay(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
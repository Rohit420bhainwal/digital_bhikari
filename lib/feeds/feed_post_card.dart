import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../home/ask_bheek_controller.dart';
import 'feed_post_controller.dart';
import 'comments_sheet.dart';
import 'package:flutter/services.dart';

class FeedPostCard extends StatefulWidget {
  final String name;
  final String upi;
  final String message;
  final int amount;
  final String toUserId;
  final String fromUserId;
  final String postId;
  final bool isTopUser;
  final String imageUrl;
  final bool isAdmin; // <-- Add this

  FeedPostCard({
    required this.name,
    required this.upi,
    required this.message,
    required this.amount,
    required this.toUserId,
    required this.fromUserId,
    required this.postId,
    this.isTopUser = false,
    this.imageUrl = '',
    this.isAdmin = false, // <-- Add this
    Key? key,
  }) : super(key: key);

  @override
  _FeedPostCardState createState() => _FeedPostCardState();
}

class _FeedPostCardState extends State<FeedPostCard> {
  late FeedPostController controller;
  Razorpay? _razorpay;
  _PendingDonation? _pendingDonation;


  @override
  void initState() {
    super.initState();
    controller = Get.put(
      FeedPostController(postId: widget.postId, userId: widget.fromUserId),
      tag: widget.postId + widget.fromUserId,
    );
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay?.clear();
    super.dispose();
  }

  Future<void> startUpiPayment({
    required String upiId,
    required String receiverName,
    required int amount,
    required String feedOwnerEmail,
  }) async {
    var options = {
      'key': 'rzp_test_icz3AXfa29RYVn', // Replace with your Razorpay key
      'amount': amount * 100, // Amount in paise
      'name': receiverName,
      'description': 'Bheek Donation',
      'method': {
        'upi': true,
        'card': false,
        'netbanking': false,
        'wallet': false,
        'emi': false,
        'paylater': false,
      },
      'prefill': {
        'contact': '',
        'email': '',
      },
      'external': {
        'wallets': []
      }
    };

    try {
      print('Starting UPI payment for $feedOwnerEmail');
      _razorpay!.open(options);
      _pendingDonation = _PendingDonation(feedOwnerEmail, amount);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (_pendingDonation != null) {
      // 1. Add transaction record
      final askBheekController = Get.find<AskBheekController>();
      final donorEmail = askBheekController.auth.userEmail.value;
      final receiverEmail = _pendingDonation!.feedOwnerEmail;
      final amount = _pendingDonation!.amount;

      await FirebaseFirestore.instance.collection('transactions').add({
        'fromUserId': donorEmail,
        'toUserId': receiverEmail,
        'amount': amount,
        'paymentId': response.paymentId, // Razorpay payment ID
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 2. Update bheek stats
      await processDonation(
        feedOwnerEmail: receiverEmail,
        donatedAmount: amount,
      );
      _pendingDonation = null;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Successful!')),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed!')),
    );
    _pendingDonation = null;
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet Selected')),
    );
  }

  Future<void> _deleteFeed() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Feed'),
        content: Text('Are you sure you want to delete this feed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseFirestore.instance.collection('feeds').doc(widget.postId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Feed deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = Get.find<AskBheekController>().auth.userEmail.value;
    final isMyOwnFeed = widget.toUserId == currentUserEmail;
    return Card(
      margin: EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 6,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar, Name, Leaderboard Badge
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blue.shade200,
                  child: Text(
                    widget.name.isNotEmpty ? widget.name[0].toUpperCase() : 'B',
                    style: TextStyle(fontSize: 22, color: Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        widget.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      if (widget.isTopUser)
                        Padding(
                          padding: const EdgeInsets.only(left: 6.0),
                          child: Text('🏆', style: TextStyle(fontSize: 20)),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.share, color: Colors.green, size: 24),
                  onPressed: () {
                    Share.share(
                      'Check out this Bheek post by ${widget.name}:\n${widget.message}\nUPI: ${widget.upi}',
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 12),
            // Message/Post Content
            Text(
              widget.message,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            // Image Display (show only if imageUrl is not empty)
            if (widget.imageUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      widget.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: Center(child: Icon(Icons.broken_image)),
                      ),
                    ),
                  ),
                ),
              ),
            SizedBox(height: 18),
            // Like, Comment, Bheek Row
            Row(
              children: [
                // Like Button
                Obx(() => Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        controller.isLiked.value
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: controller.isLiked.value
                            ? Colors.pink
                            : Colors.grey[700],
                        size: 28,
                      ),
                      onPressed: controller.toggleLike,
                    ),
                    Text(
                      '${controller.likesCount.value} likes',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                )),
                SizedBox(width: 8),
                // Comment Button
                IconButton(
                  icon: Icon(Icons.mode_comment_outlined, color: Colors.grey[700], size: 26),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                      ),
                      builder: (_) => CommentsSheet(
                        postId: widget.postId,
                        controller: controller,
                      ),
                    );
                  },
                ),
                Spacer(),
                // Bheek Do Button (icon only)
                if (!isMyOwnFeed)
                ElevatedButton(
                  onPressed: () async {
                    final amountController = TextEditingController();
                    final entered = await showDialog<int>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Enter Amount'),
                        content: TextField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4), // Max 4 digits (up to 1000)
                          ],
                          decoration: InputDecoration(
                            hintText: 'Enter amount in ₹ (1-1000)',
                            errorText: (amountController.text.isNotEmpty &&
                                        (int.tryParse(amountController.text) == null ||
                                         int.parse(amountController.text) < 1 ||
                                         int.parse(amountController.text) > 1000))
                                    ? 'Enter a valid amount (1-1000)'
                                    : null,
                          ),
                          enableInteractiveSelection: false, // Disables copy-paste
                          onChanged: (_) => (context as Element).markNeedsBuild(), // To update errorText
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              final amt = int.tryParse(amountController.text);
                              if (amt != null && amt >= 1 && amt <= 1000) {
                                Navigator.of(context).pop(amt);
                              }
                            },
                            child: Text('Pay'),
                          ),
                        ],
                      ),
                    );

                    if (entered != null && entered > 0) {
                      print('Calling startUpiPayment with feedOwnerEmail: ${widget.toUserId}');
                      await startUpiPayment(
                        upiId: widget.upi,
                        receiverName: widget.name,
                        amount: entered,
                        feedOwnerEmail: widget.toUserId, // This must be the receiver's email!
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(12),
                    elevation: 2,
                  ),
                  child: Icon(
                    Icons.volunteer_activism,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                if (widget.isAdmin)
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: _deleteFeed,
                    tooltip: 'Delete Feed',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> processDonation({
    required String feedOwnerEmail,
    required int donatedAmount,
  }) async {
    try {
      final askBheekController = Get.find<AskBheekController>();
      final donorEmail = askBheekController.auth.userEmail.value;

      final users = FirebaseFirestore.instance.collection('users');
      final now = DateTime.now();
      final nowIso = now.toIso8601String();

      int weekNumber(DateTime date) {
        final firstDayOfYear = DateTime(date.year, 1, 1);
        return ((date.difference(firstDayOfYear).inDays + firstDayOfYear.weekday) / 7).ceil();
      }

      // --- Update Donor's currentWeekDonatedBheek ---
      final donorDoc = await users.doc(donorEmail).get();
      Map<String, dynamic> donorData = donorDoc.data() ?? {};
      Map<String, dynamic> donorWeek = (donorData['currentWeekDonatedBheek'] as Map<String, dynamic>?) ?? {'amount': 0, 'date': nowIso};
      int donorLastAmount = donorWeek['amount'] ?? 0;
      DateTime? donorLastDate = DateTime.tryParse(donorWeek['date'] ?? nowIso);
      int donorLastWeek = donorLastDate != null ? weekNumber(donorLastDate) : -1;
      int donorNowWeek = weekNumber(now);
      int donorNewAmount = (donorNowWeek == donorLastWeek) ? donorLastAmount + donatedAmount : donatedAmount;

      print('Updating donor: $donorEmail');
      await users.doc(donorEmail).set({
        'totalBheekGiven': FieldValue.increment(donatedAmount),
        'currentWeekDonatedBheek': {
          'amount': donorNewAmount,
          'date': nowIso,
        }
      }, SetOptions(merge: true));
      print('Donor updated.');

      // --- Update Receiver's currentWeekReceivedBheek ---
      print('Fetching receiver doc: $feedOwnerEmail');
      final receiverDoc = await users.doc(feedOwnerEmail).get();
      Map<String, dynamic> receiverData = receiverDoc.data() ?? {};
      Map<String, dynamic> receiverWeek = (receiverData['currentWeekReceivedBheek'] as Map<String, dynamic>?) ?? {'amount': 0, 'date': nowIso};
      int receiverLastAmount = receiverWeek['amount'] ?? 0;
      DateTime? receiverLastDate = DateTime.tryParse(receiverWeek['date'] ?? nowIso);
      int receiverLastWeek = receiverLastDate != null ? weekNumber(receiverLastDate) : -1;
      int receiverNowWeek = weekNumber(now);
      int receiverNewAmount = (receiverNowWeek == receiverLastWeek) ? receiverLastAmount + donatedAmount : donatedAmount;

      print('Updating receiver: $feedOwnerEmail');
      await users.doc(feedOwnerEmail).set({
        'totalBheekReceived': FieldValue.increment(donatedAmount),
        'currentWeekReceivedBheek': {
          'amount': receiverNewAmount,
          'date': nowIso,
        }
      }, SetOptions(merge: true));
      print('Receiver updated.');

      // --- Add donation record (optional) ---
      await FirebaseFirestore.instance.collection('donations').add({
        'from': donorEmail,
        'to': feedOwnerEmail,
        'amount': donatedAmount,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Donated ₹$donatedAmount to $feedOwnerEmail!'),
          backgroundColor: Colors.green.shade100,
        ),
      );
    } catch (e) {
      print('Donation error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Donation failed: $e'),
          backgroundColor: Colors.red.shade100,
        ),
      );
    }
  }
}

class _PendingDonation {
  final String feedOwnerEmail;
  final int amount;
  _PendingDonation(this.feedOwnerEmail, this.amount);
}
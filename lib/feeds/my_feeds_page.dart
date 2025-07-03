// filepath: d:\android\flutter\digital_bhikari\lib\feeds\my_feeds_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'feed_post_card.dart';
import '../auth/auth_controller.dart';

class MyFeedsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    print('MyFeedsPage: User Email: ${authController.userEmail.value}');
    return Scaffold(
      appBar: AppBar(title: Text('My Feeds')),
    body: StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('feeds')
//      .where('email', isEqualTo: authController.userEmail.value)
      .orderBy('createdAt', descending: true)
      .snapshots(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
    final posts = snapshot.data!.docs;
    if (posts.isEmpty) return Center(child: Text('No feeds uploaded yet.'));
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index].data() as Map<String, dynamic>;
        return FeedPostCard(
          name: post['name'] ?? '',
          upi: post['upi'] ?? '',
          message: post['message'] ?? '',
          amount: post['amount'] ?? 0,
          toUserId: post['toUserId'] ?? '',
          fromUserId: authController.userEmail.value,
          postId: posts[index].id,
          isTopUser: false,
          imageUrl: post['imageUrl'] ?? '',
        );
      },
    );
  },
),

    );
  }
}
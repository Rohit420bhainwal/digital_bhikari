import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'feed_post_card.dart';
import '../auth/auth_controller.dart'; // <-- Import your AuthController

class FeedsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>(); // <-- Get the controller

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('feeds')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No feeds yet.'));
        }
        final posts = snapshot.data!.docs;
        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index].data() as Map<String, dynamic>;
            return FeedPostCard(
              name: post['name'] ?? '',
              upi: post['upi'] ?? '',
              message: post['message'] ?? '',
              amount: 0,
              toUserId: post['email'] ?? '',
              fromUserId: authController.userEmail.value, // <-- Use current user's email as ID
            );
          },
        );
      },
    );
  }
}
// filepath: d:\android\flutter\digital_bhikari\lib\feeds\my_feeds_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'my_feeds_controller.dart';
import 'feed_post_card.dart';
import '../auth/auth_controller.dart';

class MyFeedsPage extends StatelessWidget {
  final MyFeedsController controller = Get.put(MyFeedsController());

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    controller.fetchMyFeeds(authController.userEmail.value);

    return Scaffold(
      appBar: AppBar(title: Text('My Feeds')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        if (controller.myFeeds.isEmpty) {
          return Center(child: Text('No feeds uploaded yet.'));
        }
        return ListView.builder(
          itemCount: controller.myFeeds.length,
          itemBuilder: (context, index) {
            final post = controller.myFeeds[index].data() as Map<String, dynamic>;
            return FeedPostCard(
              name: post['name'] ?? '',
              upi: post['upi'] ?? '',
              message: post['message'] ?? '',
              amount: post['amount'] ?? 0,
              toUserId: post['toUserId'] ?? '',
              fromUserId: authController.userEmail.value,
              postId: controller.myFeeds[index].id,
              isTopUser: false,
              imageUrl: post['imageUrl'] ?? '',
            );
          },
        );
      }),
    );
  }
}
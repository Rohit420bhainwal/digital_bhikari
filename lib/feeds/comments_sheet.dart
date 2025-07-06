import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'feed_post_controller.dart'; // or comments_controller.dart
import '../auth/auth_controller.dart';

class CommentsSheet extends StatelessWidget {
  final String postId;
  final FeedPostController controller; // or CommentsController
  CommentsSheet({required this.postId, required this.controller});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Obx(() => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Comments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 8),
            Expanded(
              child: controller.comments.isEmpty
                  ? Center(child: Text('No comments yet.'))
                  : ListView.builder(
                itemCount: controller.comments.length,
                itemBuilder: (context, index) {
                  final comment = controller.comments[index];
                  return ListTile(
                    leading: CircleAvatar(child: Text(comment['userName']?[0] ?? '?')),
                    title: Text(comment['userName'] ?? ''),
                    subtitle: Text(comment['text'] ?? ''),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.send,
                    onChanged: (value) => controller.commentText.value = value, // 🔹 Track changes
                    onSubmitted: (_) {
                      if (controller.commentText.value.trim().isNotEmpty &&
                          !controller.isSending.value) {
                        controller.sendComment(
                          authController.userName.value,
                          authController.userEmail.value,
                        );
                      }
                    },
                  ),
                ),
                SizedBox(width: 8),
                Obx(() => controller.isSending.value
                    ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
                    : IconButton(
                  icon: Icon(Icons.send,
                      color: controller.commentText.value.trim().isEmpty
                          ? Colors.grey
                          : Theme.of(context).colorScheme.primary),
                  onPressed: controller.commentText.value.trim().isEmpty ||
                      controller.isSending.value
                      ? null
                      : () => controller.sendComment(
                    authController.userName.value,
                    authController.userEmail.value,
                  ),
                )),
              ],
            ),
          ],
        ),
      ),
    ));
  }
}

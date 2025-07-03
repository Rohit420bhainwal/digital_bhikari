import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'feed_post_controller.dart';
import 'comments_sheet.dart';

class FeedPostCard extends StatefulWidget {
  final String name;
  final String upi;
  final String message;
  final int amount;
  final String toUserId;
  final String fromUserId;
  final String postId;
  final bool isTopUser;
  final String imageUrl; // <-- Add this

  FeedPostCard({
    required this.name,
    required this.upi,
    required this.message,
    required this.amount,
    required this.toUserId,
    required this.fromUserId,
    required this.postId,
    this.isTopUser = false,
    this.imageUrl = '', // <-- Add this
    Key? key,
  }) : super(key: key);

  @override
  _FeedPostCardState createState() => _FeedPostCardState();
}

class _FeedPostCardState extends State<FeedPostCard> {
  late FeedPostController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      FeedPostController(postId: widget.postId, userId: widget.fromUserId),
      tag: widget.postId + widget.fromUserId,
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    aspectRatio: 16 / 9, // You can adjust or make dynamic if you want
                    child: Image.network(
                      widget.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.contain, // <-- Show full image, not cropped
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
                ElevatedButton(
                  onPressed: () {
                    // Your payment logic here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(12),
                    elevation: 2,
                  ),
                  child: Icon(
                    Icons.volunteer_activism, // hand/charity icon
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
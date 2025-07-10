import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'notification_controller.dart';
import 'notification_detail_screen.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.notifications.isEmpty) {
          return const Center(child: Text("No notifications found"));
        }

        return ListView.separated(
          itemCount: controller.notifications.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final notif = controller.notifications[index];
            return ListTile(
              leading: const Icon(Icons.notifications),
              title: Text(notif['title']),
              subtitle: Text(
                notif['message'],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => Get.to(
                    () => const NotificationDetailScreen(),
                arguments: notif,
              ),
            );
          },
        );
      }),
    );
  }
}

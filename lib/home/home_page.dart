import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../feeds/my_feeds_page.dart';
import 'ask_bheek_controller.dart';

class HomePage extends StatelessWidget {
  final AskBheekController controller = Get.put(AskBheekController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Center(
              child: Text(
                'Ask Bheek',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // UPI Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              margin: EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: controller.hasUpiId.value
                    ? Row(
                        children: [
                          Icon(Icons.account_balance_wallet, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Your UPI ID: ${controller.upiIdController.text}',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          TextButton(
                            onPressed: () => controller.hasUpiId.value = false,
                            child: Text('Edit'),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Enter your UPI ID',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: controller.upiIdController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              prefixIcon: Icon(Icons.account_balance_wallet),
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              child: Text('Save UPI ID'),
                              onPressed: controller.saveUpiId,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            // Message Section
            if (controller.hasUpiId.value) ...[
              Text(
                'Your Bheek Message',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller.messageController,
                maxLength: 100,
                minLines: 1,
                maxLines: null,
                decoration: InputDecoration(
                  labelText: 'Type your message (max 100 chars)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.message),
                ),
              ),
              const SizedBox(height: 18),

              // Funny Messages Section
              if (controller.funnyMessages.isNotEmpty) ...[
                Text(
                  'Or pick a funny message:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: controller.randomFunnyMessages.length,
                    separatorBuilder: (_, __) => Divider(height: 1),
                    itemBuilder: (context, index) {
                      final msg = controller.randomFunnyMessages[index];
                      return ListTile(
                        title: Text(msg, style: TextStyle(fontSize: 14)),
                        trailing: Icon(Icons.add_comment, color: Theme.of(context).colorScheme.primary),
                        onTap: () {
                          controller.messageController.text = msg;
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
              ],

              // Image/Meme Picker Section
              Text(
                'Add a meme or image (optional):',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(Icons.image),
                        label: Text('Pick Image'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade50,
                          foregroundColor: Theme.of(context).colorScheme.primary,
                          elevation: 0,
                        ),
                        onPressed: controller.pickImage,
                      ),
                      const SizedBox(width: 16),
                      Obx(() => controller.selectedImage.value != null
                          ? Stack(
                              alignment: Alignment.topRight,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    controller.selectedImage.value!,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => controller.selectedImage.value = null,
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.red,
                                    child: Icon(Icons.close, size: 16, color: Colors.white),
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'No image selected',
                              style: TextStyle(color: Colors.grey),
                            )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Ask Bheek Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.volunteer_activism, color: Colors.white),
                  label: Text('Ask Bheek'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: controller.hasUpiId.value ? controller.askBheek : null,
                ),
              ),
            ],

            // Hidden: Upload Funny Messages (for admin/dev)
            Offstage(
              offstage: true,
              child: ElevatedButton(
                child: Text('Upload Funny Messages'),
                onPressed: controller.uploadFunnyMessages,
              ),
            ),

            // My Feeds Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.list_alt),
                label: Text('My Feeds'),
                onPressed: () => Get.to(() => MyFeedsPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
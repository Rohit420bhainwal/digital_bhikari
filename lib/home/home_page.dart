import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

import '../feeds/my_feeds_page.dart';
import 'ask_bheek_controller.dart';

class HomePage extends StatelessWidget {
  final AskBheekController controller = Get.put(AskBheekController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.grey[100],
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Row: Title + My Feeds Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        /*Icon(Icons.add_circle_outline, color: Colors.orange.shade700, size: 20),
                        SizedBox(width: 10),*/
                        Flexible(
                          child: Text(
                            'Create Your Bheek Feed',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: 1.1,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.blue.shade700,
                    child: IconButton(
                      icon: Icon(Icons.feed, color: Colors.blue.shade50),
                      tooltip: 'My Feeds',
                      onPressed: () => Get.to(() => MyFeedsPage()),
                    ),
                    radius: 22,
                  ),
                ],
              ),
              SizedBox(height: 6),
              Text(
                'Fill the details below to post your Bheek feed!',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),

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

                // Funny Messages Dropdown
                if (controller.funnyMessages.isNotEmpty) ...[
                  Text(
                    'Or pick a bheek message:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: controller.funnyMessages.contains(controller.messageController.text)
                        ? controller.messageController.text
                        : null,
                    hint: Text('Pick a bheek message...'),
                    items: controller.funnyMessages
                        .map((msg) => DropdownMenuItem(
                              value: msg,
                              child: Text(msg, style: TextStyle(fontSize: 14)),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        controller.messageController.text = val;
                        Clipboard.setData(ClipboardData(text: val));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Funny message copied!'), duration: Duration(seconds: 1)),
                        );
                      }
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
                /*SizedBox(
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
                ),*/


                Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: controller.isSubmitting.value
                        ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Icon(Icons.volunteer_activism, color: Colors.white),
                    label: Text(controller.isSubmitting.value ? 'Requesting...' : 'Ask Bheek'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: controller.hasUpiId.value && !controller.isSubmitting.value
                        ? controller.askBheek
                        : null,
                  ),
                ))

              ],

              // Hidden: Upload Funny Messages (for admin/dev)
              Offstage(
                offstage: true,
                child: ElevatedButton(
                  child: Text('Upload Funny Messages'),
                  onPressed: controller.uploadFunnyMessages,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'ask_bheek_controller.dart';

class HomePage extends StatelessWidget {
  final AskBheekController controller = Get.put(AskBheekController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Ask Bheek',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            if (!controller.hasUpiId.value) ...[
              TextField(
                controller: controller.upiIdController,
                decoration: InputDecoration(
                  labelText: 'Enter your UPI ID',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.account_balance_wallet),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  child: Text('Save UPI ID'),
                  onPressed: controller.saveUpiId,
                ),
              ),
            ] else ...[
              TextField(
                controller: controller.messageController,
                maxLength: 100,
                minLines: 1,
                maxLines: null, // Allows the TextField to grow as user types
                decoration: InputDecoration(
                  labelText: 'Message (max 100 chars)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.message),
                ),
              ),
              const SizedBox(height: 12),
              // Show the saved UPI ID
              Row(
                children: [
                  Icon(Icons.account_balance_wallet, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your UPI ID: ${controller.upiIdController.text}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      controller.hasUpiId.value = false;
                    },
                    child: Text('Edit'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Funny messages list
              if (controller.funnyMessages.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Or select a funny message:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: controller.randomFunnyMessages.length,
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
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.send),
                  label: Text('Ask Bheek'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: controller.hasUpiId.value ? controller.askBheek : null,
                ),
              ),
            ],
            Offstage(
              offstage: true, // Set to false if you want to show for testing
              child: ElevatedButton(
                child: Text('Upload Funny Messages'),
                onPressed: controller.uploadFunnyMessages,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:upi_india/upi_india.dart';
import 'feed_post_controller.dart';

class FeedPostCard extends StatelessWidget {
  final String name;
  final String upi;
  final String message;
  final int amount;
  final FeedPostController controller = Get.put(FeedPostController(), tag: UniqueKey().toString());

  FeedPostCard({
    required this.name,
    required this.upi,
    required this.message,
    required this.amount,
    Key? key,
  }) : super(key: key);
  Future<void> payWithUpi(BuildContext context, String upiId, String name) async {
  final amountController = TextEditingController();

  // Ask user for amount
  final result = await showDialog<double>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Enter Amount'),
      content: TextField(
        controller: amountController,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: 'Amount (INR)',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final entered = double.tryParse(amountController.text);
            if (entered != null && entered > 0) {
              Navigator.of(context).pop(entered);
            } else {
              Get.snackbar('Invalid', 'Please enter a valid amount');
            }
          },
          child: Text('Pay'),
        ),
      ],
    ),
  );

  if (result == null) return;

  UpiIndia upi = UpiIndia();
  List<UpiApp> apps = await upi.getAllUpiApps(mandatoryTransactionId: false);

  if (apps.isEmpty) {
    Get.snackbar('No UPI App', 'No UPI app found on this device.');
    return;
  }

  // Let user pick a UPI app
  UpiApp? app = await showDialog<UpiApp>(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text('Select UPI App'),
      children: apps
          .map((app) => ListTile(
                leading: Image.memory(app.icon, width: 40, height: 40),
                title: Text(app.name),
                onTap: () => Navigator.of(context).pop(app),
              ))
          .toList(),
    ),
  );
  if (app == null) return;

  try {
    UpiResponse response = await upi.startTransaction(
      app: app,
      receiverUpiId: upiId,
      receiverName: name,
      transactionRefId: 'TID${DateTime.now().millisecondsSinceEpoch}',
      transactionNote: 'Bheek Payment',
      amount: result,
    );

    if (response.status == UpiPaymentStatus.SUCCESS) {
      Get.snackbar('Success', 'Payment successful!');
    } else if (response.status == UpiPaymentStatus.FAILURE) {
      Get.snackbar('Failed', 'Payment failed!');
    } else if (response.status == UpiPaymentStatus.SUBMITTED) {
      Get.snackbar('Pending', 'Payment submitted, check status in your UPI app.');
    } else {
      Get.snackbar('Cancelled', 'Payment cancelled.');
    }
  } catch (e) {
    Get.snackbar('Error', 'Unable to initiate UPI payment');
  }
}
/*
  Future<void> payWithUpi(BuildContext context, String upiId, String name) async {
    final amountController = TextEditingController();

    // Show dialog to enter amount
    final result = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Amount'),
          content: TextField(
            controller: amountController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Amount (INR)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final entered = double.tryParse(amountController.text);
                if (entered != null && entered > 0) {
                  Navigator.of(context).pop(entered);
                } else {
                  Get.snackbar('Invalid', 'Please enter a valid amount');
                }
              },
              child: Text('Pay'),
            ),
          ],
        );
      },
    );

    if (result == null) return; // User cancelled or invalid

    UpiIndia upi = UpiIndia();
    List<UpiApp> apps = await upi.getAllUpiApps(mandatoryTransactionId: false);

    if (apps.isEmpty) {
      Get.snackbar('No UPI App', 'No UPI app found on this device.');
      return;
    }

    UpiApp? app = await selectUpiApp(context, apps);
    if (app == null) return; // User cancelled

    try {
      // UpiResponse response = await upi.startTransaction(
      //   app: app,
      //   receiverUpiId: upiId,
      //   receiverName: name,
      //   transactionRefId: 'TID${DateTime.now().millisecondsSinceEpoch}',
      //   transactionNote: 'Bheek Payment',
      //   amount: result,
      // );
UpiResponse response = await upi.startTransaction(
  app: app, // still let user choose UPI app
  receiverUpiId: "a.amita2407@okhdfcbank", // 🛑 replace with a real UPI ID you own
  receiverName: "amita",
  transactionRefId: "TID${DateTime.now().millisecondsSinceEpoch}",
  transactionNote: "Test payment",
  amount: 1.0, // fixed amount for testing
);


      // Handle the response
      if (response.status == UpiPaymentStatus.SUCCESS) {
        Get.snackbar('Success', 'Payment successful!');
      } else if (response.status == UpiPaymentStatus.FAILURE) {
        Get.snackbar('Failed', 'Payment failed!');
      } else if (response.status == UpiPaymentStatus.SUBMITTED) {
        Get.snackbar('Pending', 'Payment submitted, check status in your UPI app.');
      } else {
        Get.snackbar('Cancelled', 'Payment cancelled.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Unable to initiate UPI payment');
    }
  }
*/
  Future<UpiApp?> selectUpiApp(BuildContext context, List<UpiApp> apps) async {
    return showDialog<UpiApp>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Select UPI App'),
        children: apps
            .map((app) => ListTile(
                  leading: Image.memory(app.icon, width: 40, height: 40),
                  title: Text(app.name),
                  onTap: () => Navigator.of(context).pop(app),
                ))
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('UPI: $upi'),
            ),
            SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            controller.isLiked.value
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: controller.isLiked.value
                                ? Colors.red
                                : Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: controller.toggleLike,
                        ),
                        Text('${controller.likes.value}'),
                      ],
                    )),
                ElevatedButton.icon(
                  icon: Icon(Icons.currency_rupee),
                  label: Text('Pay'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () => payWithUpi(context, upi, name),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
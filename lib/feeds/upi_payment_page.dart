import 'package:flutter/material.dart';
import 'package:upi_india/upi_india.dart';

class UpiPaymentPage extends StatefulWidget {
  @override
  _UpiPaymentPageState createState() => _UpiPaymentPageState();
}

class _UpiPaymentPageState extends State<UpiPaymentPage> {
  UpiIndia _upiIndia = UpiIndia();
  List<UpiApp> _apps = [];
  final amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUpiApps();
  }

  void _fetchUpiApps() async {
    _apps = await _upiIndia.getAllUpiApps(mandatoryTransactionId: false);
    setState(() {});
  }

  void _startTransaction(UpiApp app, double amount) async {
    UpiResponse response = await _upiIndia.startTransaction(
      app: app,
      receiverUpiId: 'a.amita2407@okhdfcbank', // ✅ Your UPI ID
      receiverName: 'Amita',
      transactionRefId: 'TXN${DateTime.now().millisecondsSinceEpoch}',
      transactionNote: 'Bheek Payment',
      amount: amount,
    );

    _handleUpiResponse(response);
  }

  void _handleUpiResponse(UpiResponse response) {
    String message;

    switch (response.status) {
      case UpiPaymentStatus.SUCCESS:
        message = '✅ Payment Successful\nTxn ID: ${response.transactionId}';
        break;
      case UpiPaymentStatus.FAILURE:
        message = '❌ Payment Failed';
        break;
      case UpiPaymentStatus.SUBMITTED:
        message = '📥 Payment Submitted';
        break;
      default:
        message = '⚠️ Payment Cancelled';
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('UPI Payment'),
        content: Text(message),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  void _showAmountDialog(UpiApp app) {
    amountController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Amount'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Amount in INR',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text('Pay'),
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context);
                _startTransaction(app, amount);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Enter valid amount')),
                );
              }
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Digital Bhikari UPI Payment')),
      body: _apps.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _apps.length,
              itemBuilder: (context, index) {
                UpiApp app = _apps[index];
                return ListTile(
                  leading: Image.memory(app.icon, height: 40, width: 40),
                  title: Text(app.name),
                  onTap: () => _showAmountDialog(app),
                );
              },
            ),
    );
  }
}

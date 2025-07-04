import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

class DowntimeScreen extends StatefulWidget {
  final String message;
  final InterstitialAd? ad;
  const DowntimeScreen({Key? key, required this.message, this.ad}) : super(key: key);

  @override
  State<DowntimeScreen> createState() => _DowntimeScreenState();
}

class _DowntimeScreenState extends State<DowntimeScreen> {
  @override
  void initState() {
    super.initState();
    // Show ad if available
    if (widget.ad != null) {
      widget.ad!.show();
    }
  }

  Future<bool> _onWillPop() async {
    // Exit the app
    exit(0);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.blue.shade900,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.yellow, size: 80),
                SizedBox(height: 24),
                Text(
                  "Downtime",
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  widget.message,
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                Text(
                  "Please try again later.",
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
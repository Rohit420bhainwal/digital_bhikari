import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  final Color primaryColor = const Color(0xFF1976D2);
  final Color accentColor = const Color(0xFFFFC107);

  List<Widget> get _pages => [
        // Screen 1: Funny Welcome
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🤖', style: TextStyle(fontSize: 90)),
            SizedBox(height: 24),
            Text(
              'Swagat hai Digital Bhikhari mein!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'Yahan bheek mangna hai bilkul cool!\nAapka digital bhikhari avatar ready hai! 😄',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
          ],
        ),
        // Screen 2: How it works
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('💡', style: TextStyle(fontSize: 80)),
            SizedBox(height: 18),
            Text(
              'Kaise Kaam Karta Hai?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '1. Bheek maango – apni wish likho\n2. Dosto ko share karo\n3. UPI se seedha bheek mil jaayegi!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
            SizedBox(height: 16),
            Text(
              'Sab kuch digital, sab kuch safe, aur full on fun!',
              style: TextStyle(fontSize: 16, color: accentColor, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        // Screen 3: Disclaimer
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('⚠️', style: TextStyle(fontSize: 70)),
            SizedBox(height: 18),
            Text(
              'Ek Chhota Disclaimer',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 16),
            Text(
  'Digital Bhikari ek mast idea hai! 😄\n'
  'Yahan sirf seedha UPI se bheek maangi jaati hai.\n'
  'Hum paisa nahi sambhalte, na beech mein aate hain.\n'
  'Bheek maangna aur dena – dono apni zimmedaari par!',
  textAlign: TextAlign.center,
  style: TextStyle(fontSize: 16, color: Colors.black87),
),
            SizedBox(height: 16),
            Text(
              'Masti karo, safe raho, aur digital bhikhari bano! 🎉',
              style: TextStyle(fontSize: 16, color: accentColor, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ];

  void _next() {
    if (_page < _pages.length - 1) {
      _controller.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      // Mark onboarding as seen
      GetStorage().write('onboarding_seen', true);
      Get.offAllNamed('/base');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor.withOpacity(0.1), accentColor.withOpacity(0.08), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, i) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: _pages[i],
                    ),
                  ),
                ),
              ),
              // Page indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (i) => AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 6, vertical: 18),
                    width: _page == i ? 22 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _page == i ? primaryColor : Colors.grey[400],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        onPressed: _next,
        label: Text(_page < _pages.length - 1 ? 'Next' : 'Shuru Karein'),
        icon: Icon(_page < _pages.length - 1 ? Icons.arrow_forward : Icons.check),
      ),
    );
  }
}
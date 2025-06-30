import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home/home_page.dart';
import '../feeds/feeds_page.dart';
import '../leaderboard/leaderboard_page.dart';
import '../transactions/transaction_page.dart';

class BaseController extends GetxController {
  var tabIndex = 0.obs;

  void changeTabIndex(int index) {
    tabIndex.value = index;
  }
}

class BaseScreen extends StatelessWidget {
  final List<Widget> pages = [
    HomePage(),
    FeedsPage(),
    LeaderboardPage(),
    TransactionPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final BaseController controller = Get.put(BaseController());
    return Obx(() => Scaffold(
      appBar: AppBar(
        title: Text('Digital Bhikari'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(child: Text('Drawer Header')),
            ListTile(
              title: Text('Profile'),
              onTap: () {},
            ),
            ListTile(
              title: Text('Settings'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: pages[controller.tabIndex.value],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: controller.tabIndex.value,
        onTap: controller.changeTabIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.feed), label: 'Feeds'),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'Leaderboard'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Transactions'),
        ],
      ),
    ));
  }
}
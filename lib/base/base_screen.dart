import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../feeds/feeds_page.dart';
import '../home/home_page.dart';
import '../leaderboard/leaderboard_page.dart';
import '../transactions/transaction_page.dart';
import '../auth/auth_controller.dart';
import '../profile/profile_page.dart';

import 'base_controller.dart';

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
    final AuthController authController = Get.find<AuthController>();

    return Obx(() => Scaffold(
      appBar: AppBar(
        title: Text('Digital Bhikari'),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Obx(() => UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              accountName: Text(
                authController.userName.value.isNotEmpty
                    ? authController.userName.value
                    : 'Guest',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                authController.userEmail.value.isNotEmpty
                    ? authController.userEmail.value
                    : '',
              ),
              currentAccountPicture: authController.profilePicture.value.isNotEmpty
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(authController.profilePicture.value),
                    )
                  : CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 40, color: Theme.of(context).colorScheme.primary),
                    ),
            )),
            /*ListTile(
              leading: Icon(Icons.home, color: Theme.of(context).colorScheme.primary),
              title: Text('Home'),
              onTap: () {
                controller.changeTabIndex(0);
                Navigator.pop(context);
              },
            ),*/
            ListTile(
              leading: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => ProfilePage());
              },
            ),
            /*ListTile(
              leading: Icon(Icons.settings, color: Theme.of(context).colorScheme.primary),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // Add settings navigation if needed
              },
            ),*/
            Spacer(),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                authController.signOut(); // <-- Use signOut from AuthController
              },
            ),
            SizedBox(height: 16),
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
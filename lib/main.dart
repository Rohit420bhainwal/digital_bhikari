import 'package:digital_bhikari/localization/app_translations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'notification/notification_detail_screen.dart';
import 'notification/notification_screen.dart';
import 'splash/splash_screen.dart';
import 'base/base_screen.dart';
import 'auth/google_signin_page.dart';
import 'auth/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();

  // Crashlytics Setup
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  // Register Controller
  Get.put(AuthController());

  await MobileAds.instance.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Color primaryColor = const Color(0xFF1976D2);
  final Color accentColor = const Color(0xFFFFC107);

  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],
      translations: AppTranslations(),
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      title: 'GetX Splash Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: accentColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
          ),
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
        ),
        textTheme: ThemeData.light().textTheme.apply(
          fontFamily: 'Roboto',
          bodyColor: Colors.black87,
          displayColor: Colors.black87,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => SplashScreen()),
        GetPage(name: '/login', page: () => GoogleSignInPage()),
        GetPage(name: '/base', page: () => BaseScreen()),
        GetPage(name: '/notifications', page: () => const NotificationScreen()),
        GetPage(name: '/notification_detail', page: () => const NotificationDetailScreen()),
      ],
    );
  }
}

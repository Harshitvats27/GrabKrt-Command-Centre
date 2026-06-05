import 'package:e_commerce_admin/screens/splash_screen.dart';
import 'package:e_commerce_admin/services/notification_service.dart';
import 'package:e_commerce_admin/utils/constant.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().initNotifications(); runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstant.appMainName,

      // 🔥 FIX YAHAN HAI: Ye 2 lines miss thi
      themeMode: ThemeMode.system, // Phone ke theme ko follow karega
      darkTheme: ThemeData.dark(useMaterial3: true), // Dark mode ki default theme

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      builder: EasyLoading.init(),
    );
  }
}
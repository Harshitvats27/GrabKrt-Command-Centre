// ignore_for_file: file_names, prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print

import 'dart:async';
import 'package:e_commerce_admin/screens/sign_in_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/notification_service.dart';
import '../utils/constant.dart';
import '../utils/helpers/helper_function.dart';
import 'main_screen.dart'; // 🔥 THEME CHECK KE LIYE IMPORT

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  User? user = FirebaseAuth.instance.currentUser;
  NotificationService notificationService = NotificationService();

  // 🔥 NEON ANIMATION CONTROLLERS
  late AnimationController _fadeController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    if (user != null) {
      print("Vendor id=> ${user!.uid}");
    } else {
      print("Vendor not logged in");
    }

    getToken();

    // 🔥 Setup Neon Pulsing Animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.1, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // 🔥 3 Second Timer logic
    Timer(const Duration(seconds: 3), () {
      if (user != null) {
        Get.offAll(() => const VendorDashboardScreen());
      } else {
        Get.offAll(() => const SignInScreen());
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  getToken() async {
    if (user != null) {
      String? userDeviceToken = await notificationService.getDeviceToken();
      print("token => $userDeviceToken");

      // 🔥 TOKEN DATABASE MEIN SAVE HO RAHA HAI
      if (userDeviceToken != null) {
        await FirebaseFirestore.instance.collection('Users').doc(user!.uid).update({
          'userDeviceToken': userDeviceToken,
        });
        print("🔥 Admin Token Updated from Splash Screen!");
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    // 🔥 DARK MODE CHECK
    final isDark = UHelperfunctions.isDarkTheme(context);

    return Scaffold(
      // Background color phone ki theme ke hisaab se change hoga
      backgroundColor: isDark ? const Color(0xFF101010) : Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 🔥 THE AESTHETIC ANIMATED GLOWING LOGO
                    ScaleTransition(
                      scale: CurvedAnimation(parent: _fadeController, curve: Curves.elasticOut),
                      child: Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // Circle ka andar ka color bhi theme ke hisaab se badlega
                          color: isDark ? Colors.black : Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: AppConstant.neonGlowColor.withOpacity(0.8),
                              blurRadius: 25,
                              spreadRadius: 3,
                            ),
                            BoxShadow(
                              color: AppConstant.neonGlowColor.withOpacity(0.4),
                              blurRadius: 45,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _glowAnimation.value,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(Icons.settings, color: AppConstant.neonGlowColor, size: 70),
                                  Icon(Icons.storefront, color: AppConstant.neonGlowColor, size: 40),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 35),

                    // 🔥 TEXT GLOW-UP WITH NEW NAME
                    Text(
                      "VALUEKART\nCOMMAND CENTRE", // Name update kar diya with 2 lines for better alignment
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        // Text color phone ki theme ke hisaab se change hoga
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        height: 1.3, // Line spacing
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: AppConstant.neonGlowColor,
                            offset: const Offset(0, 0),
                          ),
                          if (isDark) // Light mode mein double shadow thodi odd lag sakti hai
                            Shadow(
                              blurRadius: 20.0,
                              color: AppConstant.neonGlowColor.withOpacity(0.5),
                              offset: const Offset(0, 0),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 🔥 Bottom Text Aesthetic
            Container(
              margin: const EdgeInsets.only(bottom: 30.0),
              width: Get.width,
              alignment: Alignment.center,
              child: Opacity(
                opacity: 0.6,
                child: Text(
                  AppConstant.appPoweredBy.toUpperCase(),
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54, // Bottom text theme adjust
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
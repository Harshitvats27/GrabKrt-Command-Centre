// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, unused_local_variable, unnecessary_null_comparison, file_names

import 'package:e_commerce_admin/screens/sign_up_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/notification_service.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';

import '../controllers/sign_in_controller.dart';
import '../utils/constant.dart';
import '../utils/helpers/helper_function.dart';
import 'main_screen.dart'; // Apna dashboard path yahan check kar lena agar alag ho

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final SignInController signInController = Get.put(SignInController());
  TextEditingController userEmail = TextEditingController();
  TextEditingController userPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDark = UHelperfunctions.isDarkTheme(context);

    return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF101010) : Colors.grey[50], // Deep background
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "ACCESS TERMINAL", // Cyberpunk naming
            style: TextStyle(
              color: isDark ? Colors.cyanAccent : AppConstant.appMainColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
          iconTheme: IconThemeData(color: isDark ? Colors.cyanAccent : Colors.black),
        ),
        body: Center(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // 🔥 GLOWING ICON
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                    boxShadow: isDark ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.4), blurRadius: 20, spreadRadius: 2)] : [],
                    border: Border.all(color: isDark ? Colors.cyanAccent : Colors.blue, width: 2),
                  ),
                  child: Icon(Icons.admin_panel_settings, size: 60, color: isDark ? Colors.cyanAccent : Colors.blue),
                ),
                SizedBox(height: 40),

                // 🔥 EMAIL FIELD
                _buildNeonTextField(
                  controller: userEmail,
                  hint: "Admin Email",
                  icon: Icons.email,
                  isDark: isDark,
                ),
                SizedBox(height: 20),

                // 🔥 PASSWORD FIELD
                Obx(() => _buildNeonTextField(
                  controller: userPassword,
                  hint: "Secure Password",
                  icon: Icons.password,
                  isDark: isDark,
                  isPassword: true,
                  obscureText: signInController.isPasswordVisible.value,
                  onTogglePassword: () => signInController.isPasswordVisible.toggle(),
                )),

                // 🔥 FORGOT PASSWORD
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {},
                    child: Text(
                      "Forget Password?",
                      style: TextStyle(
                        color: isDark ? Colors.cyanAccent : Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),

                // 🔥 GLOWING SIGN IN BUTTON
                GestureDetector(
                  onTap: () async {
                    String email = userEmail.text.trim();
                    String password = userPassword.text.trim();

                    if (email.isEmpty || password.isEmpty) {
                      showSnackbar(title: "Error", message: "Terminal requires all details.");
                      return;
                    }

                    try {
                      UserCredential? userCredential = await signInController.signInMethod(email, password);

                      if (userCredential != null) {

                        // 🔥 NAYA CODE YAHAN ADD HUA HAI (Token Save Karne Ke Liye)
                        String? token = await NotificationService().getDeviceToken();
                        if (token != null) {
                          await FirebaseFirestore.instance
                              .collection('Users')
                              .doc(userCredential.user!.uid)
                              .update({
                            'userDeviceToken': token,
                          });
                          print("🔥 Token Saved After Login: $token");
                        }
                        // 🔥 --------------------------------------------------

                        Get.offAll(() => const VendorDashboardScreen());
                        showSnackbar(title: "Access Granted", message: "Welcome to Command Center.");
                      } else {
                        showSnackbar(title: "Access Denied", message: "Authentication failed.");
                      }
                    } catch (e) {
                      showSnackbar(title: "System Error", message: e.toString());
                    }
                  },
                  child: Container(
                    width: Get.width * 0.6,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.transparent : Colors.blue,
                      borderRadius: BorderRadius.circular(30.0),
                      border: Border.all(color: isDark ? Colors.cyanAccent : Colors.blue, width: 2),
                      boxShadow: isDark ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.4), blurRadius: 15)] : [],
                    ),
                    child: Center(
                      child: Text(
                        "INITIALIZE",
                        style: TextStyle(color: isDark ? Colors.cyanAccent : Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40),

                // 🔥 SIGN UP LINK
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("New Admin? ", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
                    GestureDetector(
                      onTap: () => Get.offAll(() => SignUpScreen()),
                      child: Text(
                        "Register Here",
                        style: TextStyle(color: isDark ? Colors.pinkAccent : Colors.pink, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    });
  }

  // Helper widget for neon text fields
  Widget _buildNeonTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onTogglePassword,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: isDark ? Colors.cyanAccent.withOpacity(0.5) : Colors.grey.shade300),
        boxShadow: isDark ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.1), blurRadius: 10)] : [],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        cursorColor: Colors.cyanAccent,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
          prefixIcon: Icon(icon, color: isDark ? Colors.cyanAccent : Colors.blue),
          suffixIcon: isPassword
              ? GestureDetector(
            onTap: onTogglePassword,
            child: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: isDark ? Colors.cyanAccent : Colors.blue),
          )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15.0),
        ),
      ),
    );
  }

  void showSnackbar({required String title, required String message}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.cyanAccent, // Neon style snackbar
      colorText: Colors.black,
      margin: EdgeInsets.all(15),
    );
  }
}
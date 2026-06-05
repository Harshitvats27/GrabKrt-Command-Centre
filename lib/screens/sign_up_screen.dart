// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, file_names, unused_local_variable, avoid_print

import 'package:e_commerce_admin/screens/sign_in_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';

import '../controllers/sign_up_controller.dart';
import '../services/notification_service.dart';
import '../utils/constant.dart';
import '../utils/helpers/helper_function.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final SignUpController signUpController = Get.put(SignUpController());
  TextEditingController username = TextEditingController();
  TextEditingController userEmail = TextEditingController();
  TextEditingController userPhone = TextEditingController();
  TextEditingController userCity = TextEditingController();
  TextEditingController userPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDark = UHelperfunctions.isDarkTheme(context);

    return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF101010) : Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "REGISTER VENDOR",
            style: TextStyle(
              color: isDark ? Colors.pinkAccent : AppConstant.appMainColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
          iconTheme: IconThemeData(color: isDark ? Colors.pinkAccent : Colors.black),
        ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 20),

              // 🔥 GLOWING HEADER
              Container(
                alignment: Alignment.center,
                child: Text(
                  "Create Command Center Profile",
                  style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                      letterSpacing: 1.0
                  ),
                ),
              ),
              SizedBox(height: 30),

              // 🔥 NEON TEXT FIELDS
              _buildNeonTextField(controller: userEmail, hint: "Admin Email", icon: Icons.email, isDark: isDark, neonColor: Colors.pinkAccent),
              SizedBox(height: 15),
              _buildNeonTextField(controller: username, hint: "Vendor Name", icon: Icons.person, isDark: isDark, neonColor: Colors.pinkAccent),
              SizedBox(height: 15),
              _buildNeonTextField(controller: userPhone, hint: "Contact Node (Phone)", icon: Icons.phone, isDark: isDark, neonColor: Colors.pinkAccent),
              SizedBox(height: 15),
              _buildNeonTextField(controller: userCity, hint: "Base City", icon: Icons.location_pin, isDark: isDark, neonColor: Colors.pinkAccent),
              SizedBox(height: 15),

              Obx(() => _buildNeonTextField(
                controller: userPassword,
                hint: "Secure Passcode",
                icon: Icons.password,
                isDark: isDark,
                neonColor: Colors.pinkAccent,
                isPassword: true,
                obscureText: signUpController.isPasswordVisible.value,
                onTogglePassword: () => signUpController.isPasswordVisible.toggle(),
              )),

              SizedBox(height: 40),

              // 🔥 GLOWING SIGN UP BUTTON
              GestureDetector(
                onTap: () async {
                  NotificationService notificationService = NotificationService();
                  String name = username.text.trim();
                  String email = userEmail.text.trim();
                  String phone = userPhone.text.trim();
                  String city = userCity.text.trim();
                  String password = userPassword.text.trim();

                  // 🔥 FIX YAHAN HAI: Agar token null aaya, toh khali string assign ho jayegi
                  String userDeviceToken = await notificationService.getDeviceToken() ?? "";

                  if (name.isEmpty || email.isEmpty || phone.isEmpty || city.isEmpty || password.isEmpty) {
                    Get.snackbar("Error", "All fields are required to establish profile.", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.pinkAccent, colorText: Colors.white);
                  } else {
                    UserCredential? userCredential = await signUpController.signUpMethod(name, email, phone, city, password, userDeviceToken);

                    if (userCredential != null) {
                      Get.snackbar("Profile Created", "Check email to verify your identity.", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.cyanAccent, colorText: Colors.black);
                      FirebaseAuth.instance.signOut();
                      Get.offAll(() => SignInScreen());
                    }
                  }
                },
                child: Container(
                  width: Get.width * 0.6,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.transparent : Colors.pink,
                    borderRadius: BorderRadius.circular(30.0),
                    border: Border.all(color: isDark ? Colors.pinkAccent : Colors.pink, width: 2),
                    boxShadow: isDark ? [BoxShadow(color: Colors.pinkAccent.withOpacity(0.4), blurRadius: 15)] : [],
                  ),
                  child: Center(
                    child: Text(
                      "CREATE PROFILE",
                      style: TextStyle(color: isDark ? Colors.pinkAccent : Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2.0),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30),

              // 🔥 BACK TO LOGIN
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Existing Admin? ", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
                  GestureDetector(
                    onTap: () => Get.offAll(() => SignInScreen()),
                    child: Text(
                      "Access Terminal",
                      style: TextStyle(color: isDark ? Colors.cyanAccent : Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    });
  }

  // Helper widget for neon text fields (Pink Neon for Sign Up)
  Widget _buildNeonTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    required Color neonColor,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onTogglePassword,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: isDark ? neonColor.withOpacity(0.5) : Colors.grey.shade300),
        boxShadow: isDark ? [BoxShadow(color: neonColor.withOpacity(0.1), blurRadius: 10)] : [],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        cursorColor: neonColor,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
          prefixIcon: Icon(icon, color: isDark ? neonColor : Colors.blue),
          suffixIcon: isPassword
              ? GestureDetector(
            onTap: onTogglePassword,
            child: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: isDark ? neonColor : Colors.blue),
          )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15.0),
        ),
      ),
    );
  }
}
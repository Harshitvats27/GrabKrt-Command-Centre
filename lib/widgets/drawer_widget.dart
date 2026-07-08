// ignore_for_file: prefer_const_constructors, unused_local_variable, avoid_print, unnecessary_null_comparison
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/all_brands screen.dart';
import '../screens/all_order_screen.dart';
import '../screens/brand_category_list_screen.dart';

import '../screens/all_categories_screen.dart';
import '../screens/all_user_screen.dart';
import '../screens/main_screen.dart';
import '../screens/my_stores_list_screen.dart';
import '../screens/promo_code_list.dart';
import '../screens/sign_in_screen.dart';
import '../screens/vendor_product_screen.dart';
import '../utils/constant.dart';
import '../utils/helpers/helper_function.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  User? user = FirebaseAuth.instance.currentUser;
  String userName = 'Vendor';
  String firstLetter = 'V';

  @override
  Widget build(BuildContext context) {
    final isDark = UHelperfunctions.isDarkTheme(context);

    return Drawer(
      backgroundColor: isDark
          ? const Color(0xFF161616)
          : const Color(0xFF222222), // Dark Neon background
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30.0),
          bottomRight: Radius.circular(30.0),
        ),
      ),
      child: Column(
        children: [
          // 🔥 GLOWING HEADER
          Container(
            padding: EdgeInsets.only(
              top: Get.height * 0.08,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.cyanAccent.withOpacity(0.5),
                  width: 1,
                ),
              ),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1A1A1A),
                  Colors.cyanAccent.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyanAccent.withOpacity(0.5),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 28.0,
                    backgroundColor: Colors.black,
                    child: Text(
                      firstLetter,
                      style: const TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user != null ? userName : "Guest User",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Command Center",
                        style: TextStyle(
                          color: Colors.cyanAccent.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 🔥 NEON MENU LIST
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              children: [
                _buildDrawerItem(
                  Icons.dashboard_outlined,
                  'Dashboard',
                  Colors.cyanAccent,
                  () => Get.offAll(() => const VendorDashboardScreen()),
                ),
                // _buildDrawerItem(Icons.people_outline, 'Customers', Colors.pinkAccent, () => Get.to(() => const AllUsersScreen())),
                _buildDrawerItem(
                  Icons.storefront_outlined,
                  'My Stores',
                  Colors.blueAccent,
                  () => Get.to(() => const MyStoresListScreen()),
                ),
                _buildDrawerItem(
                  Icons.branding_watermark_outlined,
                  'Brands',
                  Colors.amberAccent,
                  () => Get.to(() => const AllBrandsScreen()),
                ),
                _buildDrawerItem(
                  Icons.category_outlined,
                  'Categories',
                  Colors.purpleAccent,
                  () => Get.to(() => const AllCategoriesScreen()),
                ),
                _buildDrawerItem(
                  Icons.category,
                  'Brand Categories',
                  Colors.blueAccent,
                  () => Get.to(() => BrandCategoryListScreen()),
                ),
                _buildDrawerItem(
                  Icons.inventory_2_outlined,
                  'My Products',
                  Colors.greenAccent,
                  () => Get.to(() => VendorProductsScreen()),
                ),

                _buildDrawerItem(
                  Icons.shopping_bag_outlined,
                  'All Orders',
                  Colors.orangeAccent,
                  () => Get.to(() => const AllOrdersScreen()),
                ),
                _buildDrawerItem(
                  Icons.local_offer_outlined,
                  'Promo Codes',
                  Colors.redAccent,
                  () => Get.to(() => PromoCodeListScreen()),
                ),
                // _buildDrawerItem(Icons.storefront_outlined, 'My Stores', Colors.blueAccent, () => Get.to(() => const MyStoresListScreen())),
              ],
            ),
          ),

          // 🔥 LOGOUT BUTTON AT BOTTOM WITH LOGIC
          Container(
            padding: const EdgeInsets.all(20),
            child: _buildDrawerItem(
              user != null ? Icons.logout : Icons.login,
              user != null ? 'Logout' : 'Login',
              Colors.red,
              () async {
                // 🔥 LOGOUT LOGIC ADDED
                if (user != null) {
                  await FirebaseAuth.instance.signOut();
                  Get.offAll(() => const SignInScreen());
                  Get.snackbar(
                    "Logged Out",
                    "You have successfully logged out.",
                    backgroundColor: Colors.cyanAccent,
                    colorText: Colors.black,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                } else {
                  Get.offAll(() => const SignInScreen());
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 CUSTOM ANIMATED DRAWER TILE
  Widget _buildDrawerItem(
    IconData icon,
    String title,
    Color neonColor,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        hoverColor: neonColor.withOpacity(0.1),
        leading: Icon(icon, color: neonColor, size: 24),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.white24,
          size: 14,
        ),
        onTap: () {
          Get.back(); // Phele drawer close hoga
          onTap(); // Phir screen change hogi
        },
      ),
    );
  }
}

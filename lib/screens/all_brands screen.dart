import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/add_brand_controller.dart';
import '../utils/helpers/helper_function.dart';
import '../utils/snackbar_helpers.dart';
import 'add_brand_screen.dart';
import 'edit_brand_screen.dart';

class AllBrandsScreen extends StatefulWidget {
  const AllBrandsScreen({super.key});

  @override
  State<AllBrandsScreen> createState() => _AllBrandsScreenState();
}

class _AllBrandsScreenState extends State<AllBrandsScreen> {
  final controller = Get.put(BrandController());

  @override
  void initState() {
    super.initState();
    controller.fetchBrands();
  }

  // 🔥 DIRECT FIREBASE DELETE LOGIC
  Future<void> deleteBrand(String brandId) async {
    Get.defaultDialog(
      title: "Delete Brand",
      middleText: "Are you sure you want to permanently delete this brand?",
      textCancel: "Cancel",
      textConfirm: "Delete",
      buttonColor: Colors.redAccent,
      confirmTextColor: Colors.white,
      cancelTextColor: Colors.cyanAccent,
      backgroundColor: const Color(0xFF1E1E1E),
      titleStyle: const TextStyle(color: Colors.white),
      middleTextStyle: const TextStyle(color: Colors.white70),
      onConfirm: () async {
        Get.back(); // Close Dialog
        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
        try {
          await FirebaseFirestore.instance.collection('Brands').doc(brandId).delete();
          controller.fetchBrands(); // Refresh List
          if (Get.isDialogOpen == true) Get.back(); // Close Loading
          USnackBarHelpers.successSnackBar(title: "Deleted", message: "Brand removed successfully.");
        } catch (e) {
          if (Get.isDialogOpen == true) Get.back();
          USnackBarHelpers.errorSnackBar(title: "Error", message: e.toString());
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = UHelperfunctions.isDarkTheme(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
        title: Text("All Brands", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.cyanAccent : Colors.black),
        actions: [
          // 🔥 NEON GLOW PLUS ICON
          Container(
            margin: const EdgeInsets.only(right: 15, top: 8, bottom: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: isDark ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.6), blurRadius: 12, spreadRadius: 2)] : [],
            ),
            child: IconButton(
              icon: Icon(Icons.add_circle, color: isDark ? Colors.cyanAccent : Colors.blueAccent, size: 30),
              onPressed: () => Get.to(() => AddBrandScreen()),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          if (controller.brandList.isEmpty) {
            return Center(child: Text("No Brands Found", style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)));
          }

          return ListView.builder(
            itemCount: controller.brandList.length,
            itemBuilder: (context, index) {
              final brand = controller.brandList[index];

              return Dismissible(
                key: Key(brand.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  deleteBrand(brand.id);
                  return false; // Dialog will handle the actual deletion
                },
                background: _buildSwipeBackground(),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: _cardDecoration(isDark),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    onTap: () async {
                      var result = await Get.to(() => EditBrandScreen(brand: brand));
                      if (result != null) {
                        controller.fetchBrands();
                        USnackBarHelpers.successSnackBar(title: "Success", message: result.toString());
                      }
                    },
                    leading: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: isDark ? Colors.cyanAccent : Colors.blue, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.transparent,
                        backgroundImage: NetworkImage(brand.image),
                      ),
                    ),
                    title: Text(brand.name, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                    subtitle: Text("Products: ${brand.productsCount ?? 0}", style: TextStyle(color: isDark ? Colors.cyanAccent : Colors.green, fontWeight: FontWeight.w600)),
                    trailing: Icon(Icons.edit, color: isDark ? Colors.cyanAccent : Colors.blue),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  // 🔥 SWIPE RED BACKGROUND WIDGET
  Widget _buildSwipeBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(20)),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Icon(Icons.delete_sweep, color: Colors.white, size: 35),
    );
  }

  // 🔥 EXTREME NEON DECORATION
  BoxDecoration _cardDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: isDark ? Colors.cyanAccent.withOpacity(0.8) : Colors.grey.shade300, width: isDark ? 1.5 : 1.0),
      boxShadow: isDark
          ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.6), blurRadius: 20, spreadRadius: 2)]
          : [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
    );
  }
}
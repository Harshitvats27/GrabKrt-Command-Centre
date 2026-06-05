// ignore_for_file: avoid_unnecessary_containers

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../controllers/edit_category_controller.dart';
import '../models/categories_model.dart';
import '../utils/constant.dart';
import '../utils/helpers/helper_function.dart'; // 🔥 HELPER IMPORT FOR DARK THEME
import 'add_category_screen.dart';
import 'edit_category_screeen.dart';

class AllCategoriesScreen extends StatelessWidget {
  const AllCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = UHelperfunctions.isDarkTheme(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("All Categories", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: isDark ? Colors.cyanAccent : Colors.black),
        actions: [
          // 🔥 NEON GLOW PLUS ICON
          Container(
            margin: const EdgeInsets.only(right: 15, top: 8, bottom: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: isDark
                  ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.6), blurRadius: 12, spreadRadius: 2)]
                  : [],
            ),
            child: IconButton(
              icon: Icon(Icons.add_circle, color: isDark ? Colors.cyanAccent : Colors.blueAccent, size: 30),
              onPressed: () => Get.to(() => const AddCategoryScreen()),
            ),
          )
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Categories').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error occurred while fetching category!', style: TextStyle(color: Colors.red)));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No category found!', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)));
          }

          if (snapshot.data != null) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final data = snapshot.data!.docs[index];

                CategoryModel categoriesModel = CategoryModel(
                  id: data['id'],
                  name: data['name'],
                  image: data['image'],
                );

                // 🔥 NATIVE SWIPE TO DELETE LOGIC
                return Dismissible(
                  key: Key(categoriesModel.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    Get.defaultDialog(
                      title: "Delete Category",
                      middleText: "Are you sure you want to delete this category?",
                      textCancel: "Cancel",
                      textConfirm: "Delete",
                      buttonColor: Colors.redAccent,
                      confirmTextColor: Colors.white,
                      cancelTextColor: isDark ? Colors.cyanAccent : Colors.black,
                      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      titleStyle: TextStyle(color: isDark ? Colors.white : Colors.black),
                      middleTextStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                      onConfirm: () async {
                        Get.back(); // Dialog band karo
                        EasyLoading.show(status: 'Deleting..');
                        EditCategoryController editCategoryController = Get.put(EditCategoryController(categoriesModel: categoriesModel));
                        await editCategoryController.deleteOldImage(categoriesModel.image);
                        await editCategoryController.deleteCategory(categoriesModel.id);
                        EasyLoading.dismiss();
                      },
                    );
                    return false; // UI element StreamBuilder khud remove karega
                  },
                  background: _buildSwipeBackground(),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: _cardDecoration(isDark),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      // 🔥 Ab tap karne par Edit Screen khulegi (Products and Promos ki tarah)
                      onTap: () => Get.to(() => EditCategoryScreen(categoriesModel: categoriesModel)),
                      leading: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: isDark ? Colors.cyanAccent : Colors.blue, width: 2),
                        ),
                        child: CircleAvatar(
                          backgroundColor: AppConstant.appScendoryColor,
                          backgroundImage: CachedNetworkImageProvider(
                            categoriesModel.image.toString(),
                            errorListener: (err) => const Icon(Icons.error),
                          ),
                        ),
                      ),
                      title: Text(categoriesModel.name, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                      subtitle: Text("ID: ${categoriesModel.id}", style: TextStyle(color: isDark ? Colors.white54 : Colors.grey)),
                      trailing: Icon(Icons.edit, color: isDark ? Colors.cyanAccent : Colors.blue),
                    ),
                  ),
                );
              },
            );
          }
          return Container();
        },
      ),
    );
  }

  // 🔥 SWIPE RED BACKGROUND WIDGET
  Widget _buildSwipeBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(20),
      ),
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
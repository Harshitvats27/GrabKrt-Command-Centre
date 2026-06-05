import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../controllers/edit_category_controller.dart';
import '../models/categories_model.dart';
import '../utils/helpers/helper_function.dart';

class EditCategoryScreen extends StatefulWidget {
  final CategoryModel categoriesModel;
  const EditCategoryScreen({super.key, required this.categoriesModel});

  @override
  State<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.categoriesModel.name);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = UHelperfunctions.isDarkTheme(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
        title: Text("Edit Category", style: TextStyle(color: isDark ? Colors.cyanAccent : Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.cyanAccent : Colors.black),
      ),
      body: GetBuilder<EditCategoryController>(
        init: EditCategoryController(categoriesModel: widget.categoriesModel),
        builder: (ctrl) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /// 🔥 IMAGE PREVIEW
                Center(
                  child: Container(
                    height: 150, width: double.infinity,
                    decoration: _cardDecoration(isDark),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: ctrl.newImage.value != null
                          ? Image.file(File(ctrl.newImage.value!.path), fit: BoxFit.cover)
                          : CachedNetworkImage(
                        imageUrl: ctrl.categoryImg.value,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, error, stackTrace) => const Icon(Icons.image, size: 50),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.cyanAccent.withOpacity(0.2) : Colors.blue.withOpacity(0.1),
                    foregroundColor: isDark ? Colors.cyanAccent : Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isDark ? Colors.cyanAccent : Colors.blue)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: ctrl.pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text("Change Image", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 30),

                /// NAME
                _buildProInput(nameController, "Category Name", Icons.category, isDark),
                const SizedBox(height: 15),

                /// FEATURED
                Container(
                  decoration: _cardDecoration(isDark),
                  child: SwitchListTile(
                    activeColor: isDark ? Colors.cyanAccent : Colors.blue,
                    title: Text("Is Featured", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                    value: ctrl.isFeatured.value,
                    onChanged: (val) {
                      ctrl.isFeatured.value = val;
                      ctrl.update();
                    },
                  ),
                ),
                const SizedBox(height: 40),

                /// UPDATE BUTTON
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      if (isDark) BoxShadow(color: Colors.cyanAccent.withOpacity(0.6), blurRadius: 20, spreadRadius: 2),
                      if (!isDark) BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: isDark ? Colors.cyanAccent : Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                    onPressed: () async {
                      EasyLoading.show();
                      String imageUrl = ctrl.categoryImg.value;

                      if (ctrl.newImage.value != null) {
                        await ctrl.deleteOldImage(imageUrl);
                        imageUrl = await ctrl.uploadNewImage();
                      }

                      await FirebaseFirestore.instance.collection('Categories').doc(widget.categoriesModel.id).update({
                        "name": nameController.text.trim(),
                        "image": imageUrl,
                        "isFeatured": ctrl.isFeatured.value,
                      });

                      EasyLoading.dismiss();
                      Get.back(); // Update hone pe wapas list me jao
                      Get.snackbar("Success", "Category Updated", backgroundColor: Colors.green, colorText: Colors.white);
                    },
                    child: Text("Update Category", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.black : Colors.white)),
                  ),
                ),
                const SizedBox(height: 20),

                /// DELETE BUTTON (NEON RED)
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [BoxShadow(color: Colors.redAccent.withOpacity(0.5), blurRadius: 20, spreadRadius: 2)],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                    onPressed: () async {
                      EasyLoading.show();
                      await ctrl.deleteOldImage(ctrl.categoryImg.value);
                      await ctrl.deleteCategory(widget.categoriesModel.id);
                      EasyLoading.dismiss();
                      Get.back();
                      Get.snackbar("Deleted", "Category removed", backgroundColor: Colors.red, colorText: Colors.white);
                    },
                    child: const Text("Delete Category", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

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

  Widget _buildProInput(TextEditingController controller, String hint, IconData icon, bool isDark) {
    return Container(
      decoration: _cardDecoration(isDark),
      child: TextField(
        controller: controller,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: isDark ? Colors.cyanAccent : Colors.grey),
          labelText: hint,
          labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.grey[600]),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: isDark ? Colors.cyanAccent : Colors.blue, width: 2)),
          filled: true, fillColor: Colors.transparent,
        ),
      ),
    );
  }
}
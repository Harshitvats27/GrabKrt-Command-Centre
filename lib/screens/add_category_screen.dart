import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../controllers/category_controller.dart';
import '../models/categories_model.dart';
import '../utils/helpers/helper_function.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final nameController = TextEditingController();
  final parentIdController = TextEditingController();

  bool isFeatured = false;
  bool isSubCategory = false;
  String? selectedParentId;

  final controller = Get.put(CategoryController());

  @override
  void initState() {
    super.initState();
    controller.fetchParentCategories();
  }

  // 🔥 CUSTOM NEON SNACKBAR
  void showNeonSnackbar(String title, String message, bool isSuccess) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isSuccess ? Colors.greenAccent : Colors.redAccent,
      colorText: Colors.black,
      margin: const EdgeInsets.all(15),
      icon: Icon(isSuccess ? Icons.check_circle : Icons.error, color: Colors.black),
      duration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = UHelperfunctions.isDarkTheme(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
        title: Text("Add Category", style: TextStyle(color: isDark ? Colors.cyanAccent : Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.cyanAccent : Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GetBuilder<CategoryController>(
          builder: (ctrl) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  /// IMAGE PREVIEW NEON
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          height: 150, width: double.infinity,
                          decoration: _cardDecoration(isDark),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: ctrl.selectedImage.value == null
                                ? Center(child: Text("No Image Selected", style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)))
                                : Image.file(File(ctrl.selectedImage.value!.path), fit: BoxFit.cover),
                          ),
                        ),
                        if (ctrl.selectedImage.value != null)
                          Positioned(
                            right: 5, top: 5,
                            child: IconButton(
                              icon: const CircleAvatar(backgroundColor: Colors.redAccent, child: Icon(Icons.close, color: Colors.white, size: 20)),
                              onPressed: ctrl.removeImage,
                            ),
                          )
                      ],
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
                    label: const Text("Select Image", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 30),

                  /// CATEGORY NAME
                  _buildProInput(nameController, "Category Name", Icons.category, isDark),
                  const SizedBox(height: 15),

                  /// SWITCHES
                  Container(
                    decoration: _cardDecoration(isDark),
                    child: Column(
                      children: [
                        SwitchListTile(
                          activeColor: isDark ? Colors.cyanAccent : Colors.blue,
                          title: Text("Is Featured", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                          value: isFeatured,
                          onChanged: (val) => setState(() => isFeatured = val),
                        ),
                        Divider(color: isDark ? Colors.white24 : Colors.grey.shade300, height: 1),
                        SwitchListTile(
                          activeColor: isDark ? Colors.cyanAccent : Colors.blue,
                          title: Text("Is Subcategory (Dropdown)", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                          value: isSubCategory,
                          onChanged: (val) {
                            setState(() {
                              isSubCategory = val;
                              selectedParentId = null;
                              parentIdController.clear();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (isSubCategory)
                    _buildProDropdown<String>(
                      hint: "Select Parent Category",
                      value: selectedParentId,
                      items: ctrl.parentCategories.map((cat) => DropdownMenuItem(value: cat.id, child: Text(cat.name))).toList(),
                      onChanged: (value) => setState(() => selectedParentId = value),
                      isDark: isDark,
                    ),

                  if (!isSubCategory)
                    _buildProInput(parentIdController, "Enter Parent ID (Optional)", Icons.link, isDark),

                  const SizedBox(height: 40),

                  /// SAVE BUTTON WITH SNACKBARS
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
                        if (nameController.text.isEmpty || ctrl.selectedImage.value == null) {
                          showNeonSnackbar("System Error", "All fields are required to proceed.", false);
                          return;
                        }

                        String? finalParentId;
                        if (isSubCategory) {
                          if (selectedParentId == null) {
                            showNeonSnackbar("Error", "Please select a parent category.", false);
                            return;
                          }
                          finalParentId = selectedParentId;
                        } else {
                          finalParentId = parentIdController.text.isNotEmpty ? parentIdController.text.trim() : null;
                        }

                        EasyLoading.show();
                        try {
                          await ctrl.uploadImage();

                          DocumentReference docRef = FirebaseFirestore.instance.collection('Categories').doc();
                          CategoryModel model = CategoryModel(
                            id: docRef.id,
                            name: nameController.text.trim(),
                            image: ctrl.imageUrl.value,
                            parentId: finalParentId,
                            isFeatured: isFeatured,
                          );

                          await docRef.set(model.toJson());
                          EasyLoading.dismiss();

                          showNeonSnackbar("Upload Complete", "Category has been added successfully! 🚀", true);

                          nameController.clear();
                          parentIdController.clear();
                          ctrl.removeImage();
                          selectedParentId = null;
                          isSubCategory = false;
                          isFeatured = false;
                          setState(() {});
                        } catch (e) {
                          EasyLoading.dismiss();
                          showNeonSnackbar("Upload Failed", e.toString(), false);
                        }
                      },
                      child: Text("Save Category", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.black : Colors.white)),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- REUSABLE COMPONENTS ---
  BoxDecoration _cardDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: isDark ? Colors.cyanAccent.withOpacity(0.8) : Colors.grey.shade300, width: isDark ? 1.5 : 1.0),
      boxShadow: isDark ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.6), blurRadius: 20, spreadRadius: 2)] : [],
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
        ),
      ),
    );
  }

  Widget _buildProDropdown<T>({required T? value, required String hint, required List<DropdownMenuItem<T>> items, required void Function(T?)? onChanged, required bool isDark}) {
    return Container(
      decoration: _cardDecoration(isDark),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonFormField<T>(
        decoration: const InputDecoration(border: InputBorder.none),
        dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16),
        value: value,
        hint: Text(hint, style: TextStyle(color: isDark ? Colors.white54 : Colors.grey[600])),
        items: items,
        onChanged: onChanged,
        iconEnabledColor: isDark ? Colors.cyanAccent : Colors.grey,
      ),
    );
  }
}
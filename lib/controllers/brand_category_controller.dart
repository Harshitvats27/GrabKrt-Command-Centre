import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/brand_model.dart';
import '../models/categories_model.dart';
import '../models/brand_category_model.dart';
import '../utils/snackbar_helpers.dart';

class BrandCategoryController extends GetxController {
  static BrandCategoryController get instance => Get.find();

  List<BrandModel> brandList = [];
  List<CategoryModel> categoryList = []; // 🔥 SIRF PARENT CATEGORIES

  // --- ADD SCREEN VARIABLES ---
  BrandModel? selectedBrand;
  List<CategoryModel> selectedCategories = []; // Multi-select list

  // --- EDIT SCREEN VARIABLES ---
  String editDocId = '';
  BrandModel? editSelectedBrand;
  CategoryModel? editSelectedCategory;

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    try {
      final bSnap = await FirebaseFirestore.instance.collection('Brands').get();
      brandList = bSnap.docs.map((e) => BrandModel.fromJson(e.data())).toList();

      final cSnap = await FirebaseFirestore.instance.collection('Categories').get();
      final allCategories = cSnap.docs.map((e) => CategoryModel.fromSnapshot(e)).toList();
      categoryList = allCategories.where((cat) => cat.parentId == null || cat.parentId!.isEmpty).toList();

      update();
    } catch (e) {
      print("Fetch Error: $e");
    }
  }
  /// ================= 1. ADD LOGIC =================
  void toggleCategorySelection(CategoryModel category) {
    if (selectedCategories.contains(category)) {
      selectedCategories.remove(category);
    } else {
      selectedCategories.add(category);
    }
    update();
  }

  Future<void> saveBrandCategoryMapping() async {
    if (selectedBrand == null || selectedCategories.isEmpty) {
      USnackBarHelpers.warningSnackBar(title: "Error", message: "Please select Brand and at least one Category!");
      return;
    }

    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

    try {
      for (var category in selectedCategories) {
        final mapping = BrandCategoryModel(brandId: selectedBrand!.id, categoryId: category.id);
        await FirebaseFirestore.instance.collection('BrandCategory').add(mapping.toJson());
      }

      if (Get.isDialogOpen == true) Get.back();
      USnackBarHelpers.successSnackBar(title: "Success", message: "Linked Successfully! 🔥");

      selectedBrand = null;
      selectedCategories.clear();
      update();
      Get.back();
    } catch (e) {
      if (Get.isDialogOpen == true) Get.back();
      USnackBarHelpers.errorSnackBar(title: "Error", message: e.toString());
    }
  }
  /// ================= 2. LOAD EDIT DATA =================
  // Yeh function Edit screen khulne se theek pehle call hoga taaki data pre-fill ho jaye
  void loadEditData(String docId, String currentBrandId, String currentCategoryId) {
    editDocId = docId;
    editSelectedBrand = brandList.firstWhereOrNull((b) => b.id == currentBrandId);
    editSelectedCategory = categoryList.firstWhereOrNull((c) => c.id == currentCategoryId);
  }

  /// ================= 3. UPDATE LOGIC =================
  Future<void> updateMapping() async {
    if (editSelectedBrand == null || editSelectedCategory == null) {
      USnackBarHelpers.errorSnackBar(title: "Error", message: "Please select both Brand and Category");
      return;
    }

    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

    try {
      await FirebaseFirestore.instance.collection('BrandCategory').doc(editDocId).update({
        'brandId': editSelectedBrand!.id,
        'categoryId': editSelectedCategory!.id,
      });

      if (Get.isDialogOpen == true) Get.back();
      USnackBarHelpers.successSnackBar(title: "Success", message: "Mapping Updated! 🚀");
      Get.back();
    } catch (e) {
      if (Get.isDialogOpen == true) Get.back();
      USnackBarHelpers.errorSnackBar(title: "Error", message: e.toString());
    }
  }
  /// ================= 4. DELETE LOGIC =================
  Future<void> deleteMapping(String docId) async {
    Get.defaultDialog(
        title: "Delete Mapping",
        middleText: "Are you sure you want to delete this link?",
        textConfirm: "Delete", textCancel: "Cancel",
        buttonColor: Colors.redAccent, confirmTextColor: Colors.white, cancelTextColor: Colors.cyanAccent,
        backgroundColor: const Color(0xFF1E1E1E), titleStyle: const TextStyle(color: Colors.white), middleTextStyle: const TextStyle(color: Colors.white70),
        onConfirm: () async {
          Get.back(); // 🔥 Sirf Dialog band karo. Loading spinner mat lagao kyunki delete instant hota hai.

          try {
            await FirebaseFirestore.instance.collection('BrandCategory').doc(docId).delete();
            USnackBarHelpers.successSnackBar(title: "Deleted", message: "Mapping removed successfully.");
          } catch (e) {
            USnackBarHelpers.errorSnackBar(title: "Error", message: e.toString());
          }
        }
    );
  }
}
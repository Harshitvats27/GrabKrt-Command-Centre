import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/promo_code_model.dart';
import '../utils/enums.dart';
import '../utils/snackbar_helpers.dart'; // Tera snackbar helper

class PromoCodeController extends GetxController {
  static PromoCodeController get instance => Get.find();

  // Controllers
  final nameController = TextEditingController();
  final codeController = TextEditingController();
  final discountController = TextEditingController();
  final minOrderController = TextEditingController();
  final countController = TextEditingController();

  // Observables
  Rx<DiscountType> selectedType = DiscountType.percentage.obs;
  RxBool isActive = true.obs;
  Rx<DateTime?> startDate = Rx<DateTime?>(null);
  Rx<DateTime?> endDate = Rx<DateTime?>(null);

  // 🔥 1. Upload Logic (With Validation)
  Future<void> uploadPromoCode() async {
    // 🛑 VALIDATION CHECK
    if (nameController.text.trim().isEmpty ||
        codeController.text.trim().isEmpty ||
        discountController.text.trim().isEmpty ||
        minOrderController.text.trim().isEmpty ||
        countController.text.trim().isEmpty ||
        startDate.value == null) {

      USnackBarHelpers.errorSnackBar(
          title: "Validation Error",
          message: "Please fill all details and select a Start Date to upload the Promo Code."
      );
      return; // Stop execution here
    }

    try {
      final promo = PromoCodeModel(
        id: '',
        name: nameController.text.trim(),
        code: codeController.text.trim().toUpperCase(),
        discount: double.tryParse(discountController.text) ?? 0.0,
        discountType: selectedType.value,
        isActive: isActive.value,
        minOrderPrice: double.tryParse(minOrderController.text) ?? 0.0,
        noOfPromoCodes: int.tryParse(countController.text) ?? 0,
        startDate: startDate.value,
        endDate: endDate.value,
        userIds: [],
      );

      await FirebaseFirestore.instance.collection('PromoCodes').add(promo.toJson());

      USnackBarHelpers.successSnackBar(title: "Success", message: "Promo Code Uploaded! 🔥");
      clearForm();
      Get.back(); // Screen se wapas jaane ke liye
    } catch (e) {
      USnackBarHelpers.errorSnackBar(title: "System Error", message: e.toString());
    }
  }

  // 2. Load Data for Edit
  void loadPromoData(PromoCodeModel promo) {
    nameController.text = promo.name;
    codeController.text = promo.code;
    discountController.text = promo.discount.toString();
    minOrderController.text = promo.minOrderPrice.toString();
    countController.text = promo.noOfPromoCodes.toString();
    selectedType.value = promo.discountType ?? DiscountType.percentage;
    isActive.value = promo.isActive;
    startDate.value = promo.startDate;
    endDate.value = promo.endDate;
    update();
  }

  // 3. Update Logic
  Future<void> updatePromoCode(String promoId) async {
    // 🛑 VALIDATION CHECK FOR UPDATE
    if (nameController.text.trim().isEmpty ||
        codeController.text.trim().isEmpty ||
        discountController.text.trim().isEmpty ||
        minOrderController.text.trim().isEmpty ||
        countController.text.trim().isEmpty ||
        startDate.value == null) {

      USnackBarHelpers.errorSnackBar(
          title: "Validation Error",
          message: "Cannot update. Please ensure all details are filled."
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('PromoCodes').doc(promoId).update({
        'name': nameController.text.trim(),
        'code': codeController.text.trim().toUpperCase(),
        'discount': double.tryParse(discountController.text) ?? 0.0,
        'discountType': selectedType.value.toString(),
        'isActive': isActive.value,
        'minOrderPrice': double.tryParse(minOrderController.text) ?? 0.0,
        'noOfPromoCodes': int.tryParse(countController.text) ?? 0,
        'startDate': startDate.value,
        'endDate': endDate.value,
      });

      USnackBarHelpers.successSnackBar(title: "Success", message: "Promo Code Updated! ✅");
      Get.back();
    } catch (e) {
      USnackBarHelpers.errorSnackBar(title: "Error", message: e.toString());
    }
  }

  // 4. Clear Form
  void clearForm() {
    nameController.clear();
    codeController.clear();
    discountController.clear();
    minOrderController.clear();
    countController.clear();
    startDate.value = null;
    endDate.value = null;
    isActive.value = true;
    selectedType.value = DiscountType.percentage;
    update();
  }
}
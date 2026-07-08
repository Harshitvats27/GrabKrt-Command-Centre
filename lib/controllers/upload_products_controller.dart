import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/StoreModel.dart';
import '../models/product_model.dart';
import '../models/product_attribute_model.dart';
import '../models/product_variation_model.dart';
import '../models/brand_model.dart';
import '../models/categories_model.dart';
import '../models/product_category_model.dart';


class AdminProductController extends GetxController {
  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final salePriceController = TextEditingController();
  final stockController = TextEditingController();
  final descriptionController = TextEditingController();
  final skuController = TextEditingController();

  bool isFeatured = false;
  String productType = 'ProductType.single';

  File? thumbnailImage;

  // 🔥 STORE SELECTION VARIABLES
  List<StoreModel> activeStoresList = [];
  StoreModel? selectedStore;

  List<BrandModel> brandList = [];
  BrandModel? selectedBrand;

  List<CategoryModel> allCategories = [];
  List<CategoryModel> mainCategoryList = [];
  CategoryModel? selectedMainCategory;
  List<CategoryModel> subCategoryList = [];
  CategoryModel? selectedSubCategory;

  List<ProductAttributeModel> attributes = [];
  List<ProductVariationModel> variations = [];

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchBrands();
    fetchActiveStores(); // 🔥 INIT PE STORES FETCH HONGE
  }

  // 🔥 FETCH ONLY ACTIVE STORES (isActive == true)
  Future<void> fetchActiveStores() async {
    try {
      final vendorId = FirebaseAuth.instance.currentUser?.uid;
      if (vendorId == null) return;

      final snapshot = await FirebaseFirestore.instance.collection('Stores')
          .where('vendorId', isEqualTo: vendorId)
          .where('isActive', isEqualTo: true) // Sirf active stores laayega
          .get();

      activeStoresList = snapshot.docs.map((e) => StoreModel.fromSnapshot(e)).toList();
      update();
    } catch (e) {
      print("Error fetching stores: $e");
    }
  }

  Future<void> fetchCategories() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('Categories').get();
      allCategories = snapshot.docs.map((e) => CategoryModel.fromSnapshot(e)).toList();
      mainCategoryList = allCategories.where((cat) => cat.parentId == null || cat.parentId!.isEmpty).toList();
      update();
    } catch (e) {
      print("Category Fetch Error: $e");
    }
  }

  void onMainCategoryChanged(CategoryModel? mainCat) {
    selectedMainCategory = mainCat;
    selectedSubCategory = null;
    if (mainCat != null) {
      subCategoryList = allCategories.where((cat) => cat.parentId == mainCat.id).toList();
    } else {
      subCategoryList = [];
    }
    update();
  }

  Future<void> fetchBrands() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('Brands').get();
      brandList = snapshot.docs.map((e) => BrandModel.fromJson(e.data())).toList();
      update();
    } catch (e) {
      print("Brand Fetch Error: $e");
    }
  }

  Future<void> pickThumbnail() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      thumbnailImage = File(picked.path);
      update();
    }
  }

  Future<String> uploadImageToStorage(File image, String folder) async {
    final ref = FirebaseStorage.instance.ref('$folder/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  /// ================= ATTRIBUTE DIALOG =================
  /// ================= ATTRIBUTE DIALOG (PRO UI) =================
  void showAddAttributeDialog(BuildContext context) {
    TextEditingController nameCtrl = TextEditingController();
    TextEditingController valuesCtrl = TextEditingController();

    // 🔥 Modern UI helper function (Same as variation dialog)
    InputDecoration modernDecoration(String label, IconData icon) {
      return InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      );
    }

    // 🔥 Using native AlertDialog to prevent keyboard overflows
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.category, color: Colors.blue),
            SizedBox(width: 10),
            Expanded(child: Text("Add Attribute", style: TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        contentPadding: const EdgeInsets.all(20),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text("Define Product Attribute", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                const SizedBox(height: 15),

                TextField(
                  controller: nameCtrl,
                  decoration: modernDecoration("Name (e.g. Size, Color)", Icons.text_fields),
                ),
                const SizedBox(height: 15),

                TextField(
                  controller: valuesCtrl,
                  decoration: modernDecoration("Values (e.g. 40, 41, Black)", Icons.list),
                  maxLines: 2, // Thoda bada text field taaki zyada values aaraam se type ho sake
                ),
                const SizedBox(height: 5),

                // User ke liye ek choti si tip
                const Text(
                    "Separate multiple values with a comma (,)",
                    style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)
                ),
              ],
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty && valuesCtrl.text.trim().isNotEmpty) {
                List<String> valList = valuesCtrl.text.split(',').map((e) => e.trim()).toList();
                attributes.add(ProductAttributeModel(name: nameCtrl.text.trim(), values: valList));
                update();
                Get.back();
              } else {
                Get.snackbar(
                  "Error",
                  "Fields cannot be empty",
                  backgroundColor: Colors.redAccent,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text("Add Attribute", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// ================= VARIATION DIALOG =================
  /// ================= VARIATION DIALOG =================
  void showAddVariationDialog(BuildContext context) {
    if (attributes.isEmpty) {
      Get.snackbar("Hold On", "Pehle Attributes add karo!");
      return;
    }

    TextEditingController vPriceCtrl = TextEditingController();
    TextEditingController vSalePriceCtrl = TextEditingController();
    TextEditingController vStockCtrl = TextEditingController();
    TextEditingController vDescCtrl = TextEditingController();
    TextEditingController vSkuCtrl = TextEditingController();

    Map<String, String> selectedAttributes = {};
    File? vImageFile;
    InputDecoration modernDecoration(String label, IconData icon) {
      return InputDecoration(
        labelText: label, // 🔥 Yahi wo jadoo hai jisse text upar animate hoga
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      );
    }
    // 🔥 FIX: Swapped Get.defaultDialog for Get.dialog(AlertDialog())
    // AlertDialog automatically handles the keyboard popping up beautifully!
    Get.dialog(
      AlertDialog(
        // 🔥 Dialog ko ek smooth rounded shape di hai
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.style, color: Colors.blue),
            SizedBox(width: 10),
            Expanded(child: Text("Add New Variation", style: TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        contentPadding: const EdgeInsets.all(20),
        content: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text("Select Combination:", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                      const SizedBox(height: 10),
                      ...attributes.map((attr) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            decoration: modernDecoration(attr.name ?? "Attribute", Icons.category),
                            items: attr.values?.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                            onChanged: (val) {
                              if (val != null && attr.name != null) {
                                selectedAttributes[attr.name!] = val;
                              }
                            },
                          ),
                        );
                      }).toList(),
                      const Divider(height: 20, thickness: 1),

                      TextField(
                        controller: vSkuCtrl,
                        decoration: modernDecoration("Variation SKU", Icons.qr_code),
                      ),
                      const SizedBox(height: 15),

                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: vPriceCtrl,
                              decoration: modernDecoration("Price", Icons.currency_rupee),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: vSalePriceCtrl,
                              decoration: modernDecoration("Sale Price", Icons.currency_rupee),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      TextField(
                        controller: vStockCtrl,
                        decoration: modernDecoration("Stock Quantity", Icons.inventory_2),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 15),

                      TextField(
                        controller: vDescCtrl,
                        decoration: modernDecoration("Short Description", Icons.description),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 20),

                      // Image Picker UI Update
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue.withOpacity(0.5), style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.blue.withOpacity(0.05),
                        ),
                        child: vImageFile == null
                            ? TextButton.icon(
                          onPressed: () async {
                            final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                            if (picked != null) setState(() => vImageFile = File(picked.path));
                          },
                          icon: const Icon(Icons.add_a_photo, size: 28),
                          label: const Text("Tap to Pick Image", style: TextStyle(fontSize: 16)),
                        )
                            : Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(vImageFile!, height: 100, width: double.infinity, fit: BoxFit.cover),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: () => setState(() => vImageFile = null),
                              icon: const Icon(Icons.delete, color: Colors.red),
                              label: const Text("Remove Image", style: TextStyle(color: Colors.red)),
                              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent)),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () async {
              if (vPriceCtrl.text.isEmpty || vStockCtrl.text.isEmpty || vImageFile == null || selectedAttributes.length != attributes.length) {
                Get.snackbar("Error", "Please fill Price, Stock, pick Image, and select ALL attributes.", backgroundColor: Colors.redAccent, colorText: Colors.white);
                return;
              }

              Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

              String imgUrl = await uploadImageToStorage(vImageFile!, 'variations');

              variations.add(ProductVariationModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                attributeValues: selectedAttributes,
                sku: vSkuCtrl.text.trim(),
                price: double.tryParse(vPriceCtrl.text.trim()) ?? 0.0,
                salePrice: double.tryParse(vSalePriceCtrl.text.trim()) ?? 0.0,
                stock: int.tryParse(vStockCtrl.text.trim()) ?? 0,
                image: imgUrl,
                description: vDescCtrl.text.trim(),
              ));

              update();
              Get.back(); // Closes the loading indicator
              Get.back(); // Closes the variation dialog
            },
            child: const Text("Save Variation", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
  /// ================= UPLOAD PRODUCT =================
  Future<void> uploadProduct() async {
    try {
      // 🔥 NEW VALIDATION: Store must be selected!
      if (selectedStore == null) {
        Get.snackbar(
          "Store Required",
          "Please select an active store before uploading the product.",
          backgroundColor: Colors.orangeAccent,
          colorText: Colors.white,
        );
        return; // Yahan se aage process hi nahi hoga
      }

      if (titleController.text.isEmpty || priceController.text.isEmpty || stockController.text.isEmpty || thumbnailImage == null || selectedBrand == null || selectedSubCategory == null || selectedMainCategory == null) {
        Get.snackbar("Error", "Please fill all main fields and select categories.", backgroundColor: Colors.redAccent, colorText: Colors.white);
        return;
      }

      Get.dialog(Center(child: CircularProgressIndicator()), barrierDismissible: false);

      String thumbnailUrl = await uploadImageToStorage(thumbnailImage!, 'products/thumbnails');

      final product = ProductModel(
        id: '', // Firebase will generate
        title: titleController.text.trim(),
        stock: int.tryParse(stockController.text.trim()) ?? 0,
        price: double.tryParse(priceController.text.trim()) ?? 0.0,
        salePrice: double.tryParse(salePriceController.text.trim()) ?? 0.0,
        sku: skuController.text.trim(),
        thumbnail: thumbnailUrl,
        images: [],
        productType: productType,
        brand: selectedBrand,
        categoryId: selectedSubCategory!.id,
        description: descriptionController.text.trim(),
        uploadedBy: FirebaseAuth.instance.currentUser?.uid ?? '',
        isFeatured: isFeatured,
        productAttributes: productType == 'ProductType.variable' ? attributes : [],
        productVariations: productType == 'ProductType.variable' ? variations : [],
        // 🔥 NAYE FIELDS JO DATABASE MEIN JAYENGE
        storeId: selectedStore!.id,
        storeName: selectedStore!.storeName,
      );

      DocumentReference docRef = await FirebaseFirestore.instance.collection('Products').add(product.toJson());

      String generatedProductId = docRef.id;

      await FirebaseFirestore.instance.collection('ProductCategory').add({
        'productId': generatedProductId,
        'categoryId': selectedMainCategory!.id,
      });

      await FirebaseFirestore.instance.collection('ProductCategory').add({
        'productId': generatedProductId,
        'categoryId': selectedSubCategory!.id,
      });

      Get.back(); // Close Loading Dialog
      Get.snackbar("Success", "Product Uploaded successfully to ${selectedStore!.storeName}! 🔥", backgroundColor: Colors.green, colorText: Colors.white);
      clearForm();
      Get.back(); // Go back to previous screen
    } catch (e) {
      Get.back(); // Remove loading dialog if error occurs
      Get.snackbar("Error", e.toString(), backgroundColor: Colors.redAccent, colorText: Colors.white);
      print("Upload Error: $e");
    }
  }

  void clearForm() {
    titleController.clear(); priceController.clear(); salePriceController.clear(); stockController.clear(); descriptionController.clear(); skuController.clear();
    thumbnailImage = null;
    selectedBrand = null; selectedMainCategory = null; selectedSubCategory = null; subCategoryList.clear();
    selectedStore = null; // 🔥 Store clear kar diya
    attributes.clear(); variations.clear();
    isFeatured = false;
    update();
  }
}
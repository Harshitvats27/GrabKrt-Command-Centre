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
  void showAddAttributeDialog(BuildContext context) {
    TextEditingController nameCtrl = TextEditingController();
    TextEditingController valuesCtrl = TextEditingController();

    Get.defaultDialog(
      title: "Add Attribute",
      content: Column(
        children: [
          TextField(controller: nameCtrl, decoration: InputDecoration(hintText: "Name (e.g. Size, Color)")),
          TextField(controller: valuesCtrl, decoration: InputDecoration(hintText: "Values (e.g. 40, 41, Black)")),
        ],
      ),
      confirm: ElevatedButton(
        onPressed: () {
          if (nameCtrl.text.trim().isNotEmpty && valuesCtrl.text.trim().isNotEmpty) {
            List<String> valList = valuesCtrl.text.split(',').map((e) => e.trim()).toList();
            attributes.add(ProductAttributeModel(name: nameCtrl.text.trim(), values: valList));
            update();
            Get.back();
          } else {
            Get.snackbar("Error", "Fields cannot be empty");
          }
        },
        child: Text("Add"),
      ),
    );
  }

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

    Get.defaultDialog(
      title: "Add New Variation",
      content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text("Select Combination:", style: TextStyle(fontWeight: FontWeight.bold)),
                  ...attributes.map((attr) {
                    return DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: attr.name),
                      items: attr.values?.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                      onChanged: (val) {
                        if (val != null && attr.name != null) {
                          selectedAttributes[attr.name!] = val;
                        }
                      },
                    );
                  }).toList(),
                  Divider(),

                  TextField(controller: vSkuCtrl, decoration: InputDecoration(hintText: "Variation SKU (e.g. IP-128-BLK)")),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: vPriceCtrl, decoration: InputDecoration(hintText: "Price"), keyboardType: TextInputType.number)),
                      SizedBox(width: 10),
                      Expanded(child: TextField(controller: vSalePriceCtrl, decoration: InputDecoration(hintText: "Sale Price"), keyboardType: TextInputType.number)),
                    ],
                  ),
                  TextField(controller: vStockCtrl, decoration: InputDecoration(hintText: "Stock Quantity"), keyboardType: TextInputType.number),
                  TextField(controller: vDescCtrl, decoration: InputDecoration(hintText: "Short Description")),
                  SizedBox(height: 10),

                  vImageFile == null
                      ? ElevatedButton.icon(
                    onPressed: () async {
                      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                      if (picked != null) setState(() => vImageFile = File(picked.path));
                    },
                    icon: Icon(Icons.add_a_photo),
                    label: Text("Pick Variation Image"),
                  )
                      : Column(
                    children: [
                      Image.file(vImageFile!, height: 80, fit: BoxFit.cover),
                      TextButton(onPressed: () => setState(() => vImageFile = null), child: Text("Remove"))
                    ],
                  ),
                ],
              ),
            );
          }
      ),
      confirm: ElevatedButton(
        onPressed: () async {
          if (vPriceCtrl.text.isEmpty || vStockCtrl.text.isEmpty || vImageFile == null || selectedAttributes.length != attributes.length) {
            Get.snackbar("Error", "Please fill Price, Stock, pick Image, and select ALL attributes.");
            return;
          }

          Get.dialog(Center(child: CircularProgressIndicator()), barrierDismissible: false);

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
          Get.back();
          Get.back();
        },
        child: Text("Save Variation"),
      ),
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
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../models/product_model.dart';
import '../models/brand_model.dart';
import '../models/categories_model.dart';
import '../models/product_attribute_model.dart';
import '../models/product_variation_model.dart';

import '../utils/snackbar_helpers.dart';

class EditProductController extends GetxController {
  final ProductModel product;
  EditProductController({required this.product});

  // Text Controllers
  late TextEditingController titleCtrl;
  late TextEditingController skuCtrl;
  late TextEditingController priceCtrl;
  late TextEditingController salePriceCtrl;
  late TextEditingController stockCtrl;
  late TextEditingController descCtrl;

  // State Variables
  bool isFeatured = false;
  String productType = 'ProductType.single';

  // Image Variables
  File? newThumbnail;
  String existingThumbnail = '';

  // Dropdown Data
  List<BrandModel> brandList = [];
  BrandModel? selectedBrand;

  List<CategoryModel> allCategories = [];
  List<CategoryModel> mainCategoryList = [];
  CategoryModel? selectedMainCategory;
  List<CategoryModel> subCategoryList = [];
  CategoryModel? selectedSubCategory;

  // Variable Product Data
  List<ProductAttributeModel> attributes = [];
  List<ProductVariationModel> variations = [];

  @override
  void onInit() {
    super.onInit();
    _initializeData();
    fetchCategoriesAndBrands();
  }

  void _initializeData() {
    titleCtrl = TextEditingController(text: product.title);
    skuCtrl = TextEditingController(text: product.sku ?? ''); // 🔥 SKU Fetching handled safely
    priceCtrl = TextEditingController(text: product.price.toString());
    salePriceCtrl = TextEditingController(text: product.salePrice.toString());
    stockCtrl = TextEditingController(text: product.stock.toString());
    descCtrl = TextEditingController(text: product.description ?? '');

    isFeatured = product.isFeatured ?? false;
    productType = product.productType;
    existingThumbnail = product.thumbnail;

    attributes = product.productAttributes ?? [];
    variations = product.productVariations ?? [];
  }

  Future<void> fetchCategoriesAndBrands() async {
    try {
      final brandSnap = await FirebaseFirestore.instance.collection('Brands').get();
      brandList = brandSnap.docs.map((e) => BrandModel.fromJson(e.data())).toList();

      if (product.brand != null) {
        selectedBrand = brandList.firstWhereOrNull((b) => b.id == product.brand!.id);
      }

      final catSnap = await FirebaseFirestore.instance.collection('Categories').get();
      allCategories = catSnap.docs.map((e) => CategoryModel.fromSnapshot(e)).toList();
      mainCategoryList = allCategories.where((cat) => cat.parentId == null || cat.parentId!.isEmpty).toList();

      if (product.categoryId != null && product.categoryId!.isNotEmpty) {
        selectedSubCategory = allCategories.firstWhereOrNull((cat) => cat.id == product.categoryId);
        if (selectedSubCategory != null && selectedSubCategory!.parentId != null) {
          selectedMainCategory = mainCategoryList.firstWhereOrNull((cat) => cat.id == selectedSubCategory!.parentId);
          subCategoryList = allCategories.where((cat) => cat.parentId == selectedMainCategory!.id).toList();
        }
      }
      update();
    } catch (e) {
      print("Error fetching dropdown data: $e");
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

  Future<void> pickNewThumbnail() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      newThumbnail = File(picked.path);
      update();
    }
  }

  Future<String> uploadImageToStorage(File image, String folder) async {
    final ref = FirebaseStorage.instance.ref('$folder/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }
  /// ================= ADD ATTRIBUTE LOGIC =================
  void showAddAttributeDialog(BuildContext context) {
    TextEditingController nameCtrl = TextEditingController();
    TextEditingController valuesCtrl = TextEditingController();

    Get.defaultDialog(
      title: "Add Attribute",
      content: Column(
        children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: "Name (e.g. Size, Color)")),
          TextField(controller: valuesCtrl, decoration: const InputDecoration(hintText: "Values (e.g. 40, 41, Black)")),
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
        child: const Text("Add"),
      ),
    );
  }
  /// ================= NEW VARIATION ADD LOGIC IN EDIT SCREEN =================
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
                  const Text("Select Combination:", style: TextStyle(fontWeight: FontWeight.bold)),
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
                  const Divider(),

                  TextField(controller: vSkuCtrl, decoration: const InputDecoration(hintText: "Variation SKU (e.g. IP-128-BLK)")),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: vPriceCtrl, decoration: const InputDecoration(hintText: "Price"), keyboardType: TextInputType.number)),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: vSalePriceCtrl, decoration: const InputDecoration(hintText: "Sale Price"), keyboardType: TextInputType.number)),
                    ],
                  ),
                  TextField(controller: vStockCtrl, decoration: const InputDecoration(hintText: "Stock Quantity"), keyboardType: TextInputType.number),
                  TextField(controller: vDescCtrl, decoration: const InputDecoration(hintText: "Short Description")),
                  const SizedBox(height: 10),

                  vImageFile == null
                      ? ElevatedButton.icon(
                    onPressed: () async {
                      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                      if (picked != null) setState(() => vImageFile = File(picked.path));
                    },
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text("Pick Variation Image"),
                  )
                      : Column(
                    children: [
                      Image.file(vImageFile!, height: 80, fit: BoxFit.cover),
                      TextButton(onPressed: () => setState(() => vImageFile = null), child: const Text("Remove"))
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

          update(); // Update the UI to show new variation
          Get.back(); // Close Loading
          Get.back(); // Close Dialog
        },
        child: const Text("Save Combo"),
      ),
    );
  }
// 🔥 Ye function UI se variation remove karega
  void removeVariation(int index) {
    variations.removeAt(index);
    update(); // Screen refresh ho jayegi aur wo gayab ho jayega
  }
  // 🔥 Final Database Update Logic
  Future<void> updateProduct() async {
    // 1. Loading Dialog dikhao
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

    try {
      String finalThumbnailUrl = existingThumbnail;

      if (newThumbnail != null) {
        finalThumbnailUrl = await uploadImageToStorage(newThumbnail!, 'products/thumbnails');
      }

      Map<String, dynamic> updatedData = {
        'title': titleCtrl.text.trim(),
        'sku': skuCtrl.text.trim(),
        'price': double.tryParse(priceCtrl.text) ?? product.price,
        'salePrice': double.tryParse(salePriceCtrl.text) ?? product.salePrice,
        'stock': int.tryParse(stockCtrl.text) ?? product.stock,
        'description': descCtrl.text.trim(),
        'isFeatured': isFeatured,
        'thumbnail': finalThumbnailUrl,
        'productType': productType,
        'brand': selectedBrand?.toJson(),
        'categoryId': selectedSubCategory?.id ?? product.categoryId,
        'productAttributes': attributes.map((e) => e.toJson()).toList(),
        'productVariations': variations.map((e) => e.toJson()).toList(),
      };

      // 2. Firebase Update
      await FirebaseFirestore.instance.collection('Products').doc(product.id).update(updatedData);

      // 3. Category Mapping Update (if needed)
      if (selectedSubCategory != null && selectedSubCategory!.id != product.categoryId) {
        final oldMappings = await FirebaseFirestore.instance.collection('ProductCategory').where('productId', isEqualTo: product.id).get();
        for (var doc in oldMappings.docs) { await doc.reference.delete(); }
        await FirebaseFirestore.instance.collection('ProductCategory').add({
          'productId': product.id,
          'categoryId': selectedSubCategory!.id
        });
      }

      // 4. SAFELY CLOSE: Loading band karo
      if (Get.isDialogOpen == true) Get.back();

      USnackBarHelpers.successSnackBar(title: 'Success', message: 'Product updated perfectly!');

      // 5. Screen band karo
      Get.back();

    } catch (e) {
      // Error hone par sirf loading band karo, screen nahi
      if (Get.isDialogOpen == true) Get.back();
      USnackBarHelpers.errorSnackBar(title: 'Error', message: e.toString());
    }
  }
}
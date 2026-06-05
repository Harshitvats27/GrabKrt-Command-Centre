import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

import '../models/brand_model.dart';

class BrandController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  var brandList = <BrandModel>[].obs;


  /// 🔥 Upload Image to Firebase Storage
  Future<String> uploadImage(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      Reference ref =
      _storage.ref().child('brands_images').child(fileName);

      UploadTask uploadTask = ref.putFile(imageFile);

      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception("Image upload failed: $e");
    }
  }

  /// 🔥 Add OR Update Brand
  Future<String> addOrUpdateBrand({
    required String name,
    required File imageFile,
    required bool isFeatured,
    required int productsCount,
  }) async {
    try {
      final allBrands = await _db.collection('Brands').get();

      DocumentSnapshot? existingDoc;

      // 🔍 Manual case-insensitive check
      for (var doc in allBrands.docs) {
        String dbName = doc['name'] ?? '';

        if (dbName.toLowerCase() == name.toLowerCase()) {
          existingDoc = doc;
          break;
        }
      }

      if (existingDoc != null) {
        // 👉 Brand exists → update count
        int existingCount = existingDoc['productCount'] ?? 0;

        await _db.collection('Brands').doc(existingDoc.id).update({
          'productCount': existingCount + productsCount,
        });

        return "$name brand already exists. Updating your products count ✅";
      } else {
        // 👉 New brand
        var doc = _db.collection('Brands').doc();

        String imageUrl = await uploadImage(imageFile);

        BrandModel brand = BrandModel(
          id: doc.id,
          name: name,
          image: imageUrl,
          isFeatured: isFeatured,
          productsCount: productsCount,
        );

        await doc.set(brand.toJson());

        return "Brand added successfully 🚀";
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  Future<void> fetchBrands() async {
    try {
      var snapshot =
      await FirebaseFirestore.instance.collection('Brands').get();

      brandList.value = snapshot.docs
          .map((doc) => BrandModel.fromSnapshot(doc))
          .toList();

    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
  Future<String> updateBrand({
    required String id,
    required String name,
    required int productsCount,
    required bool isFeatured,
    File? newImageFile,
    required String oldImageUrl,
  }) async {
    try {
      String imageUrl = oldImageUrl;

      // 👉 Agar new image select ki hai to upload karo
      if (newImageFile != null) {
        imageUrl = await uploadImage(newImageFile);
      }

      await _db.collection('Brands').doc(id).update({
        'name': name,
        'productCount': productsCount,
        'isFeatured': isFeatured,
        'image': imageUrl,
      });

      return "Brand updated successfully ✅";

    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
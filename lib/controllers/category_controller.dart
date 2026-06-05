import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/categories_model.dart';

class CategoryController extends GetxController {
  final ImagePicker picker = ImagePicker();

  Rxn<XFile> selectedImage = Rxn<XFile>();
  RxString imageUrl = ''.obs;

  List<CategoryModel> parentCategories = [];

  /// PICK IMAGE
  Future<void> pickImage() async {
    final img = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (img != null) {
      selectedImage.value = img;
      update();
    }
  }

  /// REMOVE IMAGE
  void removeImage() {
    selectedImage.value = null;
    update();
  }

  /// UPLOAD IMAGE
  Future<void> uploadImage() async {
    if (selectedImage.value == null) return;

    TaskSnapshot snapshot = await FirebaseStorage.instance
        .ref()
        .child("Categories")
        .child("${DateTime.now().millisecondsSinceEpoch}.jpg")
        .putFile(File(selectedImage.value!.path));

    imageUrl.value = await snapshot.ref.getDownloadURL();
  }

  /// 🔥 FETCH ONLY MAIN CATEGORIES
  Future<void> fetchParentCategories() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Categories')
        .where('parentId', isNull: true) // ✅ FIXED
        .get();

    parentCategories = snapshot.docs
        .map((doc) => CategoryModel.fromSnapshot(doc))
        .toList();

    update();
  }
}
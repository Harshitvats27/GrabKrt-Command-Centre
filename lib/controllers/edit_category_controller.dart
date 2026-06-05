import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../models/categories_model.dart';

class EditCategoryController extends GetxController {
  CategoryModel categoriesModel;
  EditCategoryController({required this.categoriesModel});

  final ImagePicker picker = ImagePicker();

  RxString categoryImg = ''.obs;
  RxBool isFeatured = false.obs;
  Rxn<XFile> newImage = Rxn<XFile>();

  @override
  void onInit() {
    super.onInit();
    categoryImg.value = categoriesModel.image;
    isFeatured.value = categoriesModel.isFeatured ?? false;
  }

  /// PICK NEW IMAGE
  Future pickImage() async {
    final img = await picker.pickImage(source: ImageSource.gallery);

    if (img != null) {
      newImage.value = img;
      update();
    }
  }

  /// UPLOAD NEW IMAGE
  Future<String> uploadNewImage() async {
    if (newImage.value == null) return categoryImg.value;

    final snapshot = await FirebaseStorage.instance
        .ref()
        .child("Categories")
        .child("${DateTime.now().millisecondsSinceEpoch}.jpg")
        .putFile(File(newImage.value!.path));

    return await snapshot.ref.getDownloadURL();
  }

  /// DELETE OLD IMAGE
  Future deleteOldImage(String url) async {
    try {
      await FirebaseStorage.instance.refFromURL(url).delete();
    } catch (e) {
      print("Delete error: $e");
    }
  }

  /// DELETE CATEGORY
  Future deleteCategory(String id) async {
    await FirebaseFirestore.instance
        .collection('Categories')
        .doc(id)
        .delete();
  }
}
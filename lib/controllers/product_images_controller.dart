// ignore_for_file: file_names, unused_field, unused_local_variable, prefer_const_constructors, avoid_print, no_leading_underscores_for_local_identifiers

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class AddProductImagesController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  Rxn<XFile> selectedImage = Rxn<XFile>(); // only ONE image
  RxString imageUrl = ''.obs;

  final FirebaseStorage storageRef = FirebaseStorage.instance;

  Future<void> pickImage() async {
    final img = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (img != null) {
      selectedImage.value = img;
      update();
    }
  }

  Future<void> uploadImage() async {
    if (selectedImage.value == null) return;

    TaskSnapshot snapshot = await storageRef
        .ref()
        .child("Categories") // 🔥 proper folder
        .child("${DateTime.now().millisecondsSinceEpoch}.jpg")
        .putFile(File(selectedImage.value!.path));

    imageUrl.value = await snapshot.ref.getDownloadURL();
  }

  void removeImage() {
    selectedImage.value = null;
    update();
  }
}
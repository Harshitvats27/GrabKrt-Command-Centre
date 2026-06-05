import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/StoreModel.dart';

import '../utils/snackbar_helpers.dart';

class StoreController extends GetxController {
  static StoreController get instance => Get.find();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  RxList<StoreModel> myStores = <StoreModel>[].obs;
  RxList<StoreModel> filteredStores = <StoreModel>[].obs;

  RxBool isLoading = true.obs;
  RxBool isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyStores();
  }

  Future<void> fetchMyStores() async {
    try {
      isLoading.value = true;
      final vendorId = _auth.currentUser?.uid;
      if (vendorId == null) return;

      final snapshot = await _db.collection('Stores')
          .where('vendorId', isEqualTo: vendorId)
          .get();

      myStores.value = snapshot.docs.map((doc) => StoreModel.fromSnapshot(doc)).toList();

      // 🔥 BUG FIX 1: '=' ki jagah '.assignAll()' use kiya taaki duplication na ho
      filteredStores.assignAll(myStores);

    } catch (e) {
      USnackBarHelpers.errorSnackBar(title: "Error", message: "Failed to fetch stores: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void searchStore(String query) {
    if (query.isEmpty) {
      filteredStores.assignAll(myStores);
    } else {
      filteredStores.value = myStores.where((store) =>
      store!.storeName.toLowerCase().contains(query.toLowerCase()) ||
          store!.ownerName.toLowerCase().contains(query.toLowerCase()) ||
          store!.address.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
  }

  Future<bool> addStore(StoreModel store) async {
    try {
      isSaving.value = true;
      final vendorId = _auth.currentUser?.uid;
      if (vendorId == null) throw "User not logged in!";

      final docRef = _db.collection('Stores').doc();
      store.id = docRef.id;
      store.vendorId = vendorId;

      await docRef.set(store.toJson());

      // 🔥 BUG FIX 2: Sirf main list mein add karo, aur filtered list ko sync (copy) kar lo
      myStores.add(store);
      filteredStores.assignAll(myStores);

      USnackBarHelpers.successSnackBar(title: "Success", message: "Store '${store.storeName}' added successfully! 🚀");
      return true;
    } catch (e) {
      USnackBarHelpers.errorSnackBar(title: "Error", message: "Failed to save store: $e");
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> toggleStoreStatus(String storeId, bool currentStatus) async {
    try {
      final newStatus = !currentStatus;

      await _db.collection('Stores').doc(storeId).update({'isActive': newStatus});

      final index = myStores.indexWhere((store) => store.id == storeId);
      if (index != -1) {
        myStores[index].isActive = newStatus;
        myStores.refresh();
      }

      final filteredIndex = filteredStores.indexWhere((store) => store.id == storeId);
      if (filteredIndex != -1) {
        filteredStores[filteredIndex].isActive = newStatus;
        filteredStores.refresh();
      }

      if (newStatus) {
        USnackBarHelpers.successSnackBar(title: "Store Opened", message: "Your store is now OPEN for business.");
      } else {
        USnackBarHelpers.warningSnackBar(title: "Store Closed", message: "Your store is now CLOSED.");
      }

    } catch (e) {
      USnackBarHelpers.errorSnackBar(title: "Error", message: "Could not change status: $e");
    }
  }
}
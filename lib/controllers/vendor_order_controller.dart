import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VendorOrderController extends GetxController {
  static VendorOrderController get instance => Get.find();

  RxBool isLoading = false.obs;

  // 🔥 Isme seedha filtered orders ki list aayegi
  RxList<Map<String, dynamic>> vendorOrders = <Map<String, dynamic>>[].obs;

  final _db = FirebaseFirestore.instance;
  final String currentVendorId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    fetchVendorOrders();
  }

  Future<void> fetchVendorOrders() async {
    if (currentVendorId.isEmpty) return;

    try {
      isLoading.value = true;

      // 1. Fetch all orders globally
      final orderSnapshot = await _db.collectionGroup('Store_Orders').get();

      List<Map<String, dynamic>> tempOrders = [];

      // 2. 🔥 Filter out orders that contain this vendor's products
      for (var doc in orderSnapshot.docs) {
        final orderData = doc.data() as Map<String, dynamic>;
        final List<dynamic> items = orderData['items'] ?? [];

        // Check karo kya is order mein is vendor ka koi product hai
        List<dynamic> myItems = items.where((item) => item['uploadedBy'] == currentVendorId).toList();

        if (myItems.isNotEmpty) {
          // Is vendor ke items ka total price nikalo
          double myTotal = myItems.fold(0.0, (sum, item) => sum + ((item['price'] ?? 0.0) * (item['quantity'] ?? 1)));

          // Order ki saari details aur vendor-specific data ko combine karo
          tempOrders.add({
            'orderId': orderData['id'] ?? doc.id,
            'userId': orderData['userId'] ?? '',
            'orderDate': orderData['orderDate'],
            'status': orderData['status'] ?? 'Pending',
            'totalAmount': orderData['totalAmount'] ?? 0.0, // Full order total
            'vendorTotal': myTotal, // 🔥 Sirf is vendor ka total amount
            'vendorItems': myItems, // 🔥 Sirf is vendor ke products
          });
        }
      }

      // Sort by date (Latest order sabse upar)
      tempOrders.sort((a, b) => (b['orderDate'] as Timestamp).compareTo(a['orderDate'] as Timestamp));

      vendorOrders.assignAll(tempOrders);
    } catch (e) {
      print("Error fetching vendor orders: $e");
    } finally {
      isLoading.value = false;
    }
  }
  // 🔥 STATUS UPDATE LOGIC (DUAL-WRITE UPDATE)
  // 🔥 STATUS UPDATE LOGIC (ITEM-LEVEL DUAL-WRITE)
  // Future<void> updateOrderStatus(String orderId, String userId, String newStatus) async {
  //   print("DEBUG: Trying to update Order ID: $orderId");
  //   print("DEBUG: Trying to update User ID: $userId");
  //   Get.dialog(const Center(child: CircularProgressIndicator(color: Colors.cyanAccent)), barrierDismissible: false);
  //
  //   try {
  //     // 1. Database References
  //     DocumentReference userOrderRef = _db.collection('Users').doc(userId).collection('Orders').doc(orderId);
  //     DocumentReference globalOrderRef = _db.collection('All_Orders').doc(orderId); // Apne global orders collection ka naam check kar lena
  //     print("DEBUG: Looking for document at path: ${globalOrderRef.path}");
  //     // 2. Pehle Firebase se current order fetch karo taaki items nikal sakein
  //     DocumentSnapshot orderSnap = await globalOrderRef.get();
  //     if (!orderSnap.exists) {
  //       throw "Order not found in database!";
  //     }
  //
  //     Map<String, dynamic> orderData = orderSnap.data() as Map<String, dynamic>;
  //     List<dynamic> items = orderData['items'] ?? [];
  //
  //     bool isUpdated = false;
  //
  //     // 3. 🔥 MAGIC: Sirf apne vendor ke items dhoondho aur unka status update karo
  //     List<dynamic> updatedItems = items.map((item) {
  //       if (item['uploadedBy'] == currentVendorId) {
  //         isUpdated = true;
  //         // Map copy banani padti hai update karne ke liye
  //         var modifiedItem = Map<String, dynamic>.from(item);
  //         modifiedItem['status'] = newStatus; // Naya status sirf is item pe lagega
  //         return modifiedItem;
  //       }
  //       return item; // Dusre vendor ka item chhedna nahi hai, waisa hi return kar do
  //     }).toList();
  //
  //     // Agar koi item update hua hai, tabhi Firebase mein push karo
  //     if (isUpdated) {
  //       WriteBatch batch = _db.batch();
  //
  //       // 4. Update the 'items' array with the modified one
  //       batch.update(userOrderRef, {'items': updatedItems});
  //       batch.update(globalOrderRef, {'items': updatedItems});
  //
  //       await batch.commit();
  //     }
  //
  //     // List ko wapas refresh karo
  //     await fetchVendorOrders();
  //
  //     Get.back(); // Loading dialog band karo
  //     Get.back(); // Details screen se back aao list par
  //
  //     Get.snackbar(
  //       "Status Updated 🚀",
  //       "Your items have been marked as $newStatus",
  //       backgroundColor: Colors.cyanAccent,
  //       colorText: Colors.black,
  //       snackPosition: SnackPosition.BOTTOM,
  //       margin: const EdgeInsets.all(15),
  //     );
  //
  //   } catch (e) {
  //     Get.back();
  //     Get.snackbar("Error", e.toString(), backgroundColor: Colors.redAccent, colorText: Colors.white);
  //     print("Update Error: $e");
  //   }
  // }

  Future<void> updateOrderStatus(String subOrderId, String userId, String newStatus) async {
    print("DEBUG: Trying to update Sub-Order ID: $subOrderId");
    Get.dialog(const Center(child: CircularProgressIndicator(color: Colors.cyanAccent)), barrierDismissible: false);

    try {
      // 1. Pehle Store_Orders se order fetch karo
      DocumentReference storeOrderRef = _db.collection('Store_Orders').doc(subOrderId);
      DocumentSnapshot orderSnap = await storeOrderRef.get();

      if (!orderSnap.exists) {
        throw "Order not found in Store_Orders database!";
      }

      Map<String, dynamic> orderData = orderSnap.data() as Map<String, dynamic>;

      // 🔥 ASLI MAGIC YAHAN HAI: Master Order ID nikalna
      String masterOrderId = orderData['masterOrderId'];
      print("DEBUG: Master Order ID is: $masterOrderId");

      // 2. Ab dono ke sahi References banao
      // User ke collection mein MASTER ID dhoondhni hai
      DocumentReference userOrderRef = _db.collection('Users').doc(userId).collection('Orders').doc(masterOrderId);

      // 🔥 FIX 1: All_Orders mein bhi ab Master ID hi use karni hai taaki naya doc na bane
      DocumentReference allOrdersRef = _db.collection('All_Orders').doc(masterOrderId);

      // 3. User ke current master order se items nikalo taaki update kar sakein
      DocumentSnapshot userOrderSnap = await userOrderRef.get();
      if (!userOrderSnap.exists) {
        throw "Master Order not found in User's history!";
      }

      Map<String, dynamic> userOrderData = userOrderSnap.data() as Map<String, dynamic>;
      List<dynamic> items = userOrderData['items'] ?? [];

      bool isUpdated = false;

      // 4. Sirf apne vendor ke items dhoondho aur unka status update karo
      List<dynamic> updatedItems = items.map((item) {
        // NOTE: Ensure currentVendorId variable yahan accessible ho
        if (item['uploadedBy'] == currentVendorId) {
          isUpdated = true;
          var modifiedItem = Map<String, dynamic>.from(item);
          modifiedItem['status'] = newStatus;
          return modifiedItem;
        }
        return item;
      }).toList();

      if (isUpdated) {
        WriteBatch batch = _db.batch();

        // 5. Update lagao (SetOptions ke sath safe raho)

        // 🔥 FIX 2: User History mein items ke sath main 'status' bhi update hoga
        batch.set(userOrderRef, {
          'items': updatedItems,
          'status': newStatus
        }, SetOptions(merge: true));

        // 🔥 FIX 3: All_Orders mein bhi master doc par items aur status dono update honge
        batch.set(allOrdersRef, {
          'items': updatedItems,
          'status': newStatus
        }, SetOptions(merge: true));

        // Store_Orders (Vendor ka sub-order) waise ka waisa hi update hoga
        batch.set(storeOrderRef, {'status': newStatus}, SetOptions(merge: true));

        await batch.commit();
      }

      // List ko wapas refresh karo
      await fetchVendorOrders();

      Get.back(); // Loading dialog band
      Get.back(); // Details screen se back

      Get.snackbar(
        "Status Updated 🚀",
        "Your items have been marked as $newStatus",
        backgroundColor: Colors.cyanAccent,
        colorText: Colors.black,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(15),
      );

    } catch (e) {
      Get.back();
      Get.snackbar("Error", e.toString(), backgroundColor: Colors.redAccent, colorText: Colors.white);
      print("Update Error: $e");
    }
  }

}


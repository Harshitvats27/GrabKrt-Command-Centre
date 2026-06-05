import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class VendorDashboardController extends GetxController {
  static VendorDashboardController get instance => Get.find();

  final _db = FirebaseFirestore.instance;
  final String currentVendorId = FirebaseAuth.instance.currentUser?.uid ?? '';

  // Observables for Stats
  RxBool isLoading = false.obs;
  RxInt pendingOrdersCount = 0.obs;
  RxInt deliveredOrdersCount = 0.obs;
  RxInt totalProductsCount = 0.obs;

  // Observables for Lists
  RxList<Map<String, dynamic>> lowStockProducts = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> recentOrders = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    if (currentVendorId.isEmpty) return;

    try {
      isLoading.value = true;

      // 1. 🔥 FETCH PRODUCTS DATA & LOW STOCK ALERTS
      final productSnap = await _db.collection('Products').where('uploadedBy', isEqualTo: currentVendorId).get();

      totalProductsCount.value = productSnap.docs.length;
      List<Map<String, dynamic>> tempLowStock = [];

      for (var doc in productSnap.docs) {
        final data = doc.data();
        int stock = data['stock'] ?? 0;
        if (stock < 5) {
          tempLowStock.add({
            'id': doc.id,
            'title': data['title'] ?? 'Unknown',
            'stock': stock,
            'image': data['thumbnail'] ?? '',
          });
        }
      }
      lowStockProducts.assignAll(tempLowStock);

      // 2. 🔥 FETCH ORDERS DATA
      final orderSnapshot = await _db.collectionGroup('Orders').get();

      int pendingCount = 0;
      int deliveredCount = 0;
      List<Map<String, dynamic>> tempOrders = [];

      for (var doc in orderSnapshot.docs) {
        final orderData = doc.data() as Map<String, dynamic>;
        final List<dynamic> items = orderData['items'] ?? [];

        // Check if this vendor has items in this order
        List<dynamic> myItems = items.where((item) => item['uploadedBy'] == currentVendorId).toList();

        if (myItems.isNotEmpty) {
          String status = orderData['status'] ?? 'Pending';

          if (status == 'Delivered') {
            deliveredCount++;
          } else {
            pendingCount++; // Pending, Accepted, Packed, Shipped sab pending list me aayenge
          }

          tempOrders.add({
            'orderId': orderData['id'] ?? doc.id,
            'status': status,
            'orderDate': orderData['orderDate'],
            'itemCount': myItems.length,
          });
        }
      }

      pendingOrdersCount.value = pendingCount;
      deliveredOrdersCount.value = deliveredCount;

      // Sort recent orders and keep top 5
      tempOrders.sort((a, b) => (b['orderDate'] as Timestamp).compareTo(a['orderDate'] as Timestamp));
      recentOrders.assignAll(tempOrders.take(5).toList());

    } catch (e) {
      print("Dashboard Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
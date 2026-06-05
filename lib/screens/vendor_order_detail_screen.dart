import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vendor_order_controller.dart';
import '../utils/helpers/helper_function.dart';

class VendorOrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const VendorOrderDetailScreen({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    final isDark = UHelperfunctions.isDarkTheme(context);
    final List<dynamic> myItems = orderData['vendorItems'] ?? [];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
        title: const Text("Items To Pack", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.cyanAccent : Colors.black),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 👤 CUSTOMER INFORMATION CARD
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('Users').doc(orderData['userId']).get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Padding(padding: EdgeInsets.all(16), child: LinearProgressIndicator(color: Colors.cyanAccent));
              if (!snapshot.data!.exists) return const ListTile(title: Text("Customer details not found."));

              final userData = snapshot.data!.data() as Map<String, dynamic>;

              return Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("CUSTOMER DETAILS", style: TextStyle(color: isDark ? Colors.cyanAccent : Colors.blue, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
                    const SizedBox(height: 10),
                    Text("Name: ${userData['username'] ?? 'N/A'}", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text("Email: ${userData['email'] ?? 'N/A'}", style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
                    Text("Phone: ${userData['phone'] ?? 'N/A'}", style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
                  ],
                ),
              );
            },
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text("YOUR PRODUCTS IN THIS ORDER", style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          const SizedBox(height: 10),

          // 🛍️ PRODUCTS LIST (SIRF IS VENDOR KI)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: myItems.length,
              itemBuilder: (context, index) {
                final item = myItems[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDark ? Colors.cyanAccent.withOpacity(0.4) : Colors.grey.shade300),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: item['image'] != null
                              ? Image.network(item['image'], width: 70, height: 70, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image))
                              : const Icon(Icons.image, size: 70),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['title'] ?? 'Unknown Product', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
                              const SizedBox(height: 5),
                              Text("Quantity: ${item['quantity'] ?? 1}", style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13)),
                              Text("Price: ₹${item['price']}", style: TextStyle(color: isDark ? Colors.white54 : Colors.grey, fontSize: 13)),
                            ],
                          ),
                        ),
                        Text(
                          "₹${(item['price'] ?? 0.0) * (item['quantity'] ?? 1)}",
                          style: TextStyle(color: isDark ? Colors.cyanAccent : Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 🔥 FIXED BOTTOM NEON SUMMARY SHEET WITH STATUS UPDATER
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161616) : Colors.white,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              border: Border(top: BorderSide(color: isDark ? Colors.cyanAccent : Colors.grey.shade300, width: isDark ? 2 : 1)),
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("YOUR ORDER TOTAL", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("₹${orderData['vendorTotal']}", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 26, fontWeight: FontWeight.bold)),
                    ],
                  ),

                  // 🔥 UPDATE STATUS BUTTON
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.cyanAccent : Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: () {
                      _showStatusUpdateBottomSheet(context, isDark, orderData['orderId'], orderData['userId']);
                    },
                    child: Text("Update Status ⚡", style: TextStyle(color: isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 NEON BOTTOM SHEET FOR STATUS UPDATE
  // 🔥 NEON BOTTOM SHEET FOR STATUS UPDATE
  void _showStatusUpdateBottomSheet(BuildContext context, bool isDark, String orderId, String userId) {

    // 🔥 Yahan 'Accepted by Vendor' add kar diya hai
    List<String> vendorStatuses = ['Accepted by Vendor', 'Packed', 'Handed over to Delivery Boy'];

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          border: Border.all(color: isDark ? Colors.cyanAccent.withOpacity(0.5) : Colors.grey.shade300, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text("Update Order Status", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Generate list of statuses
            ...vendorStatuses.map((status) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                border: Border.all(color: isDark ? Colors.cyanAccent.withOpacity(0.3) : Colors.blue.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: Icon(Icons.check_circle_outline, color: isDark ? Colors.cyanAccent : Colors.blue),
                title: Text(status, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w600)),
                onTap: () {
                  Get.back(); // Pehle bottom sheet band karo
                  VendorOrderController.instance.updateOrderStatus(orderId, userId, status); // Call update
                },
              ),
            )).toList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
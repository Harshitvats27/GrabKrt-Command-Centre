import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/vendor_order_controller.dart';
import '../utils/helpers/helper_function.dart';
import 'vendor_order_detail_screen.dart';

class AllOrdersScreen extends StatelessWidget {
  const AllOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VendorOrderController());
    final isDark = UHelperfunctions.isDarkTheme(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
        title: Text("My Incoming Orders", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.cyanAccent : Colors.black),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CupertinoActivityIndicator(color: Colors.cyanAccent));
        }

        if (controller.vendorOrders.isEmpty) {
          return Center(child: Text('No orders found for your products.', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 16)));
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchVendorOrders(),
          color: Colors.cyanAccent,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.vendorOrders.length,
            itemBuilder: (context, index) {
              final order = controller.vendorOrders[index];

              // Date formatting
              DateTime orderDate = (order['orderDate'] as Timestamp).toDate();
              String formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(orderDate);

              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                decoration: _cardDecoration(isDark),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

                  // Icon badge based on status
                  leading: CircleAvatar(
                    backgroundColor: isDark ? const Color(0xFF222222) : Colors.grey[200],
                    child: Icon(
                        Icons.shopping_bag,
                        color: order['status'] == 'Pending' ? Colors.amber : Colors.greenAccent
                    ),
                  ),

                  // Order Details
                  title: Text(
                    "Order ID: ${order['orderId']}",
                    style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text("Date: $formattedDate", style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 13)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: order['status'] == 'Pending' ? Colors.amber.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          order['status'].toString().toUpperCase(),
                          style: TextStyle(color: order['status'] == 'Pending' ? Colors.amber : Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  // Vendor specific billing earnings
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "₹${order['vendorTotal']}",
                        style: TextStyle(color: isDark ? Colors.cyanAccent : Colors.green, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward_ios, color: isDark ? Colors.cyanAccent : Colors.grey, size: 16),
                    ],
                  ),

                  // 👉 Order details par bhejo click karne par
                  onTap: () {
                    Get.to(() => VendorOrderDetailScreen(orderData: order));
                  },
                ),
              );
            },
          ),
        );
      }),
    );
  }

  BoxDecoration _cardDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: isDark ? Colors.cyanAccent.withOpacity(0.8) : Colors.grey.shade300, width: isDark ? 1.5 : 1.0),
      boxShadow: isDark
          ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.6), blurRadius: 20, spreadRadius: 2)]
          : [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
    );
  }
}
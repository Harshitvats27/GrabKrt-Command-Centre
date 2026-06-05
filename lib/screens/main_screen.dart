import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/vendor_dashboard_controller.dart';
import '../utils/helpers/helper_function.dart';

// 🔥 TERI SCREENS IMPORT KAR LI HAIN
import '../widgets/drawer_widget.dart';
import 'add_product_screen.dart';
import 'all_order_screen.dart';
import 'vendor_product_screen.dart';
import 'upload_promo_codes.dart';
 // TERA NAYA DRAWER IMPORT

class VendorDashboardScreen extends StatelessWidget {
  const VendorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VendorDashboardController());
    final isDark = UHelperfunctions.isDarkTheme(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],

      // 🚀 MASTERSTROKE: DRAWER YAHAN CONNECT HUA
      drawer: const DrawerWidget(),

      appBar: AppBar(
        title: Text("Command Center", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // AppBar me icon color theek kiya taaki hamburger menu chamke
        iconTheme: IconThemeData(color: isDark ? Colors.cyanAccent : Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: isDark ? Colors.cyanAccent : Colors.blue),
            onPressed: () => controller.fetchDashboardData(),
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
        }

        return RefreshIndicator(
          color: Colors.cyanAccent,
          onRefresh: () => controller.fetchDashboardData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // 1. 🔥 NEON STATS GRID (NOW CLICKABLE!)
                Row(
                  children: [
                    // Click karne par Orders screen khulegi
                    Expanded(child: _buildStatCard("Pending", controller.pendingOrdersCount.value.toString(), Icons.hourglass_top, Colors.amber, isDark, () => Get.to(() => const AllOrdersScreen()))),
                    const SizedBox(width: 10),
                    // Click karne par Orders screen khulegi
                    Expanded(child: _buildStatCard("Delivered", controller.deliveredOrdersCount.value.toString(), Icons.check_circle_outline, Colors.greenAccent, isDark, () => Get.to(() => const AllOrdersScreen()))),
                    const SizedBox(width: 10),
                    // Click karne par Products screen khulegi
                    Expanded(child: _buildStatCard("Products", controller.totalProductsCount.value.toString(), Icons.inventory_2_outlined, Colors.cyanAccent, isDark, () => Get.to(() => VendorProductsScreen()))),
                  ],
                ),
                const SizedBox(height: 30),

                // 2. 🔥 QUICK ACTIONS (UNCOMMENTED ROUTING)
                Text("QUICK ACTIONS", style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildActionButton("Add Product", Icons.add_box, Colors.cyanAccent, isDark, () { Get.to(() =>  AddProductScreen()); }),
                    _buildActionButton("Promo", Icons.local_offer, Colors.pinkAccent, isDark, () { Get.to(() => AddPromoCodeScreen()); }),
                    _buildActionButton("Orders", Icons.list_alt, Colors.orangeAccent, isDark, () { Get.to(() => const AllOrdersScreen()); }),
                  ],
                ),
                const SizedBox(height: 30),

                // 3. 🔥 INVENTORY HEALTH (CLICKABLE STOCK ALERTS)
                if (controller.lowStockProducts.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                      const SizedBox(width: 8),
                      Text("LOW STOCK ALERTS", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.lowStockProducts.length,
                      itemBuilder: (context, index) {
                        final product = controller.lowStockProducts[index];
                        bool isCritical = product['stock'] == 0;
                        return GestureDetector(
                          onTap: () {
                            // 🔥 Yahan click karke user seedha Products page par ja sakta hai stock update karne
                            Get.to(() =>  VendorProductsScreen());
                          },
                          child: Container(
                            width: 250,
                            margin: const EdgeInsets.only(right: 15),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: isCritical ? Colors.redAccent : Colors.amber, width: 1.5),
                              boxShadow: isDark ? [BoxShadow(color: (isCritical ? Colors.redAccent : Colors.amber).withOpacity(0.4), blurRadius: 10)] : [],
                            ),
                            child: Row(
                              children: [
                                ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(product['image'], width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.image))),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(product['title'], style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      Text("Stock: ${product['stock']}", style: TextStyle(color: isCritical ? Colors.redAccent : Colors.amber, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                ],

                // 4. 🔥 RECENT INCOMING ORDERS
                Text("RECENT ORDERS", style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 15),
                if (controller.recentOrders.isEmpty)
                  Center(child: Padding(padding: const EdgeInsets.all(20), child: Text("No recent orders.", style: TextStyle(color: isDark ? Colors.white54 : Colors.black54))))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.recentOrders.length,
                    itemBuilder: (context, index) {
                      final order = controller.recentOrders[index];
                      DateTime date = (order['orderDate'] as Timestamp).toDate();
                      String formattedDate = DateFormat('dd MMM, hh:mm a').format(date);
                      bool isPending = order['status'] != 'Delivered';

                      return GestureDetector(
                        onTap: () {
                          // 🔥 Recent order pe click karte hi All Orders screen khulegi
                          Get.to(() => const AllOrdersScreen());
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: isDark ? Colors.cyanAccent.withOpacity(0.3) : Colors.grey.shade300),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.shopping_bag, color: isPending ? Colors.cyanAccent : Colors.greenAccent),
                            title: Text("Order ID: ${order['orderId']}", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis),
                            subtitle: Text("$formattedDate • ${order['itemCount']} Items", style: TextStyle(color: isDark ? Colors.white54 : Colors.grey, fontSize: 11)),
                            trailing: Text(order['status'], style: TextStyle(color: isPending ? Colors.amber : Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // --- UI WIDGET HELPERS (UPDATED W/ GESTURE DETECTOR) ---

  Widget _buildStatCard(String title, String count, IconData icon, Color neonColor, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap, // 🔥 Ab cards tap ho sakte hain
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: neonColor.withOpacity(isDark ? 0.8 : 0.4), width: 1.5),
          boxShadow: isDark ? [BoxShadow(color: neonColor.withOpacity(0.4), blurRadius: 15, spreadRadius: 1)] : [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5)],
        ),
        child: Column(
          children: [
            Icon(icon, color: neonColor, size: 28),
            const SizedBox(height: 10),
            Text(count, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(title, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              border: Border.all(color: color.withOpacity(0.8), width: 1.5),
              boxShadow: isDark ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 15)] : [],
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
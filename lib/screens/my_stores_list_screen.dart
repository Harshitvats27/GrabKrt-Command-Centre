import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/store_controller.dart';
import '../utils/helpers/helper_function.dart'; // Apna helper import kar
import 'add_store_screen.dart';
class MyStoresListScreen extends StatelessWidget {
  const MyStoresListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final storeController = Get.put(StoreController());
    final isDark = UHelperfunctions.isDarkTheme(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('My Stores', style: TextStyle(color: isDark ? Colors.cyanAccent : Colors.black, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: isDark ? Colors.cyanAccent : Colors.black),
      ),
      body: Obx(() {
        if (storeController.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: isDark ? Colors.cyanAccent : Colors.blue));
        }

        return Column(
          children: [
            // 🔥 PREMIUM NEON SEARCH BAR
            Container(
              margin: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? Colors.cyanAccent.withOpacity(0.8) : Colors.grey.shade300, width: isDark ? 1.5 : 1.0),
                boxShadow: isDark ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.2), blurRadius: 10)] : [BoxShadow(color: Colors.blue.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: TextField(
                onChanged: (value) => storeController.searchStore(value), // 🔥 Live Search trigger
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: isDark ? Colors.cyanAccent : Colors.grey),
                  hintText: "Search store by name...",
                  hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.grey[600]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ),

            // 🔥 STORES LIST
            Expanded(
              child: storeController.filteredStores.isEmpty
                  ? Center(
                child: Text("No stores found.", style: TextStyle(color: isDark ? Colors.grey : Colors.black54, fontSize: 16)),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                itemCount: storeController.filteredStores.length, // 🔥 Filtered list use ki hai
                itemBuilder: (context, index) {
                  final store = storeController.filteredStores[index]; // 🔥 Filtered list
                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: store.isActive
                            ? (isDark ? Colors.cyanAccent.withOpacity(0.5) : Colors.blue.withOpacity(0.5))
                            : Colors.red.withOpacity(0.3),
                        width: isDark ? 1.5 : 1.0,
                      ),
                      boxShadow: isDark ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.1), blurRadius: 10)] : [BoxShadow(color: Colors.blue.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(15),
                      leading: CircleAvatar(
                        backgroundColor: isDark ? Colors.black : Colors.blue.withOpacity(0.1),
                        child: Icon(Icons.store, color: store.isActive ? (isDark ? Colors.cyanAccent : Colors.blue) : Colors.red),
                      ),
                      title: Text(store.storeName, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Text("Owner: ${store.ownerName} | Ph: ${store.phoneNumber}", style: TextStyle(color: isDark ? Colors.grey : Colors.grey[700], fontSize: 13)),
                          const SizedBox(height: 5),
                          Text(
                            store.address,
                            style: TextStyle(color: isDark ? Colors.cyanAccent.withOpacity(0.7) : Colors.blueGrey, fontSize: 12),
                            maxLines: 2, overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      trailing: Transform.scale(
                        scale: 0.9,
                        child: Switch(
                          value: store.isActive,
                          activeColor: isDark ? Colors.cyanAccent : Colors.blue,
                          activeTrackColor: (isDark ? Colors.cyanAccent : Colors.blue).withOpacity(0.4),
                          inactiveThumbColor: Colors.grey.shade400,
                          inactiveTrackColor: Colors.grey.shade800,
                          onChanged: (val) {
                            storeController.toggleStoreStatus(store.id, store.isActive);
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: isDark ? Colors.black : Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30), side: BorderSide(color: isDark ? Colors.cyanAccent : Colors.transparent, width: 1.5)),
        icon: Icon(Icons.add, color: isDark ? Colors.cyanAccent : Colors.white),
        label: Text("Add Store", style: TextStyle(color: isDark ? Colors.cyanAccent : Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => Get.to(() => const AddStoreScreen()),
      ),
    );
  }
}
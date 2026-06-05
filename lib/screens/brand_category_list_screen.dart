import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/helpers/helper_function.dart';
import '../utils/snackbar_helpers.dart';
import '../controllers/brand_category_controller.dart';
import 'brand_category_screen.dart';
import 'edit_brand_category_screen.dart';

class BrandCategoryListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Get.put(BrandCategoryController());
    final isDark = UHelperfunctions.isDarkTheme(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
        title: Text("Linked Categories", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 15, top: 8, bottom: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: isDark ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.6), blurRadius: 12, spreadRadius: 2)] : [],
            ),
            child: IconButton(
              icon: Icon(Icons.add_circle, color: isDark ? Colors.cyanAccent : Colors.blueAccent, size: 30),
              onPressed: () => Get.to(() => AddBrandCategoryScreen()),
            ),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('BrandCategory').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return _buildShimmerLoading(isDark);
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Center(child: Text("No mappings found.", style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)));

          final mappings = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: mappings.length,
            itemBuilder: (context, index) {
              final doc = mappings[index];
              final brandId = doc['brandId'] ?? 'Unknown Brand';
              final categoryId = doc['categoryId'] ?? 'Unknown Category';

              return Dismissible(
                key: Key(doc.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  BrandCategoryController.instance.deleteMapping(doc.id);
                  return false; // Dialog handle karega delete ko
                },
                background: _buildSwipeBackground(),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: _cardDecoration(isDark),
                  child: ListTile(
                    onTap: () {
                      final c = BrandCategoryController.instance;
                      c.loadEditData(doc.id, brandId, categoryId);
                      Get.to(() => const EditBrandCategoryScreen());
                    },
                    title: Text("Brand ID: $brandId", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                    subtitle: Text("Category ID: $categoryId", style: TextStyle(color: isDark ? Colors.cyanAccent : Colors.blue)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSwipeBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(20)),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Icon(Icons.delete_sweep, color: Colors.white, size: 35),
    );
  }

  // (Include _cardDecoration and _buildShimmerLoading same as before)
  BoxDecoration _cardDecoration(bool isDark) { /*... Same Code ...*/ return BoxDecoration( color: isDark ? const Color(0xFF1A1A1A) : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all( color: isDark ? Colors.cyanAccent.withOpacity(0.8) : Colors.grey.shade300, width: isDark ? 1.5 : 1.0, ), boxShadow: isDark ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.6), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 0))] : [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))], ); }
  Widget _buildShimmerLoading(bool isDark) { /*... Same Code ...*/ return ListView.builder( padding: const EdgeInsets.all(16), itemCount: 5, itemBuilder: (context, index) { return Shimmer.fromColors( baseColor: isDark ? Colors.grey[850]! : Colors.grey[300]!, highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!, child: Container( margin: const EdgeInsets.only(bottom: 15), height: 70, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)), ), ); }, ); }
}
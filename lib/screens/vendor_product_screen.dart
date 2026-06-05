import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../models/product_model.dart';
import '../utils/helpers/helper_function.dart';
import '../utils/snackbar_helpers.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';

class VendorProductsScreen extends StatelessWidget {

  Future<void> deleteProduct(String productId) async {
    Get.defaultDialog(
        title: "Delete Product",
        middleText: "Are you sure you want to permanently delete this product?",
        textConfirm: "Delete", textCancel: "Cancel",
        confirmTextColor: Colors.white, buttonColor: Colors.redAccent, cancelTextColor: Colors.cyanAccent,
        backgroundColor: const Color(0xFF1E1E1E), titleStyle: const TextStyle(color: Colors.white), middleTextStyle: const TextStyle(color: Colors.white70),
        onConfirm: () async {
          Get.back();
          Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
          try {
            await FirebaseFirestore.instance.collection('Products').doc(productId).delete();
            final mappings = await FirebaseFirestore.instance.collection('ProductCategory').where('productId', isEqualTo: productId).get();
            for(var doc in mappings.docs) { await doc.reference.delete(); }
            Get.back();
            USnackBarHelpers.successSnackBar(title: 'Deleted', message: 'Product has been removed.');
          } catch (e) {
            Get.back();
            USnackBarHelpers.errorSnackBar(title: 'Error', message: e.toString());
          }
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isDark = UHelperfunctions.isDarkTheme(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        title: Text("My Products", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 15, top: 8, bottom: 8),
            decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [if (isDark) BoxShadow(color: Colors.cyanAccent.withOpacity(0.6), blurRadius: 12, spreadRadius: 2)]),
            child: IconButton(icon: Icon(Icons.add_circle, color: isDark ? Colors.cyanAccent : Colors.blueAccent, size: 30), onPressed: () => Get.to(() => AddProductScreen(), transition: Transition.rightToLeftWithFade)),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Products').where('uploadedBy', isEqualTo: currentUserId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return _buildShimmerLoading(isDark);
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Center(child: Text("No products added yet.", style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 18)));

          final products = snapshot.data!.docs.map((e) => ProductModel.fromSnapshot(e as DocumentSnapshot<Map<String, dynamic>>)).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Dismissible(
                key: Key(product.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  deleteProduct(product.id);
                  return false;
                },
                background: _buildSwipeBackground(),
                child: _buildNeonProductCard(product, isDark),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSwipeBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(20)),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Icon(Icons.delete_sweep, color: Colors.white, size: 35),
    );
  }

  Widget _buildNeonProductCard(ProductModel product, bool isDark) {
    return GestureDetector(
      onTap: () => Get.to(() => EditProductScreen(product: product)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16), // Adjusted to match margin inside Dismissible if needed
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? Colors.cyanAccent.withOpacity(0.8) : Colors.grey.shade300, width: isDark ? 1.5 : 1.0),
          boxShadow: isDark ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.6), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 0))] : [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          leading: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(product.thumbnail, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (c, e, s) => Icon(Icons.image, color: isDark ? Colors.white : Colors.black))),
          title: Text(product.title, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
          subtitle: Text("SKU: ${product.sku?.isNotEmpty == true ? product.sku : 'N/A'}  |  Stock: ${product.stock}\n₹${product.price}", style: TextStyle(color: isDark ? Colors.cyanAccent : Colors.green, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading(bool isDark) { /*... Same Code ...*/ return ListView.builder( padding: const EdgeInsets.all(16), itemCount: 5, itemBuilder: (context, index) { return Shimmer.fromColors( baseColor: isDark ? Colors.grey[850]! : Colors.grey[300]!, highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!, child: Container( margin: const EdgeInsets.only(bottom: 16), height: 90, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)), ), ); }, ); }
}
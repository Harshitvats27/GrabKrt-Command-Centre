import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_admin/screens/upload_promo_codes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/promo_code_model.dart';
import '../utils/helpers/helper_function.dart';
import '../utils/snackbar_helpers.dart';
import 'edit_promo_screen.dart';

class PromoCodeListScreen extends StatelessWidget {
  Future<void> deletePromo(String promoId) async {
    Get.defaultDialog(
        title: "Delete Promo",
        middleText: "Are you sure you want to delete this promo code?",
        textConfirm: "Delete", textCancel: "Cancel",
        buttonColor: Colors.redAccent, confirmTextColor: Colors.white, cancelTextColor: Colors.cyanAccent,
        backgroundColor: const Color(0xFF1E1E1E), titleStyle: const TextStyle(color: Colors.white), middleTextStyle: const TextStyle(color: Colors.white70),
        onConfirm: () async {
          Get.back();
          try {
            await FirebaseFirestore.instance.collection('PromoCodes').doc(promoId).delete();
            USnackBarHelpers.successSnackBar(title: "Deleted", message: "Promo code removed.");
          } catch (e) {}
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = UHelperfunctions.isDarkTheme(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
          title: Text("Promo Codes", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent, elevation: 0,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 15, top: 8, bottom: 8),
              decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: isDark ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.6), blurRadius: 12, spreadRadius: 2)] : []),
              child: IconButton(icon: Icon(Icons.add_circle, color: isDark ? Colors.cyanAccent : Colors.blueAccent, size: 30), onPressed: () => Get.to(() => AddPromoCodeScreen())),
            ),
          ]
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('PromoCodes').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final promos = snapshot.data!.docs.map((e) => PromoCodeModel.fromSnapshot(e)).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: promos.length,
            itemBuilder: (context, index) {
              final promo = promos[index];
              return Dismissible(
                key: Key(promo.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  deletePromo(promo.id);
                  return false;
                },
                background: _buildSwipeBackground(),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: _cardDecoration(isDark),
                  child: ListTile(
                    onTap: () => Get.to(() => EditPromoScreen(promo: promo)),
                    title: Text(promo.code, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                    subtitle: Text("${promo.name} | ${promo.discount} ${promo.discountType?.name ?? ''}"),
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

  BoxDecoration _cardDecoration(bool isDark) { /*... Same Code ...*/ return BoxDecoration( color: isDark ? const Color(0xFF1A1A1A) : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all( color: isDark ? Colors.cyanAccent.withOpacity(0.8) : Colors.grey.shade300, width: isDark ? 1.5 : 1.0, ), boxShadow: isDark ? [ BoxShadow( color: Colors.cyanAccent.withOpacity(0.6), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 0) ) ] : [ BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)), ], ); }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/promo_code_controller.dart';
import '../models/promo_code_model.dart';
import '../utils/enums.dart';
import '../utils/helpers/helper_function.dart';

class EditPromoScreen extends StatelessWidget {
  final PromoCodeModel promo;
  EditPromoScreen({required this.promo});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PromoCodeController());
    controller.loadPromoData(promo);
    final isDark = UHelperfunctions.isDarkTheme(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
        title: Text("Edit Promo", style: TextStyle(color: isDark ? Colors.cyanAccent : Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.cyanAccent : Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 🔥 DISCOUNT TYPE TOP PAR
            Obx(() => _buildProDropdown(
              hint: "Discount Type",
              value: controller.selectedType.value,
              items: DiscountType.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name.capitalize!))).toList(),
              onChanged: (val) => controller.selectedType.value = val!,
              isDark: isDark,
            )),
            const SizedBox(height: 15),

            _buildProInput(controller.nameController, "Promo Name", Icons.label, isDark),
            const SizedBox(height: 15),
            _buildProInput(controller.codeController, "Code", Icons.qr_code, isDark),
            const SizedBox(height: 15),
            _buildProInput(controller.discountController, "Discount Value", Icons.percent, isDark, isNumber: true),
            const SizedBox(height: 15),
            _buildProInput(controller.minOrderController, "Min Order Price", Icons.attach_money, isDark, isNumber: true),
            const SizedBox(height: 15),
            _buildProInput(controller.countController, "Usage Count", Icons.numbers, isDark, isNumber: true),

            const SizedBox(height: 20),
            Container(
              decoration: _cardDecoration(isDark),
              child: Obx(() => SwitchListTile(
                title: Text("Active Status", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                value: controller.isActive.value,
                onChanged: (val) => controller.isActive.value = val,
                activeColor: Colors.cyanAccent,
              )),
            ),

            const SizedBox(height: 30),

            Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: isDark ? Colors.cyanAccent.withOpacity(0.4) : Colors.blue.withOpacity(0.3), blurRadius: 15)
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.cyanAccent : Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () => controller.updatePromoCode(promo.id),
                child: Text("Save Changes", style: TextStyle(fontSize: 18, color: isDark ? Colors.black : Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- REUSABLE NEON COMPONENTS ---
  BoxDecoration _cardDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isDark ? Colors.cyanAccent.withOpacity(0.8) : Colors.grey.shade300,
        width: isDark ? 1.5 : 1.0,
      ),
      boxShadow: isDark
          ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.6), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 0))]
          : [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
    );
  }

  Widget _buildProInput(TextEditingController ctrl, String label, IconData icon, bool isDark, {bool isNumber = false}) {
    return Container(
      decoration: _cardDecoration(isDark),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: isDark ? Colors.cyanAccent : Colors.grey),
          labelText: label,
          labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: isDark ? Colors.cyanAccent : Colors.blue, width: 2)),
          filled: true, fillColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildProDropdown<T>({required T? value, required String hint, required List<DropdownMenuItem<T>> items, required void Function(T?)? onChanged, required bool isDark}) {
    return Container(
      decoration: _cardDecoration(isDark),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonFormField<T>(
        decoration: const InputDecoration(border: InputBorder.none),
        dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16),
        value: value,
        hint: Text(hint, style: TextStyle(color: isDark ? Colors.white54 : Colors.grey[600])),
        items: items,
        onChanged: onChanged,
        iconEnabledColor: isDark ? Colors.cyanAccent : Colors.grey,
      ),
    );
  }
}
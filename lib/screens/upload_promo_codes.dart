import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/promo_code_controller.dart';
import '../utils/enums.dart';
import '../utils/helpers/helper_function.dart';

class AddPromoCodeScreen extends StatelessWidget {
  final controller = Get.put(PromoCodeController());

  @override
  Widget build(BuildContext context) {
    final isDark = UHelperfunctions.isDarkTheme(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
        title: Text("Add Promo Code", style: TextStyle(color: isDark ? Colors.cyanAccent : Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.cyanAccent : Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProInput(controller.nameController, "Promo Name", Icons.label, isDark),
            const SizedBox(height: 15),
            _buildProInput(controller.codeController, "Promo Code (e.g. SAVE20)", Icons.qr_code, isDark),
            const SizedBox(height: 15),
            _buildProInput(controller.discountController, "Discount Amount", Icons.percent, isDark, isNumber: true),

            const SizedBox(height: 20),
            Obx(() => _buildProDropdown(
              hint: "Discount Type",
              value: controller.selectedType.value,
              items: DiscountType.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name.toUpperCase()))).toList(),
              onChanged: (val) => controller.selectedType.value = val!,
              isDark: isDark,
            )),

            const SizedBox(height: 20),
            // Date Pickers (Neon Style)
            _buildDateTile("Select Start Date", controller.startDate, context, isDark),
            _buildDateTile("Select End Date (Optional)", controller.endDate, context, isDark),

            const SizedBox(height: 20),
            _buildProInput(controller.minOrderController, "Min Order Price", Icons.attach_money, isDark, isNumber: true),
            const SizedBox(height: 15),
            _buildProInput(controller.countController, "Max Usage Count", Icons.numbers, isDark, isNumber: true),

            const SizedBox(height: 40),

            // 🔥 UPLOAD BUTTON
            Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: isDark ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.5), blurRadius: 15)] : [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.cyanAccent : Colors.blue,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {
                  // Calls the function which now has strict validation logic
                  controller.uploadPromoCode();
                },
                child: Text("Upload Promo 🚀", style: TextStyle(color: isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- REUSABLE NEON WIDGETS ---
  Widget _buildDateTile(String label, Rx<DateTime?> date, BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: _cardDecoration(isDark),
      child: Obx(() => ListTile(
        title: Text(date.value == null ? label : date.value.toString().split(' ')[0],
            style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: date.value == null ? FontWeight.normal : FontWeight.bold)),
        trailing: Icon(Icons.calendar_today, color: isDark ? Colors.cyanAccent : Colors.grey),
        onTap: () async {
          DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
          if(picked != null) date.value = picked;
        },
      )),
    );
  }

  BoxDecoration _cardDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: isDark ? Colors.cyanAccent.withOpacity(0.8) : Colors.grey.shade300, width: isDark ? 1.5 : 1.0),
      boxShadow: isDark ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.6), blurRadius: 20, spreadRadius: 2)] : [],
    );
  }

  Widget _buildProInput(TextEditingController controller, String hint, IconData icon, bool isDark, {bool isNumber = false, int maxLines = 1}) {
    return Container(
      decoration: _cardDecoration(isDark),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : (maxLines > 1 ? TextInputType.multiline : TextInputType.text),
        textInputAction: maxLines > 1 ? TextInputAction.newline : TextInputAction.done,
        maxLines: maxLines,
        minLines: maxLines > 1 ? 3 : 1,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: isDark ? Colors.cyanAccent : Colors.grey),
          labelText: hint,
          labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.grey[600]),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: isDark ? Colors.cyanAccent : Colors.blue, width: 2),
          ),
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
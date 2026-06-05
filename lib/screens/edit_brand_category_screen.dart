import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/brand_category_controller.dart';
import '../models/brand_model.dart';
import '../models/categories_model.dart';
import '../utils/helpers/helper_function.dart';

class EditBrandCategoryScreen extends StatelessWidget {
  const EditBrandCategoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = UHelperfunctions.isDarkTheme(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
        title: Text("Edit Link", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.cyanAccent : Colors.black),
      ),
      body: GetBuilder<BrandCategoryController>(
        builder: (c) {
          if (c.brandList.isEmpty || c.categoryList.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("Update Brand", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.cyanAccent : Colors.black)),
                const SizedBox(height: 10),

                // 🔥 NEON BRAND DROPDOWN (Editing 'editSelectedBrand')
                _buildProDropdown<BrandModel>(
                  hint: "Choose a Brand",
                  value: c.editSelectedBrand,
                  items: c.brandList.map((brand) => DropdownMenuItem(value: brand, child: Text(brand.name))).toList(),
                  onChanged: (val) { c.editSelectedBrand = val; c.update(); },
                  isDark: isDark,
                ),

                const SizedBox(height: 30),

                Text("Update Parent Category", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.cyanAccent : Colors.black)),
                const SizedBox(height: 10),

                // 🔥 NEON CATEGORY DROPDOWN (Editing 'editSelectedCategory')
                _buildProDropdown<CategoryModel>(
                  hint: "Choose Parent Category",
                  value: c.editSelectedCategory,
                  items: c.categoryList.map((cat) => DropdownMenuItem(value: cat, child: Text(cat.name))).toList(),
                  onChanged: (val) { c.editSelectedCategory = val; c.update(); },
                  isDark: isDark,
                ),

                const Spacer(),

                // 🔥 SAVE BUTTON
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      if (isDark) BoxShadow(color: Colors.cyanAccent.withOpacity(0.6), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 0)),
                      if (!isDark) BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.cyanAccent : Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: c.updateMapping, // Call update logic
                    child: Text("Update Mapping 🚀", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.black : Colors.white)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
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
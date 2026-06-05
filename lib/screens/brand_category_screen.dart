import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/brand_category_controller.dart';
import '../models/brand_model.dart';
import '../utils/helpers/helper_function.dart';

class AddBrandCategoryScreen extends StatelessWidget {
  final controller = Get.put(BrandCategoryController());

  @override
  Widget build(BuildContext context) {
    final isDark = UHelperfunctions.isDarkTheme(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
        title: Text("Link Brand & Categories", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.cyanAccent : Colors.black),
      ),
      body: GetBuilder<BrandCategoryController>(
        builder: (c) {
          // 🔥 SIRF PARENT CATEGORY FILTER LOGIC
          final parentCategories = c.categoryList.where((cat) => cat.parentId == null || cat.parentId!.isEmpty).toList();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("1. Select Brand", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.cyanAccent : Colors.black)),
                const SizedBox(height: 10),

                /// 🔥 NEON BRAND DROPDOWN
                Container(
                  decoration: _cardDecoration(isDark),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: DropdownButtonFormField<BrandModel>(
                    decoration: const InputDecoration(border: InputBorder.none),
                    dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16),
                    hint: Text("Choose a Brand", style: TextStyle(color: isDark ? Colors.white54 : Colors.grey[600])),
                    iconEnabledColor: isDark ? Colors.cyanAccent : Colors.grey,
                    value: c.selectedBrand,
                    items: c.brandList.map((brand) {
                      return DropdownMenuItem(value: brand, child: Text(brand.name));
                    }).toList(),
                    onChanged: (val) {
                      c.selectedBrand = val;
                      c.update();
                    },
                  ),
                ),

                const SizedBox(height: 30),
                Divider(color: isDark ? Colors.white24 : Colors.grey.shade300),
                const SizedBox(height: 10),

                Text("2. Select Main Categories (Parent Only)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.cyanAccent : Colors.black)),
                const SizedBox(height: 15),

                /// 🔥 MULTI-SELECT CATEGORY CHIPS (NEON STYLE)
                c.categoryList.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: parentCategories.map((category) {
                    bool isSelected = c.selectedCategories.contains(category);
                    return FilterChip(
                      label: Text(category.name, style: TextStyle(color: isSelected ? (isDark ? Colors.black : Colors.white) : (isDark ? Colors.white : Colors.black))),
                      selected: isSelected,
                      backgroundColor: isDark ? Colors.grey[850] : Colors.grey[200],
                      selectedColor: isDark ? Colors.cyanAccent : Colors.blue,
                      checkmarkColor: isDark ? Colors.black : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: isDark ? Colors.cyanAccent.withOpacity(0.5) : Colors.transparent),
                      ),
                      onSelected: (bool value) {
                        c.toggleCategorySelection(category);
                      },
                    );
                  }).toList(),
                ),

                const Spacer(),

                /// 🔥 SAVE BUTTON (NEON)
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
                    onPressed: c.saveBrandCategoryMapping,
                    child: Text("Save Mapping 🚀", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.black : Colors.white)),
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

  // 🔥 EXTREME NEON DECORATION
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
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/upload_products_controller.dart';
import '../models/StoreModel.dart';
import '../models/brand_model.dart';
import '../models/categories_model.dart';
// 🔥 STORE MODEL IMPORT KAREN (Apna path check kar lena)
import '../utils/helpers/helper_function.dart';

class AddProductScreen extends StatelessWidget {
  final controller = Get.put(AdminProductController());

  @override
  Widget build(BuildContext context) {
    final isDark = UHelperfunctions.isDarkTheme(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.cyanAccent : Colors.black),
        title: Text(
          "Add Product",
          style: TextStyle(color: isDark ? Colors.cyanAccent : Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: GetBuilder<AdminProductController>(
        builder: (c) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProInput(c.titleController, "Product Title", Icons.title, isDark),
              const SizedBox(height: 15),
              _buildProInput(c.skuController, "Product SKU (e.g. ABR4568)", Icons.qr_code, isDark),

              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildProInput(c.priceController, "Original Price", Icons.attach_money, isDark, isNumber: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildProInput(c.salePriceController, "Sale Price (Optional)", Icons.local_offer, isDark, isNumber: true)),
                ],
              ),

              const SizedBox(height: 15),
              _buildProInput(c.stockController, "Base Stock", Icons.inventory_2, isDark, isNumber: true),
              const SizedBox(height: 15),
              _buildProInput(c.descriptionController, "Description", Icons.description, isDark, maxLines: 3),

              const SizedBox(height: 20),

              /// IS FEATURED TOGGLE
              Container(
                decoration: _cardDecoration(isDark),
                child: SwitchListTile(
                  activeColor: isDark ? Colors.cyanAccent : Colors.blue,
                  activeTrackColor: isDark ? Colors.cyan.withOpacity(0.3) : Colors.blue.withOpacity(0.3),
                  title: Text("Is Featured Product?", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w600)),
                  value: c.isFeatured,
                  onChanged: (val) {
                    c.isFeatured = val;
                    c.update();
                  },
                ),
              ),

              const SizedBox(height: 20),

              /// THUMBNAIL (MAIN IMAGE)
              Text("Thumbnail Image (Main Face)", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.cyanAccent : Colors.black87, fontSize: 16)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: _cardDecoration(isDark),
                child: c.thumbnailImage == null
                    ? _buildActionButton("Pick Thumbnail", Icons.image, c.pickThumbnail, isDark)
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(c.thumbnailImage!, height: 120, width: 120, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: c.pickThumbnail,
                      icon: Icon(Icons.edit, color: isDark ? Colors.cyanAccent : Colors.blue),
                      label: Text("Change Thumbnail", style: TextStyle(color: isDark ? Colors.cyanAccent : Colors.blue)),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// 🔥 NEW SECTION: STORE SELECTION
              Text("Store Assignment", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.cyanAccent : Colors.black87, fontSize: 16)),
              const SizedBox(height: 10),

              _buildProDropdown<StoreModel>(
                hint: c.activeStoresList.isEmpty ? "No Active Stores Found! Add/Enable a store first." : "Select Store",
                value: c.selectedStore,
                items: c.activeStoresList.map((store) => DropdownMenuItem(value: store, child: Text(store.storeName))).toList(),
                onChanged: c.activeStoresList.isEmpty ? null : (value) {
                  c.selectedStore = value;
                  c.update();
                },
                isDark: isDark,
              ),

              const SizedBox(height: 20),

              /// BRANDS & CATEGORIES
              Text("Categorization", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.cyanAccent : Colors.black87, fontSize: 16)),
              const SizedBox(height: 10),

              _buildProDropdown<BrandModel>(
                hint: "Select Brand",
                value: c.selectedBrand,
                items: c.brandList.map((b) => DropdownMenuItem(value: b, child: Text(b.name))).toList(),
                onChanged: (value) => c.selectedBrand = value,
                isDark: isDark,
              ),
              const SizedBox(height: 10),

              _buildProDropdown<CategoryModel>(
                hint: "Select Main Category",
                value: c.selectedMainCategory,
                items: c.mainCategoryList.map((cat) => DropdownMenuItem(value: cat, child: Text(cat.name))).toList(),
                onChanged: (value) => c.onMainCategoryChanged(value),
                isDark: isDark,
              ),
              const SizedBox(height: 10),

              if (c.selectedMainCategory != null)
                _buildProDropdown<CategoryModel>(
                  hint: c.subCategoryList.isEmpty ? "No Subcategories Found" : "Select Subcategory",
                  value: c.selectedSubCategory,
                  items: c.subCategoryList.map((cat) => DropdownMenuItem(value: cat, child: Text(cat.name))).toList(),
                  onChanged: c.subCategoryList.isEmpty ? null : (value) {
                    c.selectedSubCategory = value;
                    c.update();
                  },
                  isDark: isDark,
                ),

              const SizedBox(height: 20),

              /// PRODUCT TYPE
              Text("Product Setup", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.cyanAccent : Colors.black87, fontSize: 16)),
              const SizedBox(height: 10),

              _buildProDropdown<String>(
                hint: "Product Type",
                value: c.productType,
                items: const [
                  DropdownMenuItem(value: 'ProductType.single', child: Text("Single Product")),
                  DropdownMenuItem(value: 'ProductType.variable', child: Text("Variable Product")),
                ],
                onChanged: (value) {
                  c.productType = value!;
                  c.update();
                },
                isDark: isDark,
              ),

              /// VARIABLE SECTION UI
              if (c.productType == 'ProductType.variable') ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _cardDecoration(isDark),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Attributes", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: c.attributes.map((a) => Chip(
                          backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                          labelStyle: TextStyle(color: isDark ? Colors.cyanAccent : Colors.black87),
                          label: Text("${a.name}: ${a.values?.join(', ')}"),
                        )).toList(),
                      ),
                      const SizedBox(height: 10),
                      _buildActionButton("Add Attribute", Icons.add, () => c.showAddAttributeDialog(context), isDark),

                      const Divider(height: 30),

                      Text("Variations", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                      const SizedBox(height: 10),
                      ...c.variations.map((v) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black45 : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? Colors.cyanAccent.withOpacity(0.3) : Colors.grey.shade300),
                        ),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(v.image, width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.image)),
                          ),
                          title: Text("SKU: ${v.sku} | Price: ₹${v.price}", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                          subtitle: Text(v.attributeValues.toString(), style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
                        ),
                      )).toList(),
                      const SizedBox(height: 10),
                      _buildActionButton("Add Variation Combo", Icons.add_photo_alternate, () => c.showAddVariationDialog(context), isDark),
                    ],
                  ),
                )
              ],

              const SizedBox(height: 40),

              /// UPLOAD BUTTON
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
                  onPressed: c.uploadProduct,
                  child: Text("Upload Product 🚀", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.black : Colors.white)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // --- REUSABLE UI COMPONENTS ---
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

  Widget _buildActionButton(String text, IconData icon, VoidCallback onPressed, bool isDark) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        side: BorderSide(color: isDark ? Colors.cyanAccent : Colors.blue),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        foregroundColor: isDark ? Colors.cyanAccent : Colors.blue,
      ),
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
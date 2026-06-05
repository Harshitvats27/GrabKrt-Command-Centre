import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/edit_product_controller.dart';
import '../models/product_model.dart';
import '../models/brand_model.dart';
import '../models/categories_model.dart';
import '../utils/helpers/helper_function.dart'; // 🔥 HELPER IMPORT

class EditProductScreen extends StatelessWidget {
  final ProductModel product;

  const EditProductScreen({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final c = Get.put(EditProductController(product: product), tag: product.id);
    final isDark = UHelperfunctions.isDarkTheme(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
        title: Text("Edit Master Product", style: TextStyle(color: isDark ? Colors.cyanAccent : Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.cyanAccent : Colors.black),
      ),
      body: GetBuilder<EditProductController>(
        tag: product.id,
        builder: (_) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// 🔥 THUMBNAIL EDIT SECTION
              Center(
                child: Stack(
                  children: [
                    Container(
                      height: 120, width: 120,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1A1A) : Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isDark ? Colors.cyanAccent : Colors.blue, width: 2),
                        boxShadow: isDark
                            ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.6), blurRadius: 20, spreadRadius: 2)]
                            : [BoxShadow(color: Colors.grey.shade300, blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: c.newThumbnail != null
                            ? Image.file(c.newThumbnail!, fit: BoxFit.cover)
                            : Image.network(c.existingThumbnail, fit: BoxFit.cover, errorBuilder: (ctx, e, s) => const Icon(Icons.image, size: 50)),
                      ),
                    ),
                    Positioned(
                      bottom: -10, right: -10,
                      child: IconButton(
                        onPressed: c.pickNewThumbnail,
                        icon: CircleAvatar(
                          backgroundColor: isDark ? Colors.cyanAccent : Colors.blue,
                          child: const Icon(Icons.edit, color: Colors.black, size: 20),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),

              _buildProInput(c.titleCtrl, "Product Title", Icons.title, isDark),
              const SizedBox(height: 15),
              _buildProInput(c.skuCtrl, "SKU", Icons.qr_code, isDark),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(child: _buildProInput(c.priceCtrl, "Price (₹)", Icons.currency_rupee, isDark, isNumber: true)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildProInput(c.salePriceCtrl, "Sale Price (₹)", Icons.local_offer, isDark, isNumber: true)),
                ],
              ),
              const SizedBox(height: 15),
              _buildProInput(c.stockCtrl, "Total Stock", Icons.inventory_2, isDark, isNumber: true),
              const SizedBox(height: 15),
              _buildProInput(c.descCtrl, "Description", Icons.description, isDark, maxLines: 4),
              const SizedBox(height: 20),

              /// 🔥 CATEGORIES & BRANDS
              Text("Categorization", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.cyanAccent : Colors.black87, fontSize: 16)),
              const SizedBox(height: 10),

              _buildProDropdown<BrandModel>(
                hint: "Select Brand",
                value: c.selectedBrand,
                items: c.brandList.map((b) => DropdownMenuItem(value: b, child: Text(b.name))).toList(),
                onChanged: (value) { c.selectedBrand = value; c.update(); },
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
                  onChanged: c.subCategoryList.isEmpty ? null : (value) { c.selectedSubCategory = value; c.update(); },
                  isDark: isDark,
                ),

              const SizedBox(height: 20),

              /// 🔥 PRODUCT TYPE & VARIATIONS
              Text("Product Setup", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.cyanAccent : Colors.black87, fontSize: 16)),
              const SizedBox(height: 10),

              _buildProDropdown<String>(
                hint: "Product Type",
                value: c.productType,
                items: const [
                  DropdownMenuItem(value: 'ProductType.single', child: Text("Single Product")),
                  DropdownMenuItem(value: 'ProductType.variable', child: Text("Variable Product")),
                ],
                onChanged: (value) { c.productType = value!; c.update(); },
                isDark: isDark,
              ),

              if (c.productType == 'ProductType.variable') ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _cardDecoration(isDark),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Existing Attributes", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10, runSpacing: 10,
                        children: c.attributes.map((a) => Chip(
                          backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                          labelStyle: TextStyle(color: isDark ? Colors.cyanAccent : Colors.black87),
                          label: Text("${a.name}: ${a.values?.join(', ')}"),
                        )).toList(),
                      ),
                      const SizedBox(height: 15),
                      _buildActionButton("Add Attribute", Icons.add, () => c.showAddAttributeDialog(context), isDark),
                      const Divider(height: 30),

                      Text("Existing Variations", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                      const SizedBox(height: 10),

                      // 🔥 YAHAN VARIATION LIST UPGRADE KI HAI SATH ME DELETE BUTTON
                      ...c.variations.asMap().entries.map((entry) {
                        int index = entry.key;
                        var v = entry.value;
                        return Container(
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
                            title: Text("SKU: ${v.sku} | ₹${v.price}", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                            subtitle: Text("Stock: ${v.stock} | ${v.attributeValues.toString()}", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => c.removeVariation(index), // Controller ko batana padega remove karne ke liye
                            ),
                          ),
                        );
                      }).toList(),

                      const SizedBox(height: 10),
                      _buildActionButton("Add Variation Combo", Icons.add_photo_alternate, () => c.showAddVariationDialog(context), isDark),
                    ],
                  ),
                )
              ],

              const SizedBox(height: 20),

              /// 🔥 TOGGLE FEATURED
              Container(
                decoration: _cardDecoration(isDark),
                child: SwitchListTile(
                  activeColor: isDark ? Colors.cyanAccent : Colors.blue,
                  title: Text("Featured Product", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                  value: c.isFeatured,
                  onChanged: (val) { c.isFeatured = val; c.update(); },
                ),
              ),

              const SizedBox(height: 40),

              /// 🔥 SAVE BUTTON
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
                  onPressed: c.updateProduct,
                  child: Text("Save All Changes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.black : Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- UI COMPONENTS ---
  // 🔥 EXTREME NEON GLOW DECORATION
  BoxDecoration _cardDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isDark ? Colors.cyanAccent.withOpacity(0.8) : Colors.transparent,
        width: isDark ? 1.5 : 1.0,
      ),
      boxShadow: isDark
          ? [
        BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.6),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 0)
        )
      ]
          : [
        BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 15, spreadRadius: 1, offset: const Offset(0, 4)),
      ],
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
          filled: true,
          fillColor: Colors.transparent,
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

  // 🔥 YEH FUNCTION AB CLASS KE ANDAR HAI, KABHI ERROR NAHI AAYEGA
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
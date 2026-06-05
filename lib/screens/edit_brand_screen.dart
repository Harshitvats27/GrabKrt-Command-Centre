import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/add_brand_controller.dart';
import '../models/brand_model.dart';
import '../utils/helpers/helper_function.dart';

class EditBrandScreen extends StatefulWidget {
  final BrandModel brand;
  const EditBrandScreen({super.key, required this.brand});

  @override
  State<EditBrandScreen> createState() => _EditBrandScreenState();
}

class _EditBrandScreenState extends State<EditBrandScreen> {
  final nameController = TextEditingController();
  final countController = TextEditingController();
  final controller = Get.find<BrandController>();

  File? selectedImage;
  bool isFeatured = false;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.brand.name;
    countController.text = (widget.brand.productsCount ?? 0).toString();
    isFeatured = widget.brand.isFeatured ?? false;
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => selectedImage = File(picked.path));
    }
  }

  Future<void> updateBrand() async {
    if (nameController.text.isEmpty || countController.text.isEmpty) {
      Get.snackbar("Error", "All fields required", backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    try {
      EasyLoading.show(status: 'Updating...');
      String result = await controller.updateBrand(
        id: widget.brand.id,
        name: nameController.text.trim(),
        productsCount: int.parse(countController.text.trim()),
        isFeatured: isFeatured,
        newImageFile: selectedImage,
        oldImageUrl: widget.brand.image,
      );
      EasyLoading.dismiss();
      Get.back(result: true);
    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar("Error", e.toString(), backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = UHelperfunctions.isDarkTheme(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
        title: Text("Edit ${widget.brand.name}", style: TextStyle(color: isDark ? Colors.cyanAccent : Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.cyanAccent : Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// 🔥 NEON IMAGE PREVIEW
              Center(
                child: GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    height: 150, width: 150,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A1A1A) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isDark ? Colors.cyanAccent : Colors.blue, width: 2),
                      boxShadow: isDark ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.6), blurRadius: 20, spreadRadius: 2)] : [],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: selectedImage != null
                          ? Image.file(selectedImage!, fit: BoxFit.cover)
                          : Image.network(widget.brand.image, fit: BoxFit.cover, errorBuilder: (c, e, s) => Icon(Icons.broken_image, size: 50, color: isDark ? Colors.white : Colors.black)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(child: Text("Tap image to change", style: TextStyle(color: isDark ? Colors.white54 : Colors.grey))),
              const SizedBox(height: 30),

              _buildProInput(nameController, "Brand Name", Icons.branding_watermark, isDark),
              const SizedBox(height: 15),
              _buildProInput(countController, "Products Count", Icons.numbers, isDark, isNumber: true),
              const SizedBox(height: 15),

              /// 🔥 NEON SWITCH
              Container(
                decoration: _cardDecoration(isDark),
                child: SwitchListTile(
                  activeColor: isDark ? Colors.cyanAccent : Colors.blue,
                  title: Text("Is Featured", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                  value: isFeatured,
                  onChanged: (val) => setState(() => isFeatured = val),
                ),
              ),
              const SizedBox(height: 40),

              /// 🔥 UPDATE BUTTON
              Container(
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: isDark ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.5), blurRadius: 15)] : [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.cyanAccent : Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {
                    if (!EasyLoading.isShow) updateBrand();
                  },
                  child: Text("Update Brand 🚀", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.black : Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: isDark ? Colors.cyanAccent.withOpacity(0.8) : Colors.transparent, width: isDark ? 1.5 : 1.0),
      boxShadow: isDark ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.6), blurRadius: 20, spreadRadius: 2)] : [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 4))],
    );
  }

  Widget _buildProInput(TextEditingController controller, String hint, IconData icon, bool isDark, {bool isNumber = false}) {
    return Container(
      decoration: _cardDecoration(isDark),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: isDark ? Colors.cyanAccent : Colors.grey),
          labelText: hint,
          labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.grey[600]),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: isDark ? Colors.cyanAccent : Colors.blue, width: 2)),
          filled: true, fillColor: Colors.transparent,
        ),
      ),
    );
  }
}
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/add_brand_controller.dart';
import '../utils/helpers/helper_function.dart';

class AddBrandScreen extends StatefulWidget {
  @override
  State<AddBrandScreen> createState() => _AddBrandScreenState();
}

class _AddBrandScreenState extends State<AddBrandScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController countController = TextEditingController();
  final BrandController controller = BrandController();

  File? selectedImage;
  bool isFeatured = false;
  bool isLoading = false;

  // 🔥 CUSTOM NEON SNACKBAR
  void showNeonSnackbar(String title, String message, bool isSuccess) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isSuccess ? Colors.greenAccent : Colors.redAccent,
      colorText: Colors.black,
      margin: const EdgeInsets.all(15),
      icon: Icon(isSuccess ? Icons.check_circle : Icons.error, color: Colors.black),
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => selectedImage = File(picked.path));
    }
  }

  Future<void> submit() async {
    if (nameController.text.isEmpty || countController.text.isEmpty || selectedImage == null) {
      showNeonSnackbar("Error", "Please fill all the details to upload the brand.", false);
      return;
    }

    setState(() => isLoading = true);

    try {
      await controller.addOrUpdateBrand(
        name: nameController.text.trim(),
        imageFile: selectedImage!,
        isFeatured: isFeatured,
        productsCount: int.parse(countController.text.trim()),
      );

      showNeonSnackbar("Upload Complete", "Brand has been successfully added! 🚀", true);

      nameController.clear();
      countController.clear();
      setState(() => selectedImage = null);
    } catch (e) {
      showNeonSnackbar("Upload Failed", e.toString(), false);
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = UHelperfunctions.isDarkTheme(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
        title: Text("Add Brand", style: TextStyle(color: isDark ? Colors.cyanAccent : Colors.black, fontWeight: FontWeight.bold)),
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
              /// NEON IMAGE PICKER
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
                          : Icon(Icons.add_a_photo, size: 50, color: isDark ? Colors.cyanAccent : Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              _buildProInput(nameController, "Brand Name", Icons.branding_watermark, isDark),
              const SizedBox(height: 15),
              _buildProInput(countController, "Products Count", Icons.numbers, isDark, isNumber: true),
              const SizedBox(height: 15),

              /// NEON SWITCH
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

              /// SUBMIT BUTTON
              isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
                  : Container(
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
                  onPressed: submit,
                  child: Text("Upload Brand 🚀", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.black : Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- REUSABLE COMPONENTS ---
  BoxDecoration _cardDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: isDark ? Colors.cyanAccent.withOpacity(0.8) : Colors.transparent, width: isDark ? 1.5 : 1.0),
      boxShadow: isDark ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.6), blurRadius: 20, spreadRadius: 2)] : [],
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
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/store_controller.dart';
import '../models/StoreModel.dart';
import '../utils/helpers/helper_function.dart';
// 🔥 APNA SNACKBAR HELPER IMPORT KAR LENA YAHAN
import '../utils/snackbar_helpers.dart';
import 'map_picker_screen.dart';

class AddStoreScreen extends StatefulWidget {
  const AddStoreScreen({Key? key}) : super(key: key);

  @override
  State<AddStoreScreen> createState() => _AddStoreScreenState();
}

class _AddStoreScreenState extends State<AddStoreScreen> {
  final storeController = Get.find<StoreController>();

  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  double? _selectedLat;
  double? _selectedLng;
  String _selectedAddress = "No Location Selected";

  // 🔥 Form Clear Karne Ka Function
  void _clearForm() {
    _storeNameController.clear();
    _ownerNameController.clear();
    _phoneController.clear();
    setState(() {
      _selectedLat = null;
      _selectedLng = null;
      _selectedAddress = "No Location Selected";
    });
  }

  Widget _buildCustomInput(String hint, TextEditingController controller, IconData icon, bool isDark, {bool isNumber = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.cyanAccent.withOpacity(0.8) : Colors.grey.shade300, width: isDark ? 1.5 : 1.0),
        boxShadow: isDark ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.2), blurRadius: 10)] : [],
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
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

  @override
  Widget build(BuildContext context) {
    final isDark = UHelperfunctions.isDarkTheme(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Add Store", style: TextStyle(color: isDark ? Colors.cyanAccent : Colors.black, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: isDark ? Colors.cyanAccent : Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Setup your business profile to start selling.",
              style: TextStyle(color: isDark ? Colors.grey : Colors.black54, fontSize: 16),
            ),
            const SizedBox(height: 30),

            _buildCustomInput("Store Name (e.g. Sharma Sweets)", _storeNameController, Icons.store, isDark),
            _buildCustomInput("Owner Name", _ownerNameController, Icons.person, isDark),
            _buildCustomInput("Phone Number", _phoneController, Icons.phone, isDark, isNumber: true),

            const SizedBox(height: 20),

            // Location Box
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? Colors.cyanAccent.withOpacity(0.5) : Colors.grey.shade300, width: isDark ? 1.5 : 1.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Store Location", style: TextStyle(color: isDark ? Colors.cyanAccent : Colors.black, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(_selectedAddress, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 15),
                  Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.black : Colors.blue.withOpacity(0.1),
                        side: BorderSide(color: isDark ? Colors.cyanAccent : Colors.blue),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        final result = await Get.to(() => const MapPickerScreen());
                        if (result != null) {
                          setState(() {
                            _selectedLat = result['latitude'];
                            _selectedLng = result['longitude'];
                            _selectedAddress = result['address'];
                          });
                        }
                      },
                      icon: Icon(Icons.map, color: isDark ? Colors.cyanAccent : Colors.blue),
                      label: Text("Drop Pin on Map", style: TextStyle(color: isDark ? Colors.cyanAccent : Colors.blue)),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 40),

            // SAVE BUTTON
            Obx(() {
              return Container(
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: isDark
                      ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.5), blurRadius: 15)]
                      : [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.cyanAccent : Colors.blue,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: storeController.isSaving.value
                      ? null
                      : () async {
                    // 🔥 Naya Warning Snackbar for Validation
                    if (_storeNameController.text.isEmpty || _selectedLat == null) {
                      USnackBarHelpers.warningSnackBar(
                          title: "Required Fields",
                          message: "Please enter Store Name and select Location!"
                      );
                      return;
                    }

                    final newStore = StoreModel(
                      id: '', vendorId: '',
                      storeName: _storeNameController.text.trim(),
                      ownerName: _ownerNameController.text.trim(),
                      phoneNumber: _phoneController.text.trim(),
                      latitude: _selectedLat!,
                      longitude: _selectedLng!,
                      address: _selectedAddress,
                      isActive: true,
                    );

                    // Call the upload logic
                    bool success = await storeController.addStore(newStore);

                    if (success) {
                      _clearForm(); // 🔥 Upload successful hone par form clear karega
                      Get.back();   // 🔥 Phir screen band kar dega
                    }
                  },
                  child: storeController.isSaving.value
                      ? CircularProgressIndicator(color: isDark ? Colors.black : Colors.white)
                      : Text(
                    "SAVE STORE 🚀",
                    style: TextStyle(color: isDark ? Colors.black : Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
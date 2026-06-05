import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../utils/helpers/helper_function.dart'; // Apna helper

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({Key? key}) : super(key: key);

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(28.9931, 77.0151);
  String _address = "Fetching address...";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw 'Location services are disabled.';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw 'Permissions are denied.';
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );

      _currentPosition = LatLng(position.latitude, position.longitude);
      await _getAddressFromLatLng();

    } catch (e) {
      _address = "Move the map to select location";
    } finally {
      if (mounted) setState(() { _isLoading = false; });
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_currentPosition, 16));
    }
  }

  Future<void> _getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(_currentPosition.latitude, _currentPosition.longitude);
      Placemark place = placemarks[0];
      if (mounted) {
        setState(() {
          _address = "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}";
        });
      }
    } catch (e) {
      if (mounted) setState(() { _address = "Searching address..."; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = UHelperfunctions.isDarkTheme(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Pick Store Location', style: TextStyle(color: isDark ? Colors.cyanAccent : Colors.black, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: isDark ? Colors.cyanAccent : Colors.black),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          _isLoading
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: isDark ? Colors.cyanAccent : Colors.blue),
              const SizedBox(height: 20),
              Text("Acquiring GPS...", style: TextStyle(color: isDark ? Colors.cyanAccent : Colors.blue, letterSpacing: 1.5))
            ],
          )
              : GoogleMap(
            initialCameraPosition: CameraPosition(target: _currentPosition, zoom: 16),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            // 🔥 Map hamesha light rahega, koi custom styling nahi lagayi ab
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            onCameraMove: (CameraPosition position) {
              setState(() { _currentPosition = position.target; });
            },
            onCameraIdle: () { _getAddressFromLatLng(); },
          ),

          if (!_isLoading)
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Icon(
                Icons.location_on,
                size: 50,
                color: isDark ? Colors.cyanAccent : Colors.red,
                shadows: isDark ? [const Shadow(color: Colors.cyanAccent, blurRadius: 20)] : [],
              ),
            ),

          if (!_isLoading)
            Positioned(
              top: 20,
              right: 20,
              child: InkWell(
                onTap: () => _getUserLocation(),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: isDark ? Colors.cyanAccent : Colors.blue),
                    boxShadow: [BoxShadow(color: isDark ? Colors.cyanAccent.withOpacity(0.3) : Colors.black12, blurRadius: 10)],
                  ),
                  child: Icon(Icons.my_location, color: isDark ? Colors.cyanAccent : Colors.blue),
                ),
              ),
            ),

          if (!_isLoading)
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? Colors.cyanAccent.withOpacity(0.5) : Colors.grey.shade300, width: isDark ? 1.5 : 1.0),
                  boxShadow: isDark
                      ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.3), blurRadius: 15)]
                      : [const BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Target Location", style: TextStyle(color: isDark ? Colors.cyanAccent : Colors.blue, fontSize: 12, letterSpacing: 1.5)),
                    const SizedBox(height: 5),
                    Text(_address, textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14)),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? Colors.cyanAccent : Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.pop(context, {
                            'latitude': _currentPosition.latitude,
                            'longitude': _currentPosition.longitude,
                            'address': _address,
                          });
                        },
                        child: Text("CONFIRM LOCATION", style: TextStyle(color: isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    )
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}
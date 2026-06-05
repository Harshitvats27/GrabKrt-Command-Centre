import 'package:cloud_firestore/cloud_firestore.dart';

class StoreModel {
  String id;
  String vendorId;
  String storeName;
  String ownerName;
  String phoneNumber;
  double latitude;
  double longitude;
  String address; // Optional: Map se text address nikalne ke liye
  bool isActive;

  StoreModel({
    required this.id,
    required this.vendorId,
    required this.storeName,
    required this.ownerName,
    required this.phoneNumber,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'vendorId': vendorId,
      'storeName': storeName,
      'ownerName': ownerName,
      'phoneNumber': phoneNumber,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'isActive': isActive,
    };
  }

  factory StoreModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return StoreModel(
      id: document.id,
      vendorId: data['vendorId'] ?? '',
      storeName: data['storeName'] ?? '',
      ownerName: data['ownerName'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      latitude: double.parse((data['latitude'] ?? 0.0).toString()),
      longitude: double.parse((data['longitude'] ?? 0.0).toString()),
      address: data['address'] ?? '',
      isActive: data['isActive'] ?? true,
    );
  }
}
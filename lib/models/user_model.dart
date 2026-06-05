class UserModel {
  final String uId;
  final String username;
  final String email;
  final String phone;
  final String profilePicture;
  final String userDeviceToken;
  final String country;
  final String userAddress;
  final String street;
  final bool isActive;
  final dynamic createdOn;
  final String role; // 🔥 NEW
  final String? city;

  UserModel({
    required this.uId,
    required this.username,
    required this.email,
    required this.phone,
    required this.profilePicture,
    required this.userDeviceToken,
    required this.country,
    required this.userAddress,
    required this.street,
    required this.isActive,
    required this.createdOn,
    required this.role,
    this.city,
  });

  Map<String, dynamic> toMap() {
    return {
      'uId': uId,
      'username': username,
      'email': email,
      'phone': phone,
      'profilePicture': profilePicture,
      'userDeviceToken': userDeviceToken,
      'country': country,
      'userAddress': userAddress,
      'street': street,
      'isActive': isActive,
      'createdOn': createdOn,
      'role': role,
      'city': city,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> json, String docId) {
    return UserModel(
      uId: docId,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profilePicture: json['profilePicture'] ?? '',
      userDeviceToken: json['userDeviceToken'] ?? '',
      country: json['country'] ?? '',
      userAddress: json['userAddress'] ?? '',
      street: json['street'] ?? '',
      isActive: json['isActive'] ?? true,
      createdOn: json['createdOn'],
      role: json['role'] ?? 'user',
      city: json['city'],
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_admin/models/product_attribute_model.dart';
import 'package:e_commerce_admin/models/product_variation_model.dart';
import 'brand_model.dart';

class ProductModel {
  String id;
  int stock;
  String? sku;
  double price;
  String title;
  DateTime? date;
  double salePrice;
  String thumbnail;
  bool? isFeatured;
  BrandModel? brand;
  String? description;
  String? categoryId;
  List<String>? images;
  String productType;
  String? uploadedBy;
  List<ProductAttributeModel>? productAttributes;
  List<ProductVariationModel>? productVariations;

  // 🔥 Ye do nayi fields add ki hain Store ke liye
  String? storeId;
  String? storeName;

  ProductModel({
    required this.id,
    required this.title,
    required this.stock,
    required this.price,
    required this.thumbnail,
    required this.productType,
    this.sku,
    this.brand,
    this.date,
    this.images,
    this.uploadedBy,
    this.salePrice = 0.0,
    this.isFeatured,
    this.productVariations,
    this.description,
    this.productAttributes,
    this.categoryId,
    this.storeId,     // 🔥 Naya addition
    this.storeName,   // 🔥 Naya addition
  });

  static ProductModel empty() => ProductModel(
    id: '',
    title: '',
    stock: 0,
    price: 0,
    uploadedBy: '',
    thumbnail: '',
    productType: '',
  );

  Map<String, dynamic> toJson() {
    return {
      'sku': sku,
      'title': title,
      'stock': stock,
      'price': price,
      'images': images ?? [],
      'uploadedBy': uploadedBy ?? '',
      'thumbnail': thumbnail,
      'salePrice': salePrice,
      'isFeatured': isFeatured,
      'categoryId': categoryId,
      'brand': brand?.toJson(),
      'description': description,
      'productType': productType,
      'storeId': storeId,     // 🔥 Naya addition
      'storeName': storeName, // 🔥 Naya addition
      'productAttributes': productAttributes != null
          ? productAttributes!.map((e) => e.toJson()).toList()
          : [],
      'productVariations': productVariations != null
          ? productVariations!.map((e) => e.toJson()).toList()
          : [],
      'date': date
    };
  }

  factory ProductModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    if (data == null) return ProductModel.empty();

    return ProductModel(
      id: document.id,
      title: data['title'] ?? '',
      sku: data['sku'] ?? data['SKU'] ?? '',
      stock: data['stock'] ?? 0,
      price: double.parse((data['price'] ?? 0).toString()),
      salePrice: double.parse((data['salePrice'] ?? 0).toString()),
      thumbnail: data['thumbnail'] ?? '',
      productType: data['productType'] ?? '',
      uploadedBy: data['uploadedBy'] ?? '',
      description: data['description'] ?? '',
      categoryId: data['categoryId'] ?? '',
      isFeatured: data['isFeatured'] ?? false,
      storeId: data['storeId'],     // 🔥 Naya addition
      storeName: data['storeName'], // 🔥 Naya addition

      productVariations: data['productVariations'] is List
          ? (data['productVariations'] as List)
          .map((e) => ProductVariationModel.fromJson(
        Map<String, dynamic>.from(e),
      ))
          .toList()
          : [],

      productAttributes: data['productAttributes'] is List
          ? (data['productAttributes'] as List)
          .map((e) => ProductAttributeModel.fromJson(
        Map<String, dynamic>.from(e),
      ))
          .toList()
          : [],

      images: data['images'] is List ? List<String>.from(data['images']) : [],
    );
  }

  factory ProductModel.fromQuerySnapshot(
      QueryDocumentSnapshot<Object?> document) {
    final data = document.data() as Map<String, dynamic>;

    return ProductModel(
      id: document.id,
      title: data['title'] ?? '',
      stock: data['stock'] ?? 0,
      price: double.parse((data['price'] ?? 0).toString()),
      sku: data['sku'] ?? data['SKU'] ?? '',
      thumbnail: (data['thumbnail'] != null &&
          data['thumbnail'].toString().isNotEmpty)
          ? data['thumbnail']
          : 'https://via.placeholder.com/150',

      productType: data['productType'] ?? '',
      salePrice: double.parse((data['salePrice'] ?? 0).toString()),
      isFeatured: data['isFeatured'] ?? false,
      uploadedBy: data['uploadedBy'] ?? '',
      brand: data['brand'] != null ? BrandModel.fromJson(data['brand']) : null,
      description: data['description'],
      categoryId: data['categoryId'],
      storeId: data['storeId'],     // 🔥 Naya addition
      storeName: data['storeName'], // 🔥 Naya addition
      images: data['images'] != null ? List<String>.from(data['images']) : [],

      productAttributes: data['productAttributes'] != null
          ? (data['productAttributes'] as List<dynamic>)
          .map((e) => ProductAttributeModel.fromJson(e))
          .toList()
          : [],

      productVariations: data['productVariations'] != null
          ? (data['productVariations'] as List<dynamic>)
          .map((e) => ProductVariationModel.fromJson(e))
          .toList()
          : [],

      date: data['date'] != null ? (data['date'] as Timestamp).toDate() : null,
    );
  }
}
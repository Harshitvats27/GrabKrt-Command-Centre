class ProductVariationModel{
  final String id;
  String sku;
  String image;
  String? description;
  double price;
  double salePrice;
  int stock;
  Map<String, String> attributeValues;

  ProductVariationModel({
    required this.id,
    this.sku = '',
    this.image = '',
    this.description = '',
    this.price = 0.0,
    this.salePrice = 0.0,
    this.stock = 0,
    required this.attributeValues
  });


  static ProductVariationModel empty() => ProductVariationModel(id: '', attributeValues: {});


  Map<String, dynamic> toJson(){
    return {
      'id' : id,
      'sku' : sku,
      'image': image,
      'description': description,
      'price': price,
      'salePrice': salePrice,
      'stock': stock,
      'attributeValues': attributeValues
    };
  }


  // factory ProductVariationModel.fromJson(Map<String, dynamic> document){
  //   final data = document;
  //   if(data.isEmpty) return ProductVariationModel.empty();
  //
  //   return ProductVariationModel(
  //       id: data['id'] ?? '',
  //       description: data['description'] ?? '',
  //       image: data['image'],
  //       price: double.parse((data['price'] ?? 0.0).toString()),
  //       salePrice: double.parse((data['salePrice'] ?? 0.0).toString()),
  //       sku: data['sku'] ?? '',
  //       stock: data['stock'] ?? 0,
  //       attributeValues: Map<String,String>.from(data['attributeValues'])
  //   );
  // }



  factory ProductVariationModel.fromJson(Map<String, dynamic> document) {
    if (document.isEmpty) return ProductVariationModel.empty();

    return ProductVariationModel(
      id: document['id'] ?? '',
      sku: document['sku'] ?? '',
      image: document['image'] ?? '',
      description: document['description'] ?? '',
      price: double.parse((document['price'] ?? 0).toString()),
      salePrice: double.parse((document['salePrice'] ?? 0).toString()),
      stock: document['stock'] ?? 0,

      // ✅ SAFE FIX
      attributeValues: document['attributeValues'] != null
          ? Map<String, String>.from(document['attributeValues'])
          : {},
    );
  }


}
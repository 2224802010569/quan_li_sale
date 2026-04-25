class ProductEntity {
  final String id;
  final String productName;
  final double price;

  ProductEntity({
    required this.id,
    required this.productName,
    required this.price,
  });

  factory ProductEntity.fromJson(Map<String, dynamic> json) {
    return ProductEntity(
      id: json['id'].toString(),
      productName: json['product_name'].toString(),
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_name': productName,
      'price': price,
    };
  }
}

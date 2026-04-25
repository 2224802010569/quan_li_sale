class Product {
  final int id;
  final String productName;
  final double price;

  Product({
    required this.id,
    required this.productName,
    required this.price,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: (map['id'] as int?) ?? 0,
      productName: (map['product_name'] as String?) ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_name': productName,
      'price': price,
    };
  }
}

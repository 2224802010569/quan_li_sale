class OrderItem {
  final int? id;
  final int orderId;
  final int productId;
  final int quantity;
  final double unitPrice;
  final String? productName;

  OrderItem({
    this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    this.productName,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    final pName = (map['products'] != null) ? map['products']['product_name'] : 'Sản phẩm #${map['product_id']}';
    return OrderItem(
      id: map['id'] as int?,
      orderId: (map['order_id'] as int?) ?? 0,
      productId: (map['product_id'] as int?) ?? 0,
      quantity: (map['quantity'] as int?) ?? 0,
      unitPrice: (map['unit_price'] as num?)?.toDouble() ?? 0.0,
      productName: pName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
    };
  }
}

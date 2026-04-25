class InventoryDetailEntity {
  final String id;
  final int checkId;
  final String productId;
  final int quantity;
  final String status;
  final DateTime createdAt;

  InventoryDetailEntity({
    required this.id,
    required this.checkId,
    required this.productId,
    required this.quantity,
    required this.status,
    required this.createdAt,
  });

  factory InventoryDetailEntity.fromJson(Map<String, dynamic> json) {
    return InventoryDetailEntity(
      id: json['id'].toString(),
      checkId: json['check_id'] as int,
      productId: json['product_id'].toString(),
      quantity: json['quantity'] as int,
      status: json['status'].toString(),
      createdAt: DateTime.parse(json['created_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'check_id': checkId,
      'product_id': productId,
      'quantity': quantity,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

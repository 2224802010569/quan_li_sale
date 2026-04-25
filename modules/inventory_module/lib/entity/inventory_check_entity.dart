class InventoryCheckEntity {
  final String id;
  final String userId;
  final String storeId;
  final DateTime createdAt;

  InventoryCheckEntity({
    required this.id,
    required this.userId,
    required this.storeId,
    required this.createdAt,
  });

  factory InventoryCheckEntity.fromJson(Map<String, dynamic> json) {
    return InventoryCheckEntity(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      storeId: json['store_id'].toString(),
      createdAt: DateTime.parse(json['created_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'store_id': storeId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

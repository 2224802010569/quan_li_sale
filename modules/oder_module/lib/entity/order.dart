import 'order_item.dart';

class Order {
  final int? id;
  final String userId;
  final int storeId;
  final double totalAmount;
  final String? orderImage;
  final String? pdfLink;
  final DateTime? createdAt;
  final List<OrderItem> items;
  final String? storeName;

  Order({
    this.id,
    required this.userId,
    required this.storeId,
    required this.totalAmount,
    this.orderImage,
    this.pdfLink,
    this.createdAt,
    this.items = const [],
    this.storeName,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    final sName = (map['stores'] != null) ? map['stores']['store_name'] : 'Cửa hàng #${map['store_id']}';
    return Order(
      id: map['id'] as int?,
      userId: (map['user_id'] as String?) ?? '',
      storeId: (map['store_id'] as int?) ?? 0,
      totalAmount: (map['total_amount'] as num?)?.toDouble() ?? 0.0,
      orderImage: map['order_image'] as String?,
      pdfLink: map['pdf_link'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      items: map['order_items'] != null
          ? (map['order_items'] as List<dynamic>)
              .map((e) => OrderItem.fromMap(e as Map<String, dynamic>))
              .toList()
          : [],
      storeName: sName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'store_id': storeId,
      'total_amount': totalAmount,
      'order_image': orderImage,
      'pdf_link': pdfLink,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}

class DisplayEntity {
  final String id;
  final String userId;
  final String storeId;
  final String imageUrl;
  final String? note;
  final DateTime createdAt;

  DisplayEntity({
    required this.id,
    required this.userId,
    required this.storeId,
    required this.imageUrl,
    this.note,
    required this.createdAt,
  });

  factory DisplayEntity.fromJson(Map<String, dynamic> json) {
    return DisplayEntity(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      storeId: json['store_id'].toString(),
      imageUrl: json['image_url'].toString(),
      note: json['note']?.toString(),
      createdAt: DateTime.parse(json['created_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'store_id': storeId,
      'image_url': imageUrl,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

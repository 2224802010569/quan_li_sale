class StoreEntity {
  final int? id;
  final String storeName;
  final String address;
  final double latitude;
  final double longitude;
  final String managerId;
  final bool isHidden;
  final DateTime? createdAt;
  final Map<String, dynamic>? data;

  StoreEntity({
    this.id,
    required this.storeName,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.managerId,
    this.isHidden = false,
    this.createdAt,
    this.data,
  });

  factory StoreEntity.fromMap(Map<String, dynamic> map) {
    return StoreEntity(
      id: map['id'],
      storeName: map['store_name'] ?? '',
      address: map['address'] ?? '',
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      managerId: map['manager_id']?.toString() ?? '',
      isHidden: map['is_hidden'] ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'].toString())
          : null,
      data: map['data'] is Map<String, dynamic> ? map['data'] : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'store_name': storeName,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'manager_id': managerId,
      'is_hidden': isHidden,
      if (data != null) 'data': data,
    };
  }

  /// Tạo bản sao với thay đổi (copyWith)
  StoreEntity copyWith({
    int? id,
    String? storeName,
    String? address,
    double? latitude,
    double? longitude,
    String? managerId,
    bool? isHidden,
    DateTime? createdAt,
    Map<String, dynamic>? data,
  }) {
    return StoreEntity(
      id: id ?? this.id,
      storeName: storeName ?? this.storeName,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      managerId: managerId ?? this.managerId,
      isHidden: isHidden ?? this.isHidden,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
    );
  }
}

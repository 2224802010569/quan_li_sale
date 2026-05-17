class RouteDetailEntity {
  final int? id;
  final int routeId;
  final int storeId;
  final int sequence;
  final DateTime? createdAt;
  final Map<String, dynamic>? data;

  RouteDetailEntity({
    this.id,
    required this.routeId,
    required this.storeId,
    required this.sequence,
    this.createdAt,
    this.data,
  });

  factory RouteDetailEntity.fromJson(Map<String, dynamic> json) {
    return RouteDetailEntity(
      id: json['id'],
      routeId: json['route_id'] as int,
      storeId: json['store_id'] as int,
      sequence: json['sequence'] as int,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
      data: json['data'] is Map<String, dynamic> ? json['data'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'route_id': routeId,
      'store_id': storeId,
      'sequence': sequence,
      if (data != null) 'data': data,
    };
  }

  /// Tạo bản sao với thay đổi
  RouteDetailEntity copyWith({
    int? id,
    int? routeId,
    int? storeId,
    int? sequence,
    DateTime? createdAt,
    Map<String, dynamic>? data,
  }) {
    return RouteDetailEntity(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      storeId: storeId ?? this.storeId,
      sequence: sequence ?? this.sequence,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
    );
  }
}

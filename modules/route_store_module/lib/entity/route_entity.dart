class RouteEntity {
  final int id;
  final String routeName;
  final String createdBy;
  final bool isHidden;
  final DateTime? createdAt;
  final Map<String, dynamic>? data;

  RouteEntity({
    required this.id,
    required this.routeName,
    required this.createdBy,
    this.isHidden = false,
    this.createdAt,
    this.data,
  });

  factory RouteEntity.fromJson(Map<String, dynamic> json) {
    return RouteEntity(
      id: (json['id'] as num?)?.toInt() ?? 0,
      routeName: json['route_name'] as String,
      createdBy: json['created_by']?.toString() ?? '',
      isHidden: json['is_hidden'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
      data: json['data'] is Map<String, dynamic> ? json['data'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'route_name': routeName,
      'created_by': createdBy,
      'is_hidden': isHidden,
      if (data != null) 'data': data,
    };
  }

  /// Tạo bản sao với thay đổi
  RouteEntity copyWith({
    int? id,
    String? routeName,
    String? createdBy,
    bool? isHidden,
    DateTime? createdAt,
    Map<String, dynamic>? data,
  }) {
    return RouteEntity(
      id: id ?? this.id,
      routeName: routeName ?? this.routeName,
      createdBy: createdBy ?? this.createdBy,
      isHidden: isHidden ?? this.isHidden,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
    );
  }
}

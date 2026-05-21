import 'package:route_store_module/entity/route_entity.dart';
import 'package:route_store_module/entity/visit_status.dart';

class AssignmentEntity {
  final int assignmentId;
  final String userId;
  final int routeId;
  final int isSupport; // 1: Chính, 2: Hỗ trợ, 3: Off
  final DateTime assignedDate;
  final VisitStatus status;
  final DateTime? createdAt;
  final Map<String, dynamic>? data;
  
  // Các field mở rộng khi join với bảng Routes
  final RouteEntity? route;

  AssignmentEntity({
    required this.assignmentId,
    required this.userId,
    required this.routeId,
    required this.isSupport,
    required this.assignedDate,
    this.status = VisitStatus.pending,
    this.createdAt,
    this.data,
    this.route,
  });

  factory AssignmentEntity.fromMap(Map<String, dynamic> map) {
    return AssignmentEntity(
      assignmentId: map['id'] ?? map['assignment_id'] ?? 0,
      userId: map['user_id'] ?? '',
      routeId: map['route_id'] ?? 0,
      isSupport: map['is_support'] ?? 1,
      assignedDate: map['assigned_date'] != null 
          ? DateTime.parse(map['assigned_date'].toString()) 
          : DateTime.now(),
      status: map['status'] != null 
          ? VisitStatus.fromString(map['status']) 
          : VisitStatus.pending,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'].toString())
          : null,
      data: map['data'] is Map<String, dynamic> ? map['data'] : null,
      route: map['routes'] != null ? RouteEntity.fromJson(map['routes']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': assignmentId,
      'user_id': userId,
      'route_id': routeId,
      'is_support': isSupport,
      'assigned_date': assignedDate.toIso8601String().split('T')[0],
      if (data != null) 'data': data,
    };
  }


  /// Kiểm tra xem đây có phải assignment hỗ trợ không
  bool get isSupportAssignment => isSupport == 2;

  /// Kiểm tra xem đây có phải assignment chính không
  bool get isPrimaryAssignment => isSupport == 1;

  /// Tạo bản sao với thay đổi
  AssignmentEntity copyWith({
    int? assignmentId,
    String? userId,
    int? routeId,
    int? isSupport,
    DateTime? assignedDate,
    VisitStatus? status,
    DateTime? createdAt,
    Map<String, dynamic>? data,
    RouteEntity? route,
  }) {
    return AssignmentEntity(
      assignmentId: assignmentId ?? this.assignmentId,
      userId: userId ?? this.userId,
      routeId: routeId ?? this.routeId,
      isSupport: isSupport ?? this.isSupport,
      assignedDate: assignedDate ?? this.assignedDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
      route: route ?? this.route,
    );
  }
}

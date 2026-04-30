class AttendanceOutput {
  final bool success;
  final String? message;
  final int? storeId;      // ID cửa hàng vừa check-in
  final String? storeName; // Tên cửa hàng vừa check-in
  final int? routeId;      // Route ID của cửa hàng

  AttendanceOutput({
    required this.success,
    this.message,
    this.storeId,
    this.storeName,
    this.routeId,
  });
}

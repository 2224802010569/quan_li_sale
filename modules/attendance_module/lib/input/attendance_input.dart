class AttendanceInput {
  final int storeId;
  final String storeName;
  final int? routeId;
  final String? routeName;
  final double? latitude;
  final double? longitude;
  final bool forceCheckout;

  const AttendanceInput({
    required this.storeId,
    required this.storeName,
    this.routeId,
    this.routeName,
    this.latitude,
    this.longitude,
    this.forceCheckout = false,
  });
}

class RouteStoreOutput {
  final String action; // 'ATTENDANCE' | 'ORDER' | 'BACK'
  final int? storeId;
  final String? storeName;
  final int? routeId;
  final String? routeName;
  final double? latitude;
  final double? longitude;

  RouteStoreOutput({
    required this.action,
    this.storeId,
    this.storeName,
    this.routeId,
    this.routeName,
    this.latitude,
    this.longitude,
  });
}

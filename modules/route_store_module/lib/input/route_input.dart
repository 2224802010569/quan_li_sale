class RouteInput {
  final String userId;
  final String userRole; // VD: 'sale', 'manager'
  final double? currentLatitude;
  final double? currentLongitude;

  RouteInput({
    required this.userId,
    required this.userRole,
    this.currentLatitude,
    this.currentLongitude,
  });
}

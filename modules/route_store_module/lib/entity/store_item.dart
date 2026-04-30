class StoreItem {
  final int id;
  final String name;
  final int routeId;
  final String routeName;
  final int sequence;
  final double? latitude;
  final double? longitude;
  bool isCompleted;

  StoreItem({
    required this.id,
    required this.name,
    required this.routeId,
    required this.routeName,
    required this.sequence,
    this.latitude,
    this.longitude,
    this.isCompleted = false,
  });
}

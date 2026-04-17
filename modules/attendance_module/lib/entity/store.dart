class Store {
  final int id;
  final String name;
  final String distance;
  final String route;
  final int? routeId;
  final String lastVisited;
  final double? latitude;
  final double? longitude;
  bool isCompleted; // Added to track checkout status

  Store({
    required this.id,
    required this.name,
    required this.distance,
    required this.route,
    this.routeId,
    required this.lastVisited,
    this.latitude,
    this.longitude,
    this.isCompleted = false,
  });

  factory Store.fromMap(Map<String, dynamic> map) {
    String routeName = '';
    if (map['route_details'] != null && map['route_details'] is List && (map['route_details'] as List).isNotEmpty) {
      var rd = map['route_details'][0];
      if (rd['routes'] != null) {
        routeName = rd['routes']['route_name'] ?? '';
      }
    } else if (map['routes'] != null) {
      routeName = map['routes']['route_name'] ?? '';
    } else {
      routeName = map['route'] ?? '';
    }

    return Store(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()) ?? 0,
      name: map['store_name'] ?? map['name'] ?? 'Cửa hàng không tên',
      distance: map['distance']?.toString() ?? '0m',
      route: routeName,
      routeId: map['route_id'] is int ? map['route_id'] : int.tryParse(map['route_id'].toString()),
      lastVisited: map['last_visited']?.toString() ?? 'Chưa có',
      latitude: map['latitude'] != null ? double.tryParse(map['latitude'].toString()) : null,
      longitude: map['longitude'] != null ? double.tryParse(map['longitude'].toString()) : null,
    );
  }
}


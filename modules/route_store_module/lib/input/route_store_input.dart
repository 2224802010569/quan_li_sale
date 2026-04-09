class RouteStoreInput {
  final String role;

  RouteStoreInput({required this.role});

  bool isSale() => role == 'Sale';

  bool isManager() => role == 'Manager';
}

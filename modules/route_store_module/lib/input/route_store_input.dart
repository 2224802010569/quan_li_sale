class RouteStoreInput {
  final String role;
  final String userId;
  final String? groupId;

  const RouteStoreInput({
    required this.role,
    required this.userId,
    this.groupId,
  });

  bool isSale() => role == 'Sale';
  bool isManager() => role == 'Manager';
}

class OrderInput {
  final String action; 
  final String role;
  final String userId;
  final String? employeeName;
  final int? storeId;
  final String? storeName;
  final String? groupId;

  OrderInput({
    required this.action,
    required this.role,
    required this.userId,
    this.employeeName,
    this.storeId,
    this.storeName,
    this.groupId,
  });
}
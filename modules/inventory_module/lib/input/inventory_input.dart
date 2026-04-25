class InventoryInput {
  final String userId;
  final String storeId;
  final List<int> productIds;

  InventoryInput({
    required this.userId,
    required this.storeId,
    required this.productIds,
  });

  bool canOpen() {
    return userId.isNotEmpty && storeId.isNotEmpty && productIds.isNotEmpty;
  }
}

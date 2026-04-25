class InventoryOutput {
  final bool success;
  final String? errorMessage;
  final String from;
  final String to;
  final String view;

  InventoryOutput({
    required this.success,
    this.errorMessage,
    required this.from,
    required this.to,
    required this.view,
  });

  factory InventoryOutput.success() {
    return InventoryOutput(
      success: true,
      from: 'INVENTORY',
      to: 'ROUTE_STORE', // Trở về danh sách tuyến hoặc cửa hàng
      view: 'HOME',
    );
  }

  factory InventoryOutput.failure(String error) {
    return InventoryOutput(
      success: false,
      errorMessage: error,
      from: 'INVENTORY',
      to: '',
      view: '',
    );
  }
}

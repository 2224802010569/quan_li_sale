class InventoryOutput {
  final bool success;
  final String? errorMessage;
  final String from;
  final String to;
  final String view;
  final Map<String, int>? actualStocks;
  final Map<String, int>? previousStocks;
  final List<dynamic>? products;

  InventoryOutput({
    required this.success,
    this.errorMessage,
    required this.from,
    required this.to,
    required this.view,
    this.actualStocks,
    this.previousStocks,
    this.products,
  });

  factory InventoryOutput.success({
    Map<String, int>? actualStocks,
    Map<String, int>? previousStocks,
    List<dynamic>? products,
  }) {
    return InventoryOutput(
      success: true,
      from: 'INVENTORY',
      to: 'INVENTORY_SUMMARY',
      view: 'SUMMARY',
      actualStocks: actualStocks,
      previousStocks: previousStocks,
      products: products,
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

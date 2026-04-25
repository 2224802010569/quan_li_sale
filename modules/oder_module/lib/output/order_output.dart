class OrderOutput {
  final String from;
  final String to;
  final String view;
  final Map<String, dynamic>? data;

  OrderOutput({
    required this.from,
    required this.to,
    required this.view,
    this.data,
  });

  factory OrderOutput.orderSuccess() {
    return OrderOutput(
      from: 'ORDER',
      to: 'ORDER', // Or wherever it needs to go
      view: 'SUCCESS',
    );
  }
}

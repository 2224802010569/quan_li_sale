import 'package:flutter/material.dart';
import '../entity/product_entity.dart';
import 'product_picker_sheet.dart';
import 'barcode_scanner_view.dart';

class InventoryAuditView extends StatefulWidget {
  final List<ProductEntity> allProducts;
  final VoidCallback onBack;
  final Function(Map<String, int> actualStocks) onConfirm;

  const InventoryAuditView({
    super.key,
    required this.allProducts,
    required this.onBack,
    required this.onConfirm,
  });

  @override
  State<InventoryAuditView> createState() => _InventoryAuditViewState();
}

class _InventoryAuditViewState extends State<InventoryAuditView> {
  final Map<String, int> _actualStocks = {};

  void _updateStock(String id, int delta) {
    setState(() {
      final current = _actualStocks[id] ?? 0;
      final newValue = current + delta;
      if (newValue >= 0) {
        _actualStocks[id] = newValue;
      }
    });
  }

  void _updateExactStock(String id, int value) {
    setState(() {
      if (value >= 0) {
        _actualStocks[id] = value;
      }
    });
  }

  void _showQuantityDialog(BuildContext context, String productId, int initialValue) {
    final controller = TextEditingController(text: initialValue.toString());
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Nhập số lượng'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Số lượng',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                final val = int.tryParse(controller.text) ?? 0;
                _updateExactStock(productId, val);
                Navigator.pop(ctx);
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  void _openProductPicker() async {
    final selectedProduct = await showModalBottomSheet<ProductEntity>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ProductPickerSheet(allProducts: widget.allProducts),
    );

    if (selectedProduct != null) {
      setState(() {
        if (!_actualStocks.containsKey(selectedProduct.id)) {
          _actualStocks[selectedProduct.id] = 0;
        }
      });
    }
  }

  void _openScanner() async {
    final scannedBarcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerView()),
    );

    if (scannedBarcode != null && mounted) {
      final product = widget.allProducts.where((p) => p.id == scannedBarcode).firstOrNull;
      if (product != null) {
        setState(() {
          final current = _actualStocks[product.id] ?? 0;
          _actualStocks[product.id] = current + 1;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã quét: ${product.productName} (+1)')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy sản phẩm')),
        );
      }
    }
  }

  void _handleConfirm() {
    if (_actualStocks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng thêm ít nhất 1 sản phẩm để kiểm tồn.')),
      );
      return;
    }
    widget.onConfirm(_actualStocks);
  }

  @override
  Widget build(BuildContext context) {
    final selectedProductIds = _actualStocks.keys.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text('Kiểm tồn kho'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _openProductPicker,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: selectedProductIds.isEmpty
                ? Center(
                    child: Text(
                      'Chưa có sản phẩm nào.\nBấm "+" hoặc quét mã để bắt đầu.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: selectedProductIds.length,
                    itemBuilder: (context, index) {
                      final productId = selectedProductIds[index];
                      final product = widget.allProducts.firstWhere((p) => p.id == productId);
                      final currentStock = _actualStocks[productId] ?? 0;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.productName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Giá: ${product.price}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    onPressed: () => _updateStock(product.id, -1),
                                    color: Colors.red,
                                  ),
                                  GestureDetector(
                                    onTap: () => _showQuantityDialog(context, product.id, currentStock),
                                    child: SizedBox(
                                      width: 40,
                                      child: Text(
                                        '$currentStock',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () => _updateStock(product.id, 1),
                                    color: Colors.green,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _openScanner,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Icon(Icons.qr_code_scanner),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 8,
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _handleConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'XÁC NHẬN',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

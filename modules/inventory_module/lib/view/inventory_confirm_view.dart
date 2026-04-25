import 'dart:io';
import 'package:flutter/material.dart';
import '../entity/product_entity.dart';
import 'proof_capture_view.dart';
import 'components/camera_capture_box.dart';

class InventoryConfirmView extends StatefulWidget {
  final Map<String, int> actualStocks;
  final Map<String, int> previousStocks;
  final List<ProductEntity> allProducts;
  final VoidCallback onBack;
  final Function(File proofImage) onSubmit;
  final bool isLoading;

  const InventoryConfirmView({
    super.key,
    required this.actualStocks,
    required this.previousStocks,
    required this.allProducts,
    required this.onBack,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<InventoryConfirmView> createState() => _InventoryConfirmViewState();
}

class _InventoryConfirmViewState extends State<InventoryConfirmView> {
  File? _proofImage;

  Future<void> _openCamera() async {
    final file = await Navigator.push<File>(
      context,
      MaterialPageRoute(builder: (_) => const ProofCaptureView()),
    );

    if (file != null && mounted) {
      setState(() {
        _proofImage = file;
      });
    }
  }

  void _submit() {
    if (_proofImage == null) return;
    widget.onSubmit(_proofImage!);
  }

  @override
  Widget build(BuildContext context) {
    final selectedIds = widget.actualStocks.keys.toList();

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF4F6F8),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          AppBar(
            title: const Text('Xác nhận kiểm tồn'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: widget.onBack,
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: selectedIds.length,
              itemBuilder: (context, index) {
                final productId = selectedIds[index];
                final product = widget.allProducts.firstWhere((p) => p.id == productId);
                final actual = widget.actualStocks[productId]!;
                final previous = widget.previousStocks[productId];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.productName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        if (previous == null)
                          Text(
                            'Lần đầu kiểm -> Tồn nay: $actual',
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                          )
                        else
                          Text(
                            'Tồn trước: $previous -> Tồn nay: $actual',
                            style: TextStyle(
                              color: actual == previous ? Colors.blue : (actual > previous ? Colors.green : Colors.red),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CameraCaptureBox(
              imagePath: _proofImage?.path,
              onCapture: _openCamera,
              onRemove: _proofImage != null ? () => setState(() => _proofImage = null) : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _proofImage != null && !widget.isLoading ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'XÁC NHẬN GỬI',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../entity/product_entity.dart';
import 'product_picker_sheet.dart';
import 'barcode_scanner_view.dart';
import 'package:core/theme/theme.dart';

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
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          title: Text(
            'Nhập số lượng',
            style: AppTextStyles.headlineSm.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            style: AppTextStyles.bodyLg.copyWith(color: AppColors.onSurface),
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.secondary, width: 2),
              ),
              labelText: 'Số lượng',
              labelStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Hủy',
                style: AppTextStyles.labelLg.copyWith(color: AppColors.onSurfaceVariant),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final val = int.tryParse(controller.text) ?? 0;
                _updateExactStock(productId, val);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radius),
                ),
              ),
              child: Text(
                'Xác nhận',
                style: AppTextStyles.labelLg.copyWith(fontWeight: FontWeight.bold, color: AppColors.white),
              ),
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
      backgroundColor: AppColors.white,
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Kiểm tồn kho',
          style: AppTextStyles.headlineSm.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurface, size: 20),
          onPressed: widget.onBack,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.secondary, size: 24),
            onPressed: _openProductPicker,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: selectedProductIds.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.containerMargin,
                      vertical: AppSpacing.lg,
                    ),
                    itemCount: selectedProductIds.length,
                    itemBuilder: (context, index) {
                      final productId = selectedProductIds[index];
                      final product = widget.allProducts.firstWhere((p) => p.id == productId);
                      final currentStock = _actualStocks[productId] ?? 0;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.stackGap),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                          boxShadow: AppShadows.level1,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.productName,
                                      style: AppTextStyles.bodyLg.copyWith(
                                        color: AppColors.onSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Giá: ${product.price}đ',
                                      style: AppTextStyles.bodyMd.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline_rounded, size: 22),
                                    onPressed: () => _updateStock(product.id, -1),
                                    color: AppColors.error,
                                  ),
                                  GestureDetector(
                                    onTap: () => _showQuantityDialog(context, product.id, currentStock),
                                    child: Container(
                                      width: 44,
                                      alignment: Alignment.center,
                                      child: Text(
                                        '$currentStock',
                                        style: AppTextStyles.bodyLg.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.secondary,
                                          decoration: TextDecoration.underline,
                                          decorationColor: AppColors.secondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
                                    onPressed: () => _updateStock(product.id, 1),
                                    color: AppColors.secondary,
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
          
          // Bottom Bar (Scanner + Confirm)
          Container(
            padding: const EdgeInsets.all(AppSpacing.containerMargin),
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(
                top: BorderSide(color: AppColors.outlineVariant, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _openScanner,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        side: const BorderSide(color: AppColors.outlineVariant, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        ),
                      ),
                      child: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.secondary, size: 24),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 8,
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _handleConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        ),
                      ),
                      child: Text(
                        'XÁC NHẬN',
                        style: AppTextStyles.labelLg.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          letterSpacing: 0.5,
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

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 80, left: 24, right: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: AppShadows.level2,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.inventory_2_outlined,
                      size: 64,
                      color: AppColors.outlineVariant,
                    ),
                  ),
                ),
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner_rounded,
                      color: AppColors.white,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Chưa có sản phẩm nào',
              style: AppTextStyles.headlineSm.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Bấm nút "+" ở trên cùng bên phải\nhoặc quét mã QR dưới góc để thêm sản phẩm kiểm kho.',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

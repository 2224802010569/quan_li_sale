import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../entity/product.dart';
import '../../../logic_uc/create_order_uc.dart';
import '../../../logic_uc/generate_pdf_uc.dart';
import '../../widgets/product_item_card.dart';
import '../../widgets/order_summary_panel.dart';
import '../../widgets/camera_capture_box.dart';
import '../../../output/order_output.dart';

class CreateOrderView extends StatefulWidget {
  final CreateOrderUC createOrderUC;
  final GeneratePdfUC generatePdfUC;
  final String userId;
  final String employeeName;
  final int storeId;
  final String storeName;
  final VoidCallback onBack;
  final Function(OrderOutput)? onOutput;

  const CreateOrderView({
    super.key,
    required this.createOrderUC,
    required this.generatePdfUC,
    required this.userId,
    required this.employeeName,
    required this.storeId,
    required this.storeName,
    required this.onBack,
    this.onOutput,
  });

  @override
  State<CreateOrderView> createState() => _CreateOrderViewState();
}

class _CreateOrderViewState extends State<CreateOrderView> {
  List<Product> _products = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _capturedImagePath;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await widget.createOrderUC.loadProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải danh sách sản phẩm';
        _isLoading = false;
      });
    }
  }

  void _onAddProduct(Product product) {
    setState(() {
      widget.createOrderUC.addProduct(product);
    });
  }

  void _onIncrement(int productId) {
    setState(() {
      widget.createOrderUC.incrementQuantity(productId);
    });
  }

  void _onDecrement(int productId) {
    setState(() {
      widget.createOrderUC.decrementQuantity(productId);
    });
  }

  void _onUpdateQuantity(int productId, int qty) {
    setState(() {
      widget.createOrderUC.updateQuantity(productId, qty);
    });
  }

  Future<void> _onCapture() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (photo != null) {
      setState(() {
        _capturedImagePath = photo.path;
      });
    }
  }

  void _onRemoveImage() {
    setState(() {
      _capturedImagePath = null;
    });
  }

  Future<void> _onSubmitOrder() async {
    if (_capturedImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chụp ảnh đơn hàng trước khi lưu')),
      );
      return;
    }

    if (widget.createOrderUC.isCartEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng thêm sản phẩm vào giỏ hàng')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final orderId = await widget.createOrderUC.submitOrder(
        userId: widget.userId,
        storeId: widget.storeId,
        imagePath: _capturedImagePath,
      );

      final cartItems = widget.createOrderUC.cart.values.toList();

      await widget.generatePdfUC.generateAndUpload(
        orderId: orderId,
        storeName: widget.storeName,
        items: cartItems,
        subtotal: widget.createOrderUC.subtotal,
        vatAmount: widget.createOrderUC.vatAmount,
        totalAmount: widget.createOrderUC.totalAmount,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đơn hàng đã được lưu thành công!')),
      );

      if (widget.onOutput != null) {
        widget.onOutput!(OrderOutput.orderSuccess());
      } else {
        widget.onBack();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showProductPicker() {
    final cartKeys = widget.createOrderUC.cart.keys.toSet();
    final availableProducts = _products.where((p) => !cartKeys.contains(p.id)).toList();

    if (availableProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tất cả sản phẩm đã được thêm')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _ProductPickerSheet(
        products: availableProducts,
        onSelect: (product) {
          Navigator.of(ctx).pop();
          _onAddProduct(product);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = widget.createOrderUC.cart;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF172554)),
          onPressed: widget.onBack,
        ),
        title: const Text(
          'Lên đơn hàng',
          style: TextStyle(
            color: Color(0xFF172554),
            fontSize: 24,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            letterSpacing: -1.20,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF003178)))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Color(0xFF434651),
                          fontSize: 16,
                          fontFamily: 'Manrope',
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _errorMessage = null;
                          });
                          _loadProducts();
                        },
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        title: 'DANH SÁCH SẢN PHẨM',
                        actionLabel: 'Thêm sản phẩm',
                        onAction: _showProductPicker,
                      ),
                      const SizedBox(height: 16),
                      if (cart.isEmpty)
                        _buildEmptyCartPlaceholder()
                      else
                        ...cart.values.map((cartItem) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: ProductItemCard(
                                product: cartItem.product,
                                quantity: cartItem.quantity,
                                onIncrement: () => _onIncrement(cartItem.product.id),
                                onDecrement: () => _onDecrement(cartItem.product.id),
                                onUpdateQuantity: (val) => _onUpdateQuantity(cartItem.product.id, val),
                              ),
                            )),
                      const SizedBox(height: 32),
                      _buildPrintDraftButton(),
                      const SizedBox(height: 32),
                      _buildSectionLabel('CHỤP HÌNH ĐƠN HÀNG'),
                      const SizedBox(height: 16),
                      CameraCaptureBox(
                        imagePath: _capturedImagePath,
                        onCapture: _onCapture,
                        onRemove: _onRemoveImage,
                      ),
                      const SizedBox(height: 32),
                      OrderSummaryPanel(
                        productCount: cart.length,
                        totalQuantity: widget.createOrderUC.totalItems,
                        subtotal: widget.createOrderUC.subtotal,
                        vatAmount: widget.createOrderUC.vatAmount,
                        totalAmount: widget.createOrderUC.totalAmount,
                        onSubmit: _onSubmitOrder,
                        isSubmitting: _isSubmitting,
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF434651),
              fontSize: 14,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              height: 1.43,
              letterSpacing: 1.40,
            ),
          ),
          GestureDetector(
            onTap: onAction,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_circle_outline, size: 18, color: Color(0xFF001D4E)),
                const SizedBox(width: 4),
                Text(
                  actionLabel,
                  style: const TextStyle(
                    color: Color(0xFF001D4E),
                    fontSize: 14,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    height: 1.43,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF434651),
          fontSize: 14,
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w700,
          height: 1.43,
          letterSpacing: 1.40,
        ),
      ),
    );
  }

  Future<void> _onPrintDraft() async {
    if (widget.createOrderUC.isCartEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng thêm sản phẩm vào giỏ hàng')),
      );
      return;
    }

    try {
      await widget.generatePdfUC.printDraftInvoice(
        storeName: widget.storeName,
        items: widget.createOrderUC.cart.values.toList(),
        subtotal: widget.createOrderUC.subtotal,
        vatAmount: widget.createOrderUC.vatAmount,
        totalAmount: widget.createOrderUC.totalAmount,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi in: ${e.toString()}')),
      );
    }
  }

  Widget _buildPrintDraftButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _onPrintDraft,
        icon: const Icon(Icons.print, size: 20),
        label: const Text(
          'In hóa đơn tạm tính',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF003178),
          side: const BorderSide(width: 1.5, color: Color(0xFF003178)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCartPlaceholder() {
    return Container(
      width: double.infinity,
      height: 128,
      decoration: ShapeDecoration(
        color: const Color(0x7FF3F3F3),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 2, color: Color(0x4CC4C6D2)),
          borderRadius: BorderRadius.circular(32),
        ),
      ),
      child: const Center(
        child: Text(
          'Nhấn vào "Thêm sản phẩm" để\nbổ sung hàng hóa',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF434651),
            fontSize: 16,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w400,
            height: 1.50,
          ),
        ),
      ),
    );
  }
}

class _ProductPickerSheet extends StatelessWidget {
  final List<Product> products;
  final ValueChanged<Product> onSelect;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );

  const _ProductPickerSheet({
    required this.products,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8E8),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Chọn sản phẩm',
            style: TextStyle(
              color: Color(0xFF172554),
              fontSize: 20,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w800,
              letterSpacing: -0.50,
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: products.length,
              separatorBuilder: (_, i) => const Divider(
                height: 1,
                color: Color(0xFFF3F3F3),
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F3F3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.inventory_2_outlined,
                        color: Color(0xFF94A3B8),
                        size: 24,
                      ),
                    ),
                  ),
                  title: Text(
                    product.productName,
                    style: const TextStyle(
                      color: Color(0xFF172554),
                      fontSize: 16,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    _currencyFormat.format(product.price),
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 14,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.add_circle,
                    color: Color(0xFF003178),
                    size: 28,
                  ),
                  onTap: () => onSelect(product),
                );
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}

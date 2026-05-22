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
import 'package:core/theme/theme.dart';

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurface, size: 20),
          onPressed: widget.onBack,
        ),
        title: Text(
          'Lên đơn hàng',
          style: AppTextStyles.headlineSm.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.secondary))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _errorMessage!,
                        style: AppTextStyles.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                          ),
                        ),
                        child: Text(
                          'Thử lại',
                          style: AppTextStyles.labelLg.copyWith(fontWeight: FontWeight.bold, color: AppColors.white),
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.containerMargin,
                    vertical: AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        title: 'DANH SÁCH SẢN PHẨM',
                        actionLabel: 'Thêm sản phẩm',
                        onAction: _showProductPicker,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (cart.isEmpty)
                        _buildEmptyCartPlaceholder()
                      else
                        ...cart.values.map((cartItem) => Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.stackGap),
                              child: ProductItemCard(
                                product: cartItem.product,
                                quantity: cartItem.quantity,
                                onIncrement: () => _onIncrement(cartItem.product.id),
                                onDecrement: () => _onDecrement(cartItem.product.id),
                                onUpdateQuantity: (val) => _onUpdateQuantity(cartItem.product.id, val),
                              ),
                            )),
                      const SizedBox(height: AppSpacing.xxl),
                      _buildPrintDraftButton(),
                      const SizedBox(height: AppSpacing.xxl),
                      _buildSectionLabel('CHỤP HÌNH ĐƠN HÀNG'),
                      const SizedBox(height: AppSpacing.md),
                      CameraCaptureBox(
                        imagePath: _capturedImagePath,
                        onCapture: _onCapture,
                        onRemove: _onRemoveImage,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      OrderSummaryPanel(
                        productCount: cart.length,
                        totalQuantity: widget.createOrderUC.totalItems,
                        subtotal: widget.createOrderUC.subtotal,
                        vatAmount: widget.createOrderUC.vatAmount,
                        totalAmount: widget.createOrderUC.totalAmount,
                        onSubmit: _onSubmitOrder,
                        isSubmitting: _isSubmitting,
                      ),
                      const SizedBox(height: 24),
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
            style: AppTextStyles.labelLg.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          GestureDetector(
            onTap: onAction,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_circle_outline_rounded, size: 18, color: AppColors.secondary),
                const SizedBox(width: 6),
                Text(
                  actionLabel,
                  style: AppTextStyles.labelLg.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
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
        style: AppTextStyles.labelLg.copyWith(
          color: AppColors.onSurfaceVariant,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
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
    return InkWell(
      onTap: _onPrintDraft,
      borderRadius: BorderRadius.circular(32),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0x4CC4C6D2), width: 2),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.print_outlined, color: Color(0xFF434651)),
            SizedBox(width: 8),
            Text(
              'In hóa đơn tạm tính',
              style: TextStyle(
                color: Color(0xFF434651),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCartPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border.all(
          width: 1.5,
          color: AppColors.outlineVariant,
          style: BorderStyle.solid, // Flutter doesn't natively support dashed border in BoxBorder, so solid is fine or we custom paint. Standard solid border is very clean.
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Center(
        child: Text(
          'Nhấn vào "Thêm sản phẩm" để\nbổ sung hàng hóa',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLg.copyWith(
            color: AppColors.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

class _ProductPickerSheet extends StatefulWidget {
  final List<Product> products;
  final ValueChanged<Product> onSelect;

  const _ProductPickerSheet({
    required this.products,
    required this.onSelect,
  });

  @override
  State<_ProductPickerSheet> createState() => _ProductPickerSheetState();
}

class _ProductPickerSheetState extends State<_ProductPickerSheet> {
  String _searchQuery = '';
  late final TextEditingController _searchController;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = widget.products.where((p) {
      final name = p.productName.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query);
    }).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Chọn sản phẩm',
            style: AppTextStyles.headlineSm.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                boxShadow: AppShadows.level1,
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                style: AppTextStyles.bodyLg.copyWith(color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm sản phẩm...',
                  hintStyle: AppTextStyles.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.onSurfaceVariant, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: AppColors.onSurfaceVariant, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: filteredProducts.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.search_off_rounded, size: 48, color: AppColors.outlineVariant),
                          const SizedBox(height: 12),
                          Text(
                            'Không tìm thấy sản phẩm phù hợp',
                            style: AppTextStyles.bodyLg.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: filteredProducts.length,
                    separatorBuilder: (_, i) => const Divider(
                      height: 1,
                      color: AppColors.outlineVariant,
                    ),
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(AppSpacing.radius),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.inventory_2_outlined,
                              color: AppColors.onSurfaceVariant,
                              size: 24,
                            ),
                          ),
                        ),
                        title: Text(
                          product.productName,
                          style: AppTextStyles.bodyLg.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          _currencyFormat.format(product.price),
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.add_circle_rounded,
                          color: AppColors.secondary,
                          size: 28,
                        ),
                        onTap: () => widget.onSelect(product),
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

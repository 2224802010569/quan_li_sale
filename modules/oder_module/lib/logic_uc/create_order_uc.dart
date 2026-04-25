import '../entity/product.dart';
import '../entity/order.dart';
import '../entity/order_item.dart';
import '../logic_data/order_data.dart';
import '../logic_data/product_data.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get lineTotal => product.price * quantity;
}

class CreateOrderUC {
  final ProductData _productData;
  final OrderData _orderData;

  final Map<int, CartItem> _cart = {};

  CreateOrderUC({
    required ProductData productData,
    required OrderData orderData,
  })  : _productData = productData,
        _orderData = orderData;

  Map<int, CartItem> get cart => Map.unmodifiable(_cart);

  Future<List<Product>> loadProducts() async {
    return _productData.getProducts();
  }

  void addProduct(Product product) {
    if (_cart.containsKey(product.id)) {
      _cart[product.id]!.quantity++;
    } else {
      _cart[product.id] = CartItem(product: product);
    }
  }

  void removeProduct(int productId) {
    _cart.remove(productId);
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      _cart.remove(productId);
      return;
    }
    if (_cart.containsKey(productId)) {
      _cart[productId]!.quantity = quantity;
    }
  }

  void incrementQuantity(int productId) {
    if (_cart.containsKey(productId)) {
      _cart[productId]!.quantity++;
    }
  }

  void decrementQuantity(int productId) {
    if (_cart.containsKey(productId)) {
      final current = _cart[productId]!.quantity;
      if (current <= 1) {
        _cart.remove(productId);
      } else {
        _cart[productId]!.quantity--;
      }
    }
  }

  void clearCart() {
    _cart.clear();
  }

  double get subtotal {
    return _cart.values.fold(0.0, (sum, item) => sum + item.lineTotal);
  }

  double get vatAmount {
    return subtotal * 0.10;
  }

  double get totalAmount {
    return subtotal + vatAmount;
  }

  int get totalItems {
    return _cart.values.fold(0, (sum, item) => sum + item.quantity);
  }

  bool get isCartEmpty => _cart.isEmpty;

  Future<int> submitOrder({
    required String userId,
    required int storeId,
    String? imagePath,
  }) async {
    if (_cart.isEmpty) {
      throw Exception('Giỏ hàng trống');
    }

    String? imageUrl;
    if (imagePath != null) {
      imageUrl = await _orderData.uploadFile(
        filePath: imagePath,
        bucket: 'order_images',
        folder: 'orders',
      );
    }

    final order = Order(
      userId: userId,
      storeId: storeId,
      totalAmount: totalAmount,
      orderImage: imageUrl,
    );

    final items = _cart.values.map((cartItem) {
      return OrderItem(
        orderId: 0,
        productId: cartItem.product.id,
        quantity: cartItem.quantity,
        unitPrice: cartItem.product.price,
      );
    }).toList();

    final orderId = await _orderData.createOrder(
      order: order,
      items: items,
    );

    _cart.clear();
    return orderId;
  }
}

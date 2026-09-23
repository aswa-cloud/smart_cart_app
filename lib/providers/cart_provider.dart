import 'package:flutter/material.dart';
import '../helpers/db_helper.dart';
import '../models/product_model.dart';

class CartItem {
  final String id;
  final ProductModel product;
  int quantity;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
  });
}

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  final DBHelper _dbHelper = DBHelper();

  List<CartItem> get items => _items;

  int get totalItemsCount {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalPrice {
    return _items.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  Future<void> fetchAndSetCart() async {
    final dataList = await _dbHelper.getCartItems();
    _items = dataList.map((map) {
      return CartItem(
        id: map['id'],
        product: ProductModel(
          id: map['product_id'],
          name: map['name'],
          subtitle: map['subtitle'] ?? '',
          price: (map['price'] as num).toDouble(),
          category: map['category'] ?? '',
          imagePath: map['image_path'],
        ),
        quantity: map['quantity'],
      );
    }).toList();
    notifyListeners();
  }

  Future<void> addToCart(ProductModel product) async {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      final newQty = _items[index].quantity + 1;
      await _dbHelper.updateCartQuantity(_items[index].id, newQty);
    } else {
      final cartId = DateTime.now().millisecondsSinceEpoch.toString();
      final cartMap = {
        'id': cartId,
        'product_id': product.id,
        'name': product.name,
        'subtitle': product.subtitle,
        'price': product.price,
        'category': product.category,
        'image_path': product.imagePath,
        'quantity': 1,
      };
      await _dbHelper.insertCart(cartMap);
    }
    await fetchAndSetCart();
  }

  Future<void> updateQuantity(String productId, int delta) async {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      final newQty = _items[index].quantity + delta;
      if (newQty <= 0) {
        await _dbHelper.deleteCartItem(_items[index].id);
      } else {
        await _dbHelper.updateCartQuantity(_items[index].id, newQty);
      }
      await fetchAndSetCart();
    }
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  CartProvider() {
    _loadCartFromStorage();
  }

  List<CartItem> get items => _items;

  int get totalItemsCount {
    int total = 0;
    for (var item in _items) {
      total += item.quantity;
    }
    return total;
  }

  double get totalPrice {
    double total = 0.0;
    for (var item in _items) {
      total += item.product.price * item.quantity;
    }
    return total;
  }

  // Menyimpan data keranjang belanja ke HP
  Future<void> _saveCartToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> cartData = _items.map((item) {
      return {
        'id': item.product.id,
        'name': item.product.name,
        'subtitle': item.product.subtitle,
        'price': item.product.price,
        'category': item.product.category,
        'imagePath': item.product.imagePath,
        'quantity': item.quantity,
      };
    }).toList();

    await prefs.setString('saved_cart', jsonEncode(cartData));
  }

  // Memuat data keranjang belanja dari HP saat aplikasi dibuka
  Future<void> _loadCartFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('saved_cart');
    if (savedData != null) {
      final List<dynamic> decoded = jsonDecode(savedData);
      _items.clear();
      for (var item in decoded) {
        _items.add(
          CartItem(
            product: ProductModel(
              id: item['id'],
              name: item['name'],
              subtitle: item['subtitle'],
              price: (item['price'] as num).toDouble(),
              category: item['category'],
              imagePath: item['imagePath'],
            ),
            quantity: item['quantity'],
          ),
        );
      }
      notifyListeners();
    }
  }

  void addToCart(ProductModel product) {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    _saveCartToStorage();
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    _saveCartToStorage();
    notifyListeners();
  }

  void updateQuantity(String productId, int delta) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].quantity += delta;
      if (_items[index].quantity <= 0) {
        _items.removeAt(index);
      }
      _saveCartToStorage();
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    _saveCartToStorage();
    notifyListeners();
  }
}
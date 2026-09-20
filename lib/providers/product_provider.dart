import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';

class ProductProvider with ChangeNotifier {
  final List<ProductModel> _products = [
    ProductModel(
      id: '1',
      name: 'Laptop RPL Pro',
      subtitle: 'Core i7 · 16GB RAM',
      price: 12500000,
      category: 'Hardware',
    ),
    ProductModel(
      id: '2',
      name: 'Mouse Wireless',
      subtitle: 'Ergonomic Silent Click',
      price: 250000,
      category: 'Aksesoris',
    ),
    ProductModel(
      id: '3',
      name: 'Keyboard Mechanical',
      subtitle: 'RGB Green Switch',
      price: 750000,
      category: 'Aksesoris',
    ),
  ];

  String _selectedCategory = 'Semua';
  String _searchQuery = '';

  ProductProvider() {
    _loadSavedImages();
  }

  List<ProductModel> get products {
    return _products.where((product) {
      final matchesCategory = _selectedCategory == 'Semua' || product.category == _selectedCategory;
      final matchesSearch = product.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  String get selectedCategory => _selectedCategory;

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Memuat foto produk yang tersimpan di memori HP
  Future<void> _loadSavedImages() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < _products.length; i++) {
      final savedPath = prefs.getString('product_image_${_products[i].id}');
      if (savedPath != null) {
        _products[i] = ProductModel(
          id: _products[i].id,
          name: _products[i].name,
          subtitle: _products[i].subtitle,
          price: _products[i].price,
          category: _products[i].category,
          imagePath: savedPath,
        );
      }
    }
    notifyListeners();
  }

  // Menyimpan lokasi foto produk secara permanen
  Future<void> updateProductImage(String productId, String imagePath) async {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index >= 0) {
      final oldProduct = _products[index];
      _products[index] = ProductModel(
        id: oldProduct.id,
        name: oldProduct.name,
        subtitle: oldProduct.subtitle,
        price: oldProduct.price,
        category: oldProduct.category,
        imagePath: imagePath,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('product_image_$productId', imagePath);
      notifyListeners();
    }
  }
}
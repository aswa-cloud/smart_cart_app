import 'package:flutter/material.dart';
import '../helpers/db_helper.dart';
import '../models/product_model.dart';

class ProductProvider with ChangeNotifier {
  List<ProductModel> _allProducts = [];
  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  final DBHelper _dbHelper = DBHelper();

  String get selectedCategory => _selectedCategory;

  List<ProductModel> get products {
    return _allProducts.where((product) {
      final matchesCategory = _selectedCategory == 'Semua' || product.category == _selectedCategory;
      final matchesSearch = product.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  Future<void> fetchAndSetProducts() async {
    final dataList = await _dbHelper.getProducts();
    _allProducts = dataList.map((item) => ProductModel.fromMap(item)).toList();

    if (_allProducts.isEmpty) {
      final defaultProducts = [
        ProductModel(id: '1', name: 'Laptop RPL Pro', subtitle: 'Core i7 · 16GB RAM', price: 12500000, category: 'Hardware'),
        ProductModel(id: '2', name: 'Mouse Wireless', subtitle: 'Ergonomic Silent Click', price: 250000, category: 'Aksesoris'),
        ProductModel(id: '3', name: 'Keyboard Mechanical', subtitle: 'RGB Green Switch', price: 750000, category: 'Aksesoris'),
      ];
      for (var p in defaultProducts) {
        await _dbHelper.insertProduct(p.toMap());
      }
      final updatedList = await _dbHelper.getProducts();
      _allProducts = updatedList.map((item) => ProductModel.fromMap(item)).toList();
    }
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> updateProductImage(String productId, String imagePath) async {
    await _dbHelper.updateProductImage(productId, imagePath);
    await fetchAndSetProducts();
  }

  Future<void> addProduct(String name, String subtitle, double price, String category) async {
    final newProduct = ProductModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      subtitle: subtitle,
      price: price,
      category: category,
    );
    await _dbHelper.insertProduct(newProduct.toMap());
    await fetchAndSetProducts();
  }
}
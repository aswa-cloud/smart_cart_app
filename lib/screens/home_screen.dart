import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../models/product_model.dart';
import '../widgets/product_card.dart';
import '../widgets/search_bar_widget.dart';
import 'cart_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void _pickImageForProduct(BuildContext context, ProductModel product) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ubah Foto: ${product.name}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E4D3B),
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(
                        source: ImageSource.camera,
                        imageQuality: 80,
                      );
                      if (picked != null) {
                        Provider.of<ProductProvider>(context, listen: false)
                            .updateProductImage(product.id, picked.path);
                      }
                    },
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    label: const Text('Kamera', style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E4D3B),
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 80,
                      );
                      if (picked != null) {
                        Provider.of<ProductProvider>(context, listen: false)
                            .updateProductImage(product.id, picked.path);
                      }
                    },
                    icon: const Icon(Icons.photo_library, color: Colors.white),
                    label: const Text('Galeri', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final nameController = TextEditingController();
    final subtitleController = TextEditingController();
    final priceController = TextEditingController();
    String selectedCat = 'Hardware';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Tambah Produk Baru', style: TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nama Produk'),
                  ),
                  TextField(
                    controller: subtitleController,
                    decoration: const InputDecoration(labelText: 'Deskripsi Singkat'),
                  ),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Harga (Rp)'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedCat,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                    items: ['Hardware', 'Aksesoris']
                        .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedCat = val);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E4D3B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                    final price = double.tryParse(priceController.text) ?? 0.0;
                    Provider.of<ProductProvider>(context, listen: false).addProduct(
                      nameController.text,
                      subtitleController.text,
                      price,
                      selectedCat,
                    );
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Simpan', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SearchBarWidget(
                      onChanged: (val) => productProvider.setSearchQuery(val),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_bag_outlined, size: 28),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CartScreen()),
                          );
                        },
                      ),
                      if (cartProvider.totalItemsCount > 0)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: CircleAvatar(
                            radius: 9,
                            backgroundColor: Colors.red,
                            child: Text(
                              '${cartProvider.totalItemsCount}',
                              style: const TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          ),
                        )
                    ],
                  )
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E4D3B),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Smart Catalog',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Siap pakai & Garansi Sekolah',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Daftar Perangkat',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: ['Semua', 'Hardware', 'Aksesoris'].map((cat) {
                  final isSelected = productProvider.selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: const Color(0xFF1E4D3B),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                      onSelected: (_) => productProvider.setCategory(cat),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: productProvider.products.length,
                  itemBuilder: (context, index) {
                    final product = productProvider.products[index];
                    return ProductCard(
                      product: product,
                      onAddToCart: () => cartProvider.addToCart(product),
                      onImageTap: () => _pickImageForProduct(context, product),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1E4D3B),
        onPressed: () => _showAddProductDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
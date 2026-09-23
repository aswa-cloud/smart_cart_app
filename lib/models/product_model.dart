class ProductModel {
  final String id;
  final String name;
  final String subtitle;
  final double price;
  final String category;
  final String? imagePath;

  ProductModel({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.price,
    required this.category,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'subtitle': subtitle,
      'price': price,
      'category': category,
      'image_path': imagePath,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      name: map['name'],
      subtitle: map['subtitle'] ?? '',
      price: (map['price'] as num).toDouble(),
      category: map['category'] ?? 'Semua',
      imagePath: map['image_path'],
    );
  }
}
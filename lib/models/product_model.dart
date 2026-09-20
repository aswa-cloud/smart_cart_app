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
}
// v1.6 - models/product.dart
class Product {
  final int id;
  String name;
  double price;
  int stock;
  String? category; // optional: 'beer', 'snack', etc.

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.category,
  });

  bool get isLowStock => stock <= 5;
  bool get isOutOfStock => stock <= 0;
}

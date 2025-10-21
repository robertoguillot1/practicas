// v1.6 - services/product_service.dart
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/product.dart';

class ProductService extends ChangeNotifier {
  final List<Product> _products = [
    Product(id: 1, name: 'Cerveza Águila', price: 3500, stock: 12),
    Product(id: 2, name: 'Poker', price: 3300, stock: 6),
    Product(id: 3, name: 'Club Colombia', price: 4200, stock: 3),
  ];

  int _nextId = 4;

  // Configurable: cuando el stock <= threshold, muestra alerta
  final int lowStockThreshold = 5;

  List<Product> get products => List.unmodifiable(_products);

  Product? getById(int id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Product addProduct(String name, double price, int stock, {String? category}) {
    if (name.trim().isEmpty) {
      Fluttertoast.showToast(msg: "El nombre del producto no puede estar vacío");
      throw Exception("Nombre vacío");
    }
    if (price <= 0 || stock < 0) {
      Fluttertoast.showToast(msg: "Precio o stock inválido");
      throw Exception("Valores inválidos");
    }

    final product = Product(
      id: _nextId++, 
      name: name, 
      price: price, 
      stock: stock,
      category: category,
    );
    _products.add(product);
    notifyListeners();

    Fluttertoast.showToast(msg: "Producto agregado: ${product.name}");
    return product;
  }

  void updateProduct(Product updated) {
    final index = _products.indexWhere((p) => p.id == updated.id);
    if (index >= 0) {
      _products[index] = updated;
      notifyListeners();
      Fluttertoast.showToast(msg: "Producto actualizado: ${updated.name}");
    }
  }

  void deleteProduct(int id) {
    final product = getById(id);
    if (product != null) {
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
      Fluttertoast.showToast(
        msg: "🗑️ Producto eliminado: ${product.name}",
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
    }
  }

  void decreaseStock(int productId, int quantity) {
    final product = getById(productId);
    if (product == null || product.stock < quantity) {
      Fluttertoast.showToast(msg: "Stock insuficiente para venta");
      throw Exception("Stock insuficiente");
    }

    product.stock -= quantity;
    
    // Notificaciones automáticas
    if (product.stock == 0) {
      Fluttertoast.showToast(
        msg: "🚨 ¡AGOTADO! ${product.name} - Stock: 0",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );
    } else if (product.stock <= lowStockThreshold) {
      Fluttertoast.showToast(
        msg: "⚠️ Quedan ${product.stock} unidades de ${product.name}",
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
    }

    notifyListeners();
  }

  void increaseStock(int productId, int quantity) {
    final product = getById(productId);
    if (product != null) {
      product.stock += quantity;
      notifyListeners();
      Fluttertoast.showToast(msg: "Stock actualizado: ${product.name} → ${product.stock}");
    }
  }

  List<Product> getLowStockProducts() {
    return _products.where((p) => p.stock <= lowStockThreshold).toList();
  }

  double get totalInventoryValue {
    return _products.fold(0.0, (sum, p) => sum + (p.price * p.stock));
  }

  double get averagePrice {
    if (_products.isEmpty) return 0.0;
    return _products.fold(0.0, (sum, p) => sum + p.price) / _products.length;
  }
}

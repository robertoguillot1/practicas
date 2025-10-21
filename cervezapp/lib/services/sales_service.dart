// v1.6 - services/sales_service.dart
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../models/customer.dart';
import 'product_service.dart';
import 'customer_service.dart';

class SalesService extends ChangeNotifier {
  final ProductService productService;
  final CustomerService customerService;

  SalesService({
    required this.productService,
    required this.customerService,
  });

  final List<Sale> _sales = [];
  int _nextId = 1;

  List<Sale> get sales => List.unmodifiable(_sales);

  void registerSale(int customerId, int productId, int quantity, {String paymentType = 'Cash', String? paymentReceipt}) {
    final customer = customerId == 0 ? Customer.empty() : customerService.getById(customerId);
    final product = productService.getById(productId);

    if (customer.id == 0 && customerId != 0) {
      Fluttertoast.showToast(
        msg: "Cliente no encontrado.",
        backgroundColor: Colors.redAccent,
      );
      return;
    }

    if (product == null) {
      Fluttertoast.showToast(
        msg: "Producto no encontrado.",
        backgroundColor: Colors.redAccent,
      );
      return;
    }

    if (product.stock <= 0) {
      Fluttertoast.showToast(
        msg: "❌ NO TIENES STOCK DE ESTE PRODUCTO. SURTE TU INVENTARIO.",
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
      return;
    }

    if (product.stock < quantity) {
      Fluttertoast.showToast(
        msg: "Stock insuficiente para vender ${quantity} unidades de ${product.name}.",
        backgroundColor: Colors.orangeAccent,
        textColor: Colors.white,
      );
      return;
    }

    // Registrar la venta
    final total = product.price * quantity;
    final sale = Sale(
      id: _nextId++,
      customerId: customerId,
      productId: productId,
      quantity: quantity,
      total: total,
      date: DateTime.now(),
      paymentType: paymentType,
      paymentReceipt: paymentReceipt,
    );

    _sales.add(sale);

    // Disminuir stock
    productService.decreaseStock(productId, quantity);

    notifyListeners();

    Fluttertoast.showToast(
      msg: "✅ Venta registrada: ${product.name} x$quantity → \$${total.toStringAsFixed(0)}${customerId == 0 ? ' (Anónima)' : ''}",
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  double get totalRevenue =>
      _sales.fold(0.0, (sum, sale) => sum + sale.total);

  int get totalUnitsSold =>
      _sales.fold(0, (sum, sale) => sum + sale.quantity);

  Map<String, double> get revenueByProduct {
    final Map<String, double> data = {};
    for (var sale in _sales) {
      final product = productService.getById(sale.productId);
      if (product != null) {
        data[product.name] = (data[product.name] ?? 0) + sale.total;
      }
    }
    return data;
  }

  void updatePaymentStatus(int saleId, String newPaymentType, {String? paymentReceipt}) {
    final saleIndex = _sales.indexWhere((s) => s.id == saleId);
    if (saleIndex >= 0) {
      _sales[saleIndex].paymentType = newPaymentType;
      if (paymentReceipt != null) {
        _sales[saleIndex].paymentReceipt = paymentReceipt;
      }
      notifyListeners();
      
      Fluttertoast.showToast(
        msg: "💳 Estado de pago actualizado: ${newPaymentType}",
        backgroundColor: Colors.blue,
        textColor: Colors.white,
      );
    }
  }

  void updateSale(Sale updatedSale) {
    final saleIndex = _sales.indexWhere((s) => s.id == updatedSale.id);
    if (saleIndex >= 0) {
      _sales[saleIndex] = updatedSale;
      notifyListeners();
      
      Fluttertoast.showToast(
        msg: "✅ Venta actualizada correctamente",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    }
  }

  void deleteSale(int saleId) {
    final saleIndex = _sales.indexWhere((s) => s.id == saleId);
    if (saleIndex >= 0) {
      final sale = _sales[saleIndex];
      
      // Restaurar stock del producto
      final product = productService.getById(sale.productId);
      if (product != null) {
        productService.increaseStock(sale.productId, sale.quantity);
      }
      
      _sales.removeAt(saleIndex);
      notifyListeners();
      
      Fluttertoast.showToast(
        msg: "🗑️ Venta eliminada y stock restaurado",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void clearSales() {
    _sales.clear();
    notifyListeners();
  }
}

// v1.6 - services/sales_service.dart
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sale.dart';
import '../models/customer.dart';
import 'product_service.dart';
import 'customer_service.dart';

class SalesService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProductService productService;
  final CustomerService customerService;

  SalesService({
    required this.productService,
    required this.customerService,
  }) {
    // No iniciar automáticamente, esperar a ser llamado después de la autenticación
  }

  // Inicializar el servicio después de la autenticación
  void initialize() {
    if (_sales.isEmpty) {
      _startListening();
    }
  }

  final List<Sale> _sales = [];
  bool _isLoading = false;
  DateTime? _lastCheckedDate;

  List<Sale> get sales => List.unmodifiable(_sales);
  bool get isLoading => _isLoading;

  // Escuchar cambios en tiempo real desde Firestore
  void _startListening() {
    _isLoading = true;
    notifyListeners();

    _firestore.collection('sales').orderBy('date', descending: true).snapshots().listen(
      (snapshot) {
        _sales.clear();
        
        for (var doc in snapshot.docs) {
          final sale = Sale.fromMap(doc.data(), doc.id);
          _sales.add(sale);
        }
        
        debugPrint('Ventas cargadas desde Firestore: ${_sales.length}');
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Error listening to sales: $error');
        Fluttertoast.showToast(
          msg: "Error al cargar ventas: $error",
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Método para refrescar manualmente
  Future<void> refreshSales() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final snapshot = await _firestore.collection('sales').orderBy('date', descending: true).get();
      _sales.clear();
      
      for (var doc in snapshot.docs) {
        final sale = Sale.fromMap(doc.data(), doc.id);
        _sales.add(sale);
      }
      
      debugPrint('Ventas refrescadas: ${_sales.length}');
    } catch (e) {
      debugPrint('Error refreshing sales: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> registerSale(String? customerId, String productId, int quantity, {String paymentType = 'Cash', String? paymentReceipt}) async {
    final customer = customerId == null ? Customer.empty() : customerService.getById(customerId);
    final product = productService.getById(productId);

    if (customer.id == null && customerId != null) {
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
        msg: "Stock insuficiente para vender $quantity unidades de ${product.name}.",
        backgroundColor: Colors.orangeAccent,
        textColor: Colors.white,
      );
      return;
    }

    try {
      // Registrar la venta
      final total = product.price * quantity;
      final sale = Sale(
        date: DateTime.now(),
        customerId: customerId,
        productId: productId,
        quantity: quantity,
        total: total,
        paymentType: paymentType,
        paymentReceipt: paymentReceipt,
      );

      await _firestore.collection('sales').add(sale.toMap());
      
      // No agregar manualmente a la lista, el listener se encargará
      // _sales.insert(0, newSale); // REMOVIDO - causa duplicación

      // Disminuir stock
      await productService.decreaseStock(productId, quantity);

      // No llamar notifyListeners() aquí, el listener lo hará automáticamente
      // notifyListeners(); // REMOVIDO - causa duplicación

      Fluttertoast.showToast(
        msg: "✅ Venta registrada: ${product.name} x$quantity → \$${total.toStringAsFixed(0)}${customerId == null ? ' (Anónima)' : ''}",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      debugPrint('Error registering sale: $e');
      Fluttertoast.showToast(
        msg: "Error al registrar venta: $e",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  double get totalRevenue =>
      _sales.fold(0.0, (sum, sale) => sum + sale.total);

  int get totalUnitsSold =>
      _sales.fold(0, (sum, sale) => sum + sale.quantity);

  // Métodos para ventas del día actual
  List<Sale> get todaySales {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return _sales.where((sale) => 
      sale.date.isAfter(startOfDay) && sale.date.isBefore(endOfDay)
    ).toList();
  }

  double get todayRevenue => todaySales.fold(0.0, (sum, sale) => sum + sale.total);

  int get todayUnitsSold => todaySales.fold(0, (sum, sale) => sum + sale.quantity);

  int get todaySalesCount => todaySales.length;

  // Verificar si ha cambiado el día y notificar a los listeners
  void checkDayChange() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    if (_lastCheckedDate == null || !_lastCheckedDate!.isAtSameMomentAs(todayDate)) {
      _lastCheckedDate = todayDate;
      debugPrint('Nuevo día detectado: ${todayDate.day}/${todayDate.month}/${todayDate.year}');
      notifyListeners(); // Notificar para actualizar las estadísticas del día
    }
  }

  Map<String, double> get revenueByProduct {
    final Map<String, double> data = {};
    for (var sale in _sales) {
      final product = productService.getById(sale.productId!);
      if (product != null) {
        data[product.name] = (data[product.name] ?? 0) + sale.total;
      }
    }
    return data;
  }

  Future<void> updatePaymentStatus(String saleId, String newPaymentType, {String? paymentReceipt}) async {
    try {
      await _firestore.collection('sales').doc(saleId).update({
        'paymentType': newPaymentType,
        'paymentReceipt': paymentReceipt,
        'updatedAt': Timestamp.now(),
      });

      // No actualizar manualmente la lista, el listener se encargará
      // El listener detectará el cambio y actualizará automáticamente
      
      Fluttertoast.showToast(
        msg: "💳 Estado de pago actualizado: $newPaymentType",
        backgroundColor: Colors.blue,
        textColor: Colors.white,
      );
    } catch (e) {
      debugPrint('Error updating payment status: $e');
      Fluttertoast.showToast(
        msg: "Error al actualizar estado de pago: $e",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> updateSale(Sale updatedSale) async {
    if (updatedSale.id == null) {
      Fluttertoast.showToast(msg: "Error: ID de la venta no válido");
      return;
    }

    try {
      await _firestore.collection('sales').doc(updatedSale.id).update(updatedSale.toMap());
      
      // No actualizar manualmente la lista, el listener se encargará
      // El listener detectará el cambio y actualizará automáticamente
      
      Fluttertoast.showToast(
        msg: "✅ Venta actualizada correctamente",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      debugPrint('Error updating sale: $e');
      Fluttertoast.showToast(
        msg: "Error al actualizar venta: $e",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  // Método para borrar todas las ventas
  Future<void> deleteAllSales() async {
    try {
      // Obtener todas las ventas
      final snapshot = await _firestore.collection('sales').get();
      
      // Borrar cada venta
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
      
      debugPrint('Todas las ventas han sido borradas');
      Fluttertoast.showToast(
        msg: "✅ Todas las ventas han sido borradas",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      debugPrint('Error deleting all sales: $e');
      Fluttertoast.showToast(
        msg: "Error al borrar todas las ventas: $e",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  // Método para borrar ventas seleccionadas
  Future<void> deleteSelectedSales(List<String> saleIds) async {
    try {
      // Borrar cada venta seleccionada
      for (var saleId in saleIds) {
        await _firestore.collection('sales').doc(saleId).delete();
      }
      
      debugPrint('${saleIds.length} ventas han sido borradas');
      Fluttertoast.showToast(
        msg: "✅ ${saleIds.length} ventas han sido borradas",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      debugPrint('Error deleting selected sales: $e');
      Fluttertoast.showToast(
        msg: "Error al borrar las ventas seleccionadas: $e",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> deleteSale(String saleId) async {
    try {
      final saleIndex = _sales.indexWhere((s) => s.id == saleId);
      if (saleIndex >= 0) {
        final sale = _sales[saleIndex];
        
        // Restaurar stock del producto
        if (sale.productId != null) {
          final product = productService.getById(sale.productId!);
          if (product != null) {
            await productService.increaseStock(sale.productId!, sale.quantity);
          }
        }
        
        await _firestore.collection('sales').doc(saleId).delete();
        
        // No remover manualmente de la lista, el listener se encargará
        // _sales.removeAt(saleIndex); // REMOVIDO - causa inconsistencias
        // notifyListeners(); // REMOVIDO - el listener lo hará automáticamente
        
        Fluttertoast.showToast(
          msg: "🗑️ Venta eliminada y stock restaurado",
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error deleting sale: $e');
      Fluttertoast.showToast(
        msg: "Error al eliminar venta: $e",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> clearSales() async {
    try {
      // Eliminar todas las ventas de Firestore
      final batch = _firestore.batch();
      final snapshot = await _firestore.collection('sales').get();
      
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      
      // No limpiar manualmente la lista, el listener se encargará
      // _sales.clear(); // REMOVIDO - el listener detectará los cambios
      // notifyListeners(); // REMOVIDO - el listener lo hará automáticamente
      
      Fluttertoast.showToast(
        msg: "🗑️ Todas las ventas han sido eliminadas",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } catch (e) {
      debugPrint('Error clearing sales: $e');
      Fluttertoast.showToast(
        msg: "Error al eliminar ventas: $e",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
}

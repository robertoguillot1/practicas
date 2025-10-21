import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/sales_service.dart';
import '../../services/customer_service.dart';
import '../../services/product_service.dart';
import 'sale_form.dart';
import 'sale_edit_screen.dart';
import '../../widgets/receipt_capture_widget.dart';
import 'dart:io';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final salesService = Provider.of<SalesService>(context);
    final customerService = Provider.of<CustomerService>(context);
    final productService = Provider.of<ProductService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_shopping_cart),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SaleFormScreen()),
            ),
          ),
        ],
      ),
      body: salesService.sales.isEmpty
          ? const Center(child: Text('No hay ventas registradas'))
          : ListView.builder(
        itemCount: salesService.sales.length,
        itemBuilder: (context, i) {
          final sale = salesService.sales[i];
          final customer = customerService.getById(sale.customerId);
          final product = productService.getById(sale.productId);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: sale.isPending ? Colors.orange : Colors.green,
                child: Icon(
                  sale.isPending ? Icons.pending : Icons.check_circle,
                  color: Colors.white,
                ),
              ),
              title: Text(
                '${product?.name ?? "Producto desconocido"}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cliente: ${customer.name.isNotEmpty ? customer.name : "Venta Anónima"}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  Text(
                    'Total: \$${sale.total.toStringAsFixed(0)} | Cantidad: ${sale.quantity}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  Row(
                    children: [
                      Icon(
                        sale.paymentType == 'Cash' ? Icons.money :
                        sale.paymentType == 'Nequi' ? Icons.phone_android :
                        Icons.pending,
                        size: 16,
                        color: sale.paymentType == 'Cash' ? Colors.green :
                               sale.paymentType == 'Nequi' ? Colors.blue :
                               Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        sale.paymentType,
                        style: TextStyle(
                          color: sale.paymentType == 'Cash' ? Colors.green :
                                 sale.paymentType == 'Nequi' ? Colors.blue :
                                 Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (sale.hasReceipt) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Comprobante',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Mostrar icono de comprobante si existe
                  if (sale.hasReceipt)
                    IconButton(
                      icon: const Icon(Icons.receipt_long, color: Colors.blue),
                      onPressed: () => _showReceiptDialog(context, sale.paymentReceipt!),
                      tooltip: 'Ver comprobante',
                    ),
                  
                  // Menú de cambio de estado de pago
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (String newPaymentType) {
                      if (newPaymentType == 'Nequi' && !sale.hasReceipt) {
                        _showReceiptCaptureDialog(context, sale, salesService);
                      } else {
                        salesService.updatePaymentStatus(sale.id, newPaymentType);
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: 'Cash',
                        child: ListTile(
                          leading: Icon(Icons.money, color: Colors.green),
                          title: Text('Efectivo'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Nequi',
                        child: ListTile(
                          leading: Icon(Icons.phone_android, color: Colors.blue),
                          title: Text('Nequi'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Pending',
                        child: ListTile(
                          leading: Icon(Icons.pending, color: Colors.orange),
                          title: Text('Pendiente'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Información detallada
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.info_outline, size: 20, color: Colors.blue),
                                const SizedBox(width: 8),
                                const Text(
                                  'Detalles de la Venta',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow('📦 Producto', product?.name ?? "Desconocido"),
                            _buildDetailRow('👤 Cliente', customer.name.isNotEmpty ? customer.name : "Venta Anónima"),
                            _buildDetailRow('📊 Cantidad', '${sale.quantity} unidades'),
                            _buildDetailRow('💰 Precio Unitario', '\$${product?.price.toStringAsFixed(0) ?? "0"}'),
                            _buildDetailRow('💵 Total', '\$${sale.total.toStringAsFixed(0)}'),
                            _buildDetailRow('📅 Fecha', '${sale.date.day}/${sale.date.month}/${sale.date.year}'),
                            _buildDetailRow('💳 Método de Pago', sale.paymentType),
                            if (sale.hasReceipt)
                              _buildDetailRow('📄 Comprobante', 'Disponible', isReceipt: true),
                          ],
                        ),
                      ),
                      
                      // Botones de acción
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (sale.hasReceipt)
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _showReceiptDialog(context, sale.paymentReceipt!),
                                icon: const Icon(Icons.receipt_long),
                                label: const Text('Ver Comprobante'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          if (sale.hasReceipt) const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SaleEditScreen(sale: sale),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text('Editar'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static Widget _buildDetailRow(String label, String value, {bool isReceipt = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: isReceipt
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '📄 Ver Comprobante',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  )
                : Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
          ),
        ],
      ),
    );
  }

  static void _showReceiptDialog(BuildContext context, String receiptPath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: const Text('Comprobante de Pago'),
                backgroundColor: Colors.transparent,
                elevation: 0,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(receiptPath),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, color: Colors.red, size: 64),
                            SizedBox(height: 16),
                            Text('Error al cargar el comprobante'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _showReceiptCaptureDialog(BuildContext context, sale, SalesService salesService) {
    String? receiptPath;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('📷 Agregar Comprobante Nequi'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 400,
              maxHeight: 500,
            ),
            child: SingleChildScrollView(
              child: ReceiptCaptureWidget(
                onReceiptChanged: (path) {
                  receiptPath = path;
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                salesService.updatePaymentStatus(sale.id, 'Nequi', paymentReceipt: receiptPath);
                Navigator.pop(context);
              },
              child: const Text('Confirmar'),
            ),
          ],
        ),
      ),
    );
  }
}

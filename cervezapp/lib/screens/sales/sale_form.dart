import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/sales_service.dart';
import '../../services/product_service.dart';
import '../../services/customer_service.dart';
import '../../widgets/receipt_capture_widget.dart';

class SaleFormScreen extends StatefulWidget {
  const SaleFormScreen({super.key});

  @override
  State<SaleFormScreen> createState() => _SaleFormScreenState();
}

class _SaleFormScreenState extends State<SaleFormScreen> {
  int? selectedProductId;
  int? selectedCustomerId;
  int quantity = 1;
  String paymentType = 'Cash';
  bool isAnonymousSale = false;
  String? paymentReceipt;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductService>(context);
    final customerService = Provider.of<CustomerService>(context);
    final salesService = Provider.of<SalesService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Venta')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<int>(
                value: selectedProductId,
                items: productService.products
                    .where((p) => p.stock > 0) // Solo productos con stock
                    .map((p) => DropdownMenuItem(
                  value: p.id,
                  child: Text('${p.name} (\$${p.price.toStringAsFixed(0)}) - Stock: ${p.stock}'),
                ))
                    .toList(),
                onChanged: (v) => setState(() => selectedProductId = v),
                decoration: const InputDecoration(labelText: 'Producto'),
                validator: (v) => v == null ? 'Seleccione un producto' : null,
              ),
              const SizedBox(height: 16),
              
              // Opción de venta anónima
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person_outline, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          const Text(
                            'Selección de Cliente',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      CheckboxListTile(
                        title: const Text('Venta Anónima'),
                        subtitle: const Text('No asignar a ningún cliente específico'),
                        value: isAnonymousSale,
                        onChanged: (value) {
                          setState(() {
                            isAnonymousSale = value ?? false;
                            if (isAnonymousSale) {
                              selectedCustomerId = null;
                            }
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      if (!isAnonymousSale) ...[
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: selectedCustomerId,
                          items: customerService.customers
                              .map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ))
                              .toList(),
                          onChanged: (v) => setState(() => selectedCustomerId = v),
                          decoration: const InputDecoration(
                            labelText: 'Seleccionar Cliente',
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (v) => !isAnonymousSale && v == null ? 'Seleccione un cliente' : null,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: '1',
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Cantidad'),
                validator: (v) {
                  final qty = int.tryParse(v ?? '');
                  if (qty == null || qty <= 0) {
                    return 'Ingrese una cantidad válida';
                  }
                  return null;
                },
                onChanged: (v) => quantity = int.tryParse(v) ?? 1,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: paymentType,
                items: const [
                  DropdownMenuItem(value: 'Cash', child: Text('Efectivo')),
                  DropdownMenuItem(value: 'Nequi', child: Text('Nequi')),
                  DropdownMenuItem(value: 'Pending', child: Text('Pendiente')),
                ],
                onChanged: (v) => setState(() => paymentType = v ?? 'Cash'),
                decoration: const InputDecoration(
                  labelText: 'Método de Pago',
                  prefixIcon: Icon(Icons.payment),
                ),
              ),
              
              // Comprobante de pago para Nequi
              if (paymentType == 'Nequi') ...[
                const SizedBox(height: 16),
                ReceiptCaptureWidget(
                  initialReceiptPath: paymentReceipt,
                  onReceiptChanged: (receiptPath) {
                    setState(() => paymentReceipt = receiptPath);
                  },
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Registrar Venta'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (selectedProductId != null && (isAnonymousSale || selectedCustomerId != null)) {
                      // Para ventas anónimas, usar ID 0 (cliente vacío)
                      final customerId = isAnonymousSale ? 0 : selectedCustomerId!;
                      
                      salesService.registerSale(
                        customerId,
                        selectedProductId!,
                        quantity,
                        paymentType: paymentType,
                        paymentReceipt: paymentReceipt,
                      );
                      Navigator.pop(context);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

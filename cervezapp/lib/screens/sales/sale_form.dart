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
  String? selectedProductId;
  String? selectedCustomerId;
  int quantity = 1;
  String paymentType = 'Cash';
  bool isAnonymousSale = false;
  String? paymentReceipt;
  final _formKey = GlobalKey<FormState>();
  
  // Variables para cálculo de cambio
  final TextEditingController _cashReceivedController = TextEditingController();
  double? _changeAmount;

  @override
  void dispose() {
    _cashReceivedController.dispose();
    super.dispose();
  }

  // Calcular el total de la venta
  double _calculateTotal() {
    if (selectedProductId == null) return 0.0;
    final productService = Provider.of<ProductService>(context, listen: false);
    final product = productService.getById(selectedProductId!);
    if (product == null) return 0.0;
    return product.price * quantity;
  }

  // Calcular el cambio
  void _calculateChange() {
    final cashReceived = double.tryParse(_cashReceivedController.text) ?? 0.0;
    final total = _calculateTotal();
    setState(() {
      _changeAmount = cashReceived - total;
    });
  }

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductService>(context);
    final customerService = Provider.of<CustomerService>(context);
    final salesService = Provider.of<SalesService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Venta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: selectedProductId,
                items: productService.products
                    .where((p) => p.stock > 0) // Solo productos con stock
                    .map((p) => DropdownMenuItem<String>(
                  value: p.id,
                  child: Text('${p.name} (\$${p.price.toStringAsFixed(0)}) - Stock: ${p.stock}'),
                ))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    selectedProductId = v;
                    _calculateChange(); // Recalcular cuando cambie el producto
                  });
                },
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
                        DropdownButtonFormField<String>(
                          value: selectedCustomerId,
                          items: customerService.customers
                              .map((c) => DropdownMenuItem<String>(
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
                onChanged: (v) {
                  setState(() {
                    quantity = int.tryParse(v) ?? 1;
                    _calculateChange(); // Recalcular cuando cambie la cantidad
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: paymentType,
                items: const [
                  DropdownMenuItem(value: 'Cash', child: Text('Efectivo')),
                  DropdownMenuItem(value: 'Nequi', child: Text('Nequi')),
                  DropdownMenuItem(value: 'Pending', child: Text('Pendiente')),
                ],
                onChanged: (v) {
                  setState(() {
                    paymentType = v ?? 'Cash';
                    if (paymentType != 'Cash') {
                      _cashReceivedController.clear();
                      _changeAmount = null;
                    }
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Método de Pago',
                  prefixIcon: Icon(Icons.payment),
                ),
              ),
              
              // Calculadora de cambio para efectivo
              if (paymentType == 'Cash') ...[
                const SizedBox(height: 16),
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calculate, color: Colors.green.shade700),
                            const SizedBox(width: 8),
                            const Text(
                              'Calculadora de Cambio',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Mostrar total
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total a pagar:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '\$${_calculateTotal().toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Campo para dinero recibido
                        TextFormField(
                          controller: _cashReceivedController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Dinero recibido',
                            prefixIcon: Icon(Icons.money),
                            hintText: 'Ingrese la cantidad que le dieron',
                          ),
                          onChanged: (value) => _calculateChange(),
                        ),
                        const SizedBox(height: 12),
                        
                        // Mostrar cambio
                        if (_changeAmount != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _changeAmount! >= 0 ? Colors.green.shade50 : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _changeAmount! >= 0 ? Colors.green.shade200 : Colors.red.shade200,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _changeAmount! >= 0 ? 'Cambio a dar:' : 'Falta dinero:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _changeAmount! >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                                  ),
                                ),
                                Text(
                                  '\$${_changeAmount!.abs().toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _changeAmount! >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_changeAmount! < 0) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.orange.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.warning, color: Colors.orange.shade700, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'El cliente no ha dado suficiente dinero',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ],
              
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Registrar Venta'),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (selectedProductId != null && (isAnonymousSale || selectedCustomerId != null)) {
                        // Para ventas anónimas, usar null (cliente vacío)
                        final customerId = isAnonymousSale ? null : selectedCustomerId;
                        
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
              ),
              const SizedBox(height: 24), // Espacio adicional al final
            ],
          ),
        ),
      ),
    );
  }
}

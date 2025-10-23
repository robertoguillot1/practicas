// v1.6 - screens/sales/sale_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/sales_service.dart';
import '../../services/customer_service.dart';
import '../../services/product_service.dart';
import '../../models/sale.dart';
import '../../theme/app_colors.dart';

class SaleEditScreen extends StatefulWidget {
  final Sale sale;
  
  const SaleEditScreen({super.key, required this.sale});

  @override
  State<SaleEditScreen> createState() => _SaleEditScreenState();
}

class _SaleEditScreenState extends State<SaleEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _quantityController;
  late TextEditingController _totalController;
  String _selectedPaymentType = 'Cash';
  String? _selectedCustomerId;
  String? _selectedProductId;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: widget.sale.quantity.toString());
    _totalController = TextEditingController(text: widget.sale.total.toStringAsFixed(0));
    _selectedPaymentType = widget.sale.paymentType;
    // Asegurar que el valor del cliente sea válido para el dropdown
    _selectedCustomerId = widget.sale.customerId;
    _selectedProductId = widget.sale.productId;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final salesService = Provider.of<SalesService>(context, listen: false);
    final customerService = Provider.of<CustomerService>(context, listen: false);
    final productService = Provider.of<ProductService>(context, listen: false);

    final customers = customerService.customers;
    final products = productService.products;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Venta'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showDeleteDialog(context, salesService),
            tooltip: 'Eliminar venta',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Información de la venta original
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Text(
                            'Información Original',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('ID: ${widget.sale.id}'),
                      Text('Fecha: ${widget.sale.date.day}/${widget.sale.date.month}/${widget.sale.date.year}'),
                      if (widget.sale.hasReceipt)
                        const Text('📄 Tiene comprobante adjunto'),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Cliente
              DropdownButtonFormField<String>(
                value: _selectedCustomerId,
                decoration: const InputDecoration(
                  labelText: 'Cliente',
                  border: OutlineInputBorder(),
                ),
                items: [
                  // Opción para venta anónima
                  const DropdownMenuItem<String>(
                    value: '0',
                    child: Text('Venta Anónima'),
                  ),
                  // Clientes registrados (solo IDs no nulos)
                  ...customers.where((customer) => customer.id != null).map((customer) {
                    return DropdownMenuItem<String>(
                      value: customer.id.toString(),
                      child: Text(customer.name.isNotEmpty ? customer.name : 'Cliente ${customer.id}'),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCustomerId = value;
                  });
                },
                validator: (value) => value == null ? 'Seleccione un cliente' : null,
              ),
              
              const SizedBox(height: 16),
              
              // Producto
              DropdownButtonFormField<String>(
                value: _selectedProductId,
                decoration: const InputDecoration(
                  labelText: 'Producto',
                  border: OutlineInputBorder(),
                ),
                items: products.map((product) {
                  return DropdownMenuItem<String>(
                    value: product.id.toString(),
                    child: Text('${product.name} - \$${product.price.toStringAsFixed(0)}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProductId = value;
                    _updateTotal();
                  });
                },
                validator: (value) => value == null ? 'Seleccione un producto' : null,
              ),
              
              const SizedBox(height: 16),
              
              // Cantidad
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Cantidad',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => _updateTotal(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese la cantidad';
                  }
                  final quantity = int.tryParse(value);
                  if (quantity == null || quantity <= 0) {
                    return 'La cantidad debe ser mayor a 0';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Total (calculado automáticamente)
              TextFormField(
                controller: _totalController,
                decoration: const InputDecoration(
                  labelText: 'Total',
                  border: OutlineInputBorder(),
                  suffixText: 'COP',
                ),
                keyboardType: TextInputType.number,
                readOnly: true,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Método de pago
              DropdownButtonFormField<String>(
                value: _selectedPaymentType,
                decoration: const InputDecoration(
                  labelText: 'Método de Pago',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Cash', child: Text('Efectivo')),
                  DropdownMenuItem(value: 'Nequi', child: Text('Nequi')),
                  DropdownMenuItem(value: 'Pending', child: Text('Pendiente')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentType = value!;
                  });
                },
                validator: (value) => value == null ? 'Seleccione un método de pago' : null,
              ),
              
              const SizedBox(height: 24),
              
              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                      ),
                      child: const Text('Guardar Cambios'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24), // Espacio adicional al final
            ],
          ),
        ),
      ),
    );
  }

  void _updateTotal() {
    if (_selectedProductId != null && _quantityController.text.isNotEmpty) {
      final productService = Provider.of<ProductService>(context, listen: false);
      final product = productService.getById(_selectedProductId!);
      
      if (product != null) {
        final quantity = int.tryParse(_quantityController.text) ?? 0;
        final total = product.price * quantity;
        _totalController.text = total.toStringAsFixed(0);
      }
    }
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final salesService = Provider.of<SalesService>(context, listen: false);
      
      final updatedSale = Sale(
        id: widget.sale.id,
        date: widget.sale.date,
        customerId: _selectedCustomerId,
        productId: _selectedProductId!,
        quantity: int.parse(_quantityController.text),
        total: double.parse(_totalController.text),
        paymentType: _selectedPaymentType,
        paymentReceipt: widget.sale.paymentReceipt, // Mantener el comprobante original
      );
      
      salesService.updateSale(updatedSale);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Venta actualizada correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context);
    }
  }

  void _showDeleteDialog(BuildContext context, SalesService salesService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🗑️ Eliminar Venta'),
        content: const Text('¿Estás seguro de que quieres eliminar esta venta? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (widget.sale.id != null) {
                salesService.deleteSale(widget.sale.id!);
                Navigator.pop(context); // Cerrar diálogo
                Navigator.pop(context); // Volver a la lista de ventas
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🗑️ Venta eliminada'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}


// v1.6 - screens/customers/customer_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/customer.dart';
import '../../models/sale.dart';
import '../../models/product.dart';
import '../../services/customer_service.dart';
import '../../services/sales_service.dart';
import '../../services/product_service.dart';
import '../../theme/app_colors.dart';
import 'customer_form.dart';

class CustomerDetailScreen extends StatelessWidget {
  final Customer customer;
  
  const CustomerDetailScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    final salesService = Provider.of<SalesService>(context);
    final productService = Provider.of<ProductService>(context);
    
    // Obtener todas las ventas de este cliente
    final customerSales = salesService.sales
        .where((sale) => sale.customerId == customer.id)
        .toList();
    
    // Calcular totales
    final totalConsumption = customerSales
        .where((sale) => sale.paymentType != 'Pending')
        .fold(0.0, (sum, sale) => sum + sale.total);
    
    final totalDebt = customerSales
        .where((sale) => sale.paymentType == 'Pending')
        .fold(0.0, (sum, sale) => sum + sale.total);
    
    final totalPurchases = customerSales.length;
    final pendingPurchases = customerSales.where((sale) => sale.paymentType == 'Pending').length;

    return Scaffold(
      appBar: AppBar(
        title: Text(customer.name.isNotEmpty ? customer.name : 'Cliente ${customer.id}'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CustomerForm(customer: customer),
                ),
              );
            },
            tooltip: 'Editar cliente',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del cliente
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Text(
                            customer.name.isNotEmpty 
                                ? customer.name[0].toUpperCase() 
                                : 'C',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customer.name.isNotEmpty ? customer.name : 'Cliente ${customer.id}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (customer.email != null && customer.email!.isNotEmpty)
                                Text(
                                  customer.email!,
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              if (customer.phone != null && customer.phone!.isNotEmpty)
                                Text(
                                  customer.phone!,
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Resumen financiero
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.analytics, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text(
                          'Resumen Financiero',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Estadísticas
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Consumido',
                            '\$${totalConsumption.toStringAsFixed(0)}',
                            Colors.green,
                            Icons.shopping_cart,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            'Deuda Pendiente',
                            '\$${totalDebt.toStringAsFixed(0)}',
                            Colors.red,
                            Icons.credit_card,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Compras Totales',
                            '$totalPurchases',
                            Colors.blue,
                            Icons.receipt,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            'Pendientes',
                            '$pendingPurchases',
                            Colors.orange,
                            Icons.pending,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Historial de compras
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.history, color: Colors.purple),
                        const SizedBox(width: 8),
                        const Text(
                          'Historial de Compras',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${customerSales.length} compras',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    if (customerSales.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No hay compras registradas',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: customerSales.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final sale = customerSales[index];
                          final product = productService.getById(sale.productId);
                          
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: sale.paymentType == 'Cash' ? Colors.green :
                                             sale.paymentType == 'Nequi' ? Colors.blue :
                                             Colors.orange,
                              child: Icon(
                                sale.paymentType == 'Cash' ? Icons.money :
                                sale.paymentType == 'Nequi' ? Icons.phone_android :
                                Icons.pending,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              product?.name ?? 'Producto desconocido',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Cantidad: ${sale.quantity} | Total: \$${sale.total.toStringAsFixed(0)}'),
                                Text(
                                  '${sale.date.day}/${sale.date.month}/${sale.date.year}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: sale.paymentType == 'Cash' ? Colors.green :
                                           sale.paymentType == 'Nequi' ? Colors.blue :
                                           Colors.orange,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    sale.paymentType,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (sale.hasReceipt)
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Comprobante',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

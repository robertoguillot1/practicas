import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/customer.dart';
import '../../services/customer_service.dart';
import 'customer_form.dart';
import 'customer_detail_screen.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final customerService = Provider.of<CustomerService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CustomerForm()),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: customerService.customers.length,
        itemBuilder: (context, i) {
          final c = customerService.customers[i];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text(
                  c.name.isNotEmpty ? c.name[0].toUpperCase() : 'C',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                c.name.isNotEmpty ? c.name : 'Cliente ${c.id}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${c.email} • ${c.phone}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.analytics, color: Colors.blue),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CustomerDetailScreen(customer: c)),
                    ),
                    tooltip: 'Ver historial',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => customerService.deleteCustomer(c.id),
                    tooltip: 'Eliminar cliente',
                  ),
                ],
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CustomerForm(customer: c)),
              ),
            ),
          );
        },
      ),
    );
  }
}

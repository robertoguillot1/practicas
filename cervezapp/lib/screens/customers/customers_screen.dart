import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/customer_service.dart';
import 'customer_form.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final customerService = Provider.of<CustomerService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [
          Consumer<CustomerService>(
            builder: (context, customerService, child) {
              return IconButton(
                icon: customerService.isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.refresh),
                onPressed: customerService.isLoading ? null : () {
                  customerService.refreshCustomers();
                },
                tooltip: 'Refrescar clientes',
              );
            },
          ),
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
          return ListTile(
            leading: const Icon(Icons.person),
            title: Text(c.name),
            subtitle: Text('${c.email} • ${c.phone}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () {
                if (c.id != null) {
                  customerService.deleteCustomer(c.id!);
                }
              },
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CustomerForm(customer: c)),
            ),
          );
        },
      ),
    );
  }
}

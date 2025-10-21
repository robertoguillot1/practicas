import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.deepPurple,
            ),
            child: Center(
              child: Text(
                'CervezApp 🍻',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
            ),
          ),
          _buildItem(Icons.home, 'Inicio', '/', context),
          _buildItem(Icons.inventory_2, 'Productos', '/products', context),
          _buildItem(Icons.shopping_cart, 'Ventas', '/sales', context),
          _buildItem(Icons.people, 'Clientes', '/customers', context),
          _buildItem(Icons.bar_chart, 'Estadísticas', '/stats', context),
          const Divider(),
          _buildItem(Icons.info, 'Acerca de', '/about', context),
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, String title, String route, BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        if (route == '/') {
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        } else {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }
}

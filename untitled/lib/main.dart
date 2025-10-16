import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/ventas_screen.dart';
import 'screens/productos_screen.dart';
import 'screens/estadisticas_screen.dart';
import 'screens/configuracion_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(CervezApp());
}

class CervezApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CervezApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    VentasScreen(),
    ProductosScreen(),
    EstadisticasScreen(),
    ConfiguracionScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Ventas'),
          BottomNavigationBarItem(icon: Icon(Icons.local_drink), label: 'Productos'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Estadísticas'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Config.'),
        ],
      ),
    );
  }
}

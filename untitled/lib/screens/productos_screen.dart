import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../utils/formatters.dart';

class ProductosScreen extends StatefulWidget {
  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  List<Producto> productos = [
    Producto(nombre: 'Poker', precio: 3500, cantidad: 12),
    Producto(nombre: 'Águila', precio: 3300, cantidad: 8),
    Producto(nombre: 'Coronita', precio: 5000, cantidad: 15),
  ];

  void agregarProducto(Producto nuevo) {
    setState(() {
      productos.add(nuevo);
    });
  }

  void editarProducto(int index, Producto actualizado) {
    setState(() {
      productos[index] = actualizado;
    });
  }

  void eliminarProducto(int index) {
    setState(() {
      productos.removeAt(index);
    });
  }

  void mostrarFormularioAgregar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductoFormPage(
          onSave: (nuevoProducto) {
            agregarProducto(nuevoProducto);
          },
        ),
      ),
    );
  }

  void mostrarFormularioEditar(int index, Producto producto) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductoFormPage(
          producto: producto,
          onSave: (actualizado) {
            editarProducto(index, actualizado);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Cervezas'),
        backgroundColor: Colors.amber[800],
      ),
      body: ListView.builder(
        itemCount: productos.length,
        itemBuilder: (context, index) {
          final producto = productos[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(producto.nombre,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                'Precio: ${formatCurrency(producto.precio)}  |  Stock: ${producto.cantidad}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => mostrarFormularioEditar(index, producto),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => eliminarProducto(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber[800],
        child: const Icon(Icons.add),
        onPressed: mostrarFormularioAgregar,
      ),
    );
  }
}

class ProductoFormPage extends StatefulWidget {
  final Producto? producto;
  final Function(Producto) onSave;

  const ProductoFormPage({super.key, this.producto, required this.onSave});

  @override
  State<ProductoFormPage> createState() => _ProductoFormPageState();
}

class _ProductoFormPageState extends State<ProductoFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nombreController;
  late TextEditingController precioController;
  late TextEditingController cantidadController;

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(text: widget.producto?.nombre ?? '');
    precioController = TextEditingController(
        text: widget.producto?.precio.toString() ?? '');
    cantidadController = TextEditingController(
        text: widget.producto?.cantidad.toString() ?? '');
  }

  void guardarProducto() {
    if (_formKey.currentState!.validate()) {
      final nuevo = Producto(
        nombre: nombreController.text,
        precio: double.tryParse(precioController.text) ?? 0,
        cantidad: int.tryParse(cantidadController.text) ?? 0,
      );
      widget.onSave(nuevo);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.producto != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar Cerveza' : 'Agregar Cerveza'),
        backgroundColor: Colors.amber[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese un nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: precioController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Precio'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese un precio';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: cantidadController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Cantidad'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese la cantidad';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[800],
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                ),
                onPressed: guardarProducto,
                child: Text(esEdicion ? 'Actualizar' : 'Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

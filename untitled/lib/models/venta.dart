class Venta {
  final String cerveza;
  final int cantidad;
  final String metodoPago;
  final double total;
  final DateTime fecha;

  Venta({
    required this.cerveza,
    required this.cantidad,
    required this.metodoPago,
    required this.total,
    required this.fecha,
  });
}

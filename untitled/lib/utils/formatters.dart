import 'package:intl/intl.dart';

/// Formatea un número a formato de moneda en pesos colombianos
String formatCurrency(double value) {
  final format = NumberFormat.currency(locale: 'es_CO', symbol: '\$');
  return format.format(value);
}

/// Formatea una fecha a formato legible: dd/MM/yyyy – hh:mm a
String formatDate(DateTime date) {
  final format = DateFormat('dd/MM/yyyy – hh:mm a');
  return format.format(date);
}

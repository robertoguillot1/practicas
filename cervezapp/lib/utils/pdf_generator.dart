import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/sale.dart';
import '../models/customer.dart';
import '../models/product.dart';
import '../services/customer_service.dart';
import '../services/product_service.dart';
import 'formatters.dart';

class PdfGenerator {
  static Future<File> generateSalesReport(
    List<Sale> sales,
    CustomerService customerService,
    ProductService productService,
  ) async {
    // Crear un archivo de texto simple ya que no tenemos la dependencia pdf
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/sales_report.txt');
    
    final buffer = StringBuffer();
    buffer.writeln('=== REPORTE DE VENTAS ===');
    buffer.writeln('Generado: ${formatDate(DateTime.now())}');
    buffer.writeln('');
    buffer.writeln('ID\tCliente\tProducto\tFecha\tTotal\tEstado');
    buffer.writeln('-' * 80);
    
    for (var sale in sales) {
      final customer = customerService.getById(sale.customerId);
      final product = productService.getById(sale.productId);
      
      buffer.writeln([
        sale.id,
        customer.name.isNotEmpty ? customer.name : 'Cliente desconocido',
        product?.name ?? 'Producto desconocido',
        formatDate(sale.date),
        formatCurrency(sale.total),
        sale.isPending ? 'Pendiente' : 'Pagado'
      ].join('\t'));
    }
    
    buffer.writeln('');
    buffer.writeln('Total de ventas: ${sales.length}');
    buffer.writeln('Total ingresos: ${formatCurrency(sales.fold(0.0, (sum, sale) => sum + sale.total))}');
    
    await file.writeAsString(buffer.toString());
    return file;
  }
}

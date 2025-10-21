import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/sale.dart';
import '../models/customer.dart';
import '../models/product.dart';
import '../services/customer_service.dart';
import '../services/product_service.dart';
import 'formatters.dart';

class ExcelGenerator {
  static Future<File> generateSalesExcel(
    List<Sale> sales,
    CustomerService customerService,
    ProductService productService,
  ) async {
    // Crear un archivo CSV simple ya que no tenemos la dependencia excel
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/sales_report.csv');
    
    final buffer = StringBuffer();
    buffer.writeln('ID,Cliente,Producto,Fecha,Total,Estado');
    
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
      ].join(','));
    }
    
    await file.writeAsString(buffer.toString());
    return file;
  }
}

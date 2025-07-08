import 'dart:io';
import 'table_service.dart';

class BillingService {
  static Future<void> generateBill(int tableId) async {
    final tables = await TableService.loadTables();
    final table = tables.firstWhere((t) => t.id == tableId);

    if (!table.isOccupied) {
      throw Exception('Table $tableId is not occupied');
    }

    final invoice =
        '''
=== INVOICE ===
Table: $tableId
Date: ${DateTime.now()}

Orders:
${table.orders.map((o) => '${o.itemName} x${o.quantity} - \$${o.total}').join('\n')}

Total: \$${table.orders.fold(0.0, (sum, order) => sum + order.total)}
''';

    final invoiceDir = Directory('data/invoices');
    if (!await invoiceDir.exists()) await invoiceDir.create();

    final invoiceFile = File('data/invoices/table_$tableId.txt');
    await invoiceFile.writeAsString(invoice);

    await TableService.freeTable(tableId);
  }
}

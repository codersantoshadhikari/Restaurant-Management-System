import 'dart:io';
import '../models/menu_item.dart';
import '../models/table.dart';
import '../models/inventory_item.dart';
import 'menu_service.dart';
import 'table_service.dart';
import 'inventory_service.dart';

class ReportService {
  /// Generates both TXT and CSV daily reports
  static Future<void> generateDailyReport() async {
    final tables = await TableService.loadTables();
    final menu = await MenuService.getMenu();
    final inventory = await InventoryService.getInventory();

    // Generate text report
    await _generateTextReport(tables, menu, inventory);

    // Generate CSV sales report
    await _generateSalesReportCSV(tables);
  }

  /// Generates inventory-specific report
  static Future<void> generateInventoryReport() async {
    final inventory = await InventoryService.getInventory();
    final reportContent =
        '''
=== INVENTORY REPORT ===
Date: ${DateTime.now()}

ITEMS:
${inventory.map((i) => '${i.name.padRight(20)} ${i.quantity.toString().padLeft(5)}${i.unit}').join('\n')}
''';

    await _ensureReportsDirectory();
    final reportFile = File(
      'data/invoices/inventory_report_${_timestamp()}.txt',
    );
    await reportFile.writeAsString(reportContent);
  }

  // ========================
  // PRIVATE HELPERS
  // ========================

  static Future<void> _generateTextReport(
    List<Table> tables,
    List<MenuItem> menu,
    List<InventoryItem> inventory,
  ) async {
    final reportContent =
        '''
=== DAILY REPORT ===
Date: ${DateTime.now()}

TABLES STATUS:
${tables.map((t) => 'Table ${t.id}: ${t.isOccupied ? 'Occupied' : 'Available'}').join('\n')}

MENU ITEMS:
${menu.map((i) => '${i.name} - \$${i.price} (${i.isAvailable ? 'Available' : 'Unavailable'})').join('\n')}

INVENTORY:
${inventory.map((i) => '${i.name}: ${i.quantity}${i.unit}').join('\n')}
''';

    await _ensureReportsDirectory();
    final reportFile = File('data/invoices/daily_report_${_timestamp()}.txt');
    await reportFile.writeAsString(reportContent);
  }

  static Future<void> _generateSalesReportCSV(List<Table> tables) async {
    final csvLines = <String>[];

    // Header row
    csvLines.add('TableID,ItemName,Quantity,UnitPrice,Total,Date');

    // Data rows
    final now = DateTime.now();
    for (final table in tables) {
      for (final order in table.orders) {
        csvLines.add(
          [
            table.id.toString(),
            _escapeCsv(order.itemName),
            order.quantity.toString(),
            order.price.toStringAsFixed(2),
            order.total.toStringAsFixed(2),
            _formatDate(now),
          ].join(','),
        );
      }
    }

    await _ensureReportsDirectory();
    final csvFile = File('data/invoices/sales_report.csv');
    await csvFile.writeAsString(csvLines.join('\n'));
  }

  static String _escapeCsv(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String _timestamp() =>
      DateTime.now().millisecondsSinceEpoch.toString();

  static Future<void> _ensureReportsDirectory() async {
    final dir = Directory('data/invoices');
    if (!await dir.exists()) await dir.create();
  }
}

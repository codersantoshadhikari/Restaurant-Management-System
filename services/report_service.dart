import 'dart:io';
import '../models/menu_item.dart';
import '../models/table.dart';
import '../models/inventory_item.dart';
import 'menu_service.dart';
import 'table_service.dart';
import 'inventory_service.dart';

class ReportService {
  /// Generates both TXT and CSV daily reports for a specific branch
  static Future<void> generateDailyReport(String branch) async {
    final tables = await TableService.loadTables();
    final menu = await MenuService.getMenu();
    final inventory = await InventoryService.getInventory(branch);

    // Generate text report
    await _generateTextReport(branch, tables, menu, inventory);

    // Generate CSV sales report
    await _generateSalesReportCSV(branch, tables);
  }

  /// Generates inventory-specific report for a branch
  static Future<void> generateInventoryReport(String branch) async {
    final inventory = await InventoryService.getInventory(branch);
    final reportContent =
        '''
=== INVENTORY REPORT ===
Branch: ${branch.toUpperCase()}
Date: ${DateTime.now()}

ITEMS:
${inventory.map((i) => '${i.item.padRight(20)} ${i.quantity.toString().padLeft(5)}${i.unit}').join('\n')}
''';

    await _ensureReportsDirectory(branch);
    final reportFile = File(
      'data/branches/$branch/reports/inventory_report_${_timestamp()}.txt',
    );
    await reportFile.writeAsString(reportContent);
  }

  /*Private Helpers */

  static Future<void> _generateTextReport(
    String branch,
    List<Table> tables,
    List<MenuItem> menu,
    List<InventoryItem> inventory,
  ) async {
    final reportContent =
        '''
=== DAILY REPORT ===
Branch: ${branch.toUpperCase()}
Date: ${DateTime.now()}

TABLES STATUS:
${tables.map((t) => 'Table ${t.id}: ${t.isOccupied ? 'Occupied' : 'Available'}').join('\n')}

MENU ITEMS:
${menu.map((i) => '${i.name} - \$${i.price} (${i.isAvailable ? 'Available' : 'Unavailable'})').join('\n')}

INVENTORY:
${inventory.map((i) => '${i.item}: ${i.quantity}${i.unit}').join('\n')}
''';

    await _ensureReportsDirectory(branch);
    final reportFile = File(
      'data/branches/$branch/reports/daily_report_${_timestamp()}.txt',
    );
    await reportFile.writeAsString(reportContent);
  }

  static Future<void> _generateSalesReportCSV(
    String branch,
    List<Table> tables,
  ) async {
    final csvLines = <String>[];

    // Header row
    csvLines.add('Branch,TableID,ItemName,Quantity,UnitPrice,Total,Date');

    // Data rows
    final now = DateTime.now();
    for (final table in tables) {
      for (final order in table.orders) {
        csvLines.add(
          [
            branch,
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

    await _ensureReportsDirectory(branch);
    final csvFile = File(
      'data/branches/$branch/reports/sales_report_${_timestamp()}.csv',
    );
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

  static Future<void> _ensureReportsDirectory(String branch) async {
    final dir = Directory('data/branches/$branch/reports');
    if (!await dir.exists()) await dir.create(recursive: true);
  }
}

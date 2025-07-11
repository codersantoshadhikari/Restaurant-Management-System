import 'dart:io';
import '../models/menu_item.dart';
import '../models/table.dart';
import '../models/inventory_item.dart';
import 'menu_service.dart';
import 'table_service.dart';
import 'inventory_service.dart';

class ReportService {
  static const String _centralReportFile = 'data/sales_report.csv';

  /// Generates both TXT and CSV daily reports for a specific branch
  static Future<void> generateDailyReport(String branch) async {
    final tables = await TableService.loadTables();
    final menu = await MenuService.getMenu();
    final inventory = await InventoryService.getInventory(branch);

    // Generate reports in branch directory
    await _generateTableReports(branch, tables, menu, inventory);
    await _generateSalesReportCSV(branch, tables);

    // Also append to central sales report
    await _appendToCentralReport(branch, tables);
  }

  /// Generates individual table reports that append to existing files
  static Future<void> _generateTableReports(
    String branch,
    List<Table> tables,
    List<MenuItem> menu,
    List<InventoryItem> inventory,
  ) async {
    await _ensureTableReportsDirectory(branch);

    for (final table in tables) {
      final reportContent =
          '''
=== TABLE ${table.id} DAILY REPORT ===
Date: ${DateTime.now()}
Status: ${table.isOccupied ? 'Occupied' : 'Available'}

ORDERS:
${table.orders.map((o) => '${o.itemName} x${o.quantity} = \$${o.total}').join('\n')}

INVENTORY STATUS:
${inventory.map((i) => '${i.item}: ${i.quantity}${i.unit}').join('\n')}

'''; // Extra newlines for separation

      final reportFile = File(
        'data/branches/$branch/reports/tables/table_${table.id}.txt',
      );

      // Append to existing file or create new
      await reportFile.writeAsString(reportContent, mode: FileMode.append);
    }
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
      'data/branches/$branch/reports/inventory_report_${_uniqueTimestamp()}.txt',
    );
    await reportFile.writeAsString(reportContent);
  }

  static Future<void> _generateSalesReportCSV(
    String branch,
    List<Table> tables,
  ) async {
    final csvLines = <String>[];
    final now = DateTime.now();
    final dateStr = _formatDate(now);

    // Header
    csvLines.add('Branch,Table,Item,Quantity,UnitPrice,Total,Date');

    // Data rows
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
            dateStr,
          ].join(','),
        );
      }
    }

    await _ensureReportsDirectory(branch);
    final csvFile = File(
      'data/branches/$branch/reports/sales_report_${_uniqueTimestamp()}.csv',
    );
    await csvFile.writeAsString(csvLines.join('\n'));
  }

  static Future<void> _appendToCentralReport(
    String branch,
    List<Table> tables,
  ) async {
    final csvLines = <String>[];
    final now = DateTime.now();
    final dateStr = _formatDate(now);

    // Create header if file doesn't exist
    if (!await File(_centralReportFile).exists()) {
      csvLines.add('Branch,Table,Item,Quantity,UnitPrice,Total,Date');
    }

    // Add data rows
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
            dateStr,
          ].join(','),
        );
      }
    }

    // Append to central file
    await File(_centralReportFile).writeAsString(
      csvLines.isEmpty ? '' : '\n${csvLines.join('\n')}',
      mode: FileMode.append,
    );
  }

  /* Helper Methods */

  static Future<void> _ensureTableReportsDirectory(String branch) async {
    final dir = Directory('data/branches/$branch/reports/tables');
    if (!await dir.exists()) await dir.create(recursive: true);
  }

  static Future<void> _ensureReportsDirectory(String branch) async {
    final dir = Directory('data/branches/$branch/reports');
    if (!await dir.exists()) await dir.create(recursive: true);
    final centralDir = Directory('data/reports');
    if (!await centralDir.exists()) await centralDir.create(recursive: true);
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

  static String _uniqueTimestamp() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
  }
}

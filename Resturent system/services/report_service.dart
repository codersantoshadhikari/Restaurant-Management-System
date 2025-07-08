import 'dart:io';
import '../models/order.dart';

class ReportService {
  final String _reportFilePath = 'data/sales_report.csv';

  Future<void> generateSalesReport(List<Order> orders) async {
    try {
      final file = File(_reportFilePath);
      final csvData = StringBuffer();

      // Header
      csvData.writeln(
        'Total Orders,Total Sales,Most Sold Item,Least Sold Item',
      );

      // Calculate metrics
      final totalOrders = orders.length;
      final totalSales = orders.fold(0.0, (sum, order) => sum + order.total);

      final itemSales = <String, double>{};
      for (final order in orders) {
        for (final item in order.items) {
          final itemName = item.menuItem.name;
          itemSales[itemName] = (itemSales[itemName] ?? 0) + item.quantity;
        }
      }

      String mostSoldItem = 'N/A';
      String leastSoldItem = 'N/A';
      if (itemSales.isNotEmpty) {
        final sortedItems = itemSales.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        mostSoldItem = sortedItems.first.key;
        leastSoldItem = sortedItems.last.key;
      }

      // Write data
      csvData.writeln(
        '$totalOrders,${totalSales.toStringAsFixed(2)},$mostSoldItem,$leastSoldItem',
      );

      await file.writeAsString(csvData.toString());
    } catch (e) {
      print('Error generating sales report: $e');
    }
  }
}

import 'dart:async';
import '../models/order.dart';
import '../utils/file_handler.dart';

class ReportService {
  Future<void> generateSalesReport(List<Order> orders) async {
    try {
      final csvData = StringBuffer();

      // Header
      csvData.writeln(
        'Date,Total Orders,Total Sales,Most Sold Item,Least Sold Item',
      );

      // Group orders by date
      final ordersByDate = <DateTime, List<Order>>{};
      for (final order in orders) {
        final date = DateTime(
          order.orderTime.year,
          order.orderTime.month,
          order.orderTime.day,
        );
        ordersByDate[date] ??= [];
        ordersByDate[date]!.add(order);
      }

      // Calculate metrics for each date
      for (final entry in ordersByDate.entries) {
        final date = entry.key;
        final dailyOrders = entry.value;

        final totalOrders = dailyOrders.length;
        final totalSales = dailyOrders.fold(0.0, (sum, order) => sum + order.total);

        final itemSales = <String, double>{};
        for (final order in dailyOrders) {
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
          '${date.toIso8601String().split('T')[0]},$totalOrders,${totalSales.toStringAsFixed(2)},$mostSoldItem,$leastSoldItem',
        );
      }

      await FileHandler.saveReport(
        'sales_report_${DateTime.now().toIso8601String().split('T')[0]}.csv',
        csvData.toString(),
      );
    } catch (e) {
      print('Error generating sales report: $e');
    }
  }

  Future<void> generateInventoryReport( inventoryService) async {
    try {
      final csvData = StringBuffer();
      csvData.writeln('ID,Name,Quantity,Unit,Threshold,Status');

      for (final item in inventoryService.inventoryItems) {
        csvData.writeln(
          '${item.id},${item.name},${item.quantity},${item.unit},${item.threshold},${item.quantity < item.threshold ? 'LOW' : 'OK'}',
        );
      }

      await FileHandler.saveReport(
        'inventory_report_${DateTime.now().toIso8601String().split('T')[0]}.csv',
        csvData.toString(),
      );
    } catch (e) {
      print('Error generating inventory report: $e');
    }
  }
}
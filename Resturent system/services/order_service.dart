import 'dart:convert';
import 'dart:io';
import '../models/order.dart';

class OrderService {
  List<Order> _orders = [];
  final String _invoicesDirectory = 'data/invoices';

  List<Order> get orders => _orders;

  Future<void> loadOrders(menuService) async {
    try {
      final directory = Directory(_invoicesDirectory);
      if (await directory.exists()) {
        final files = await directory
            .list()
            .where((file) => file.path.endsWith('.json'))
            .toList();

        _orders = [];
        for (final file in files) {
          final jsonData = await File(file.path).readAsString();
          final orderData = json.decode(jsonData);
          _orders.add(Order.fromJson(orderData, menuService.menuItems));
        }
      }
    } catch (e) {
      print('Error loading orders: $e');
      _orders = [];
    }
  }

  Future<void> saveOrder(Order order) async {
    try {
      final directory = Directory(_invoicesDirectory);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final file = File('${directory.path}/invoice_${order.id}.json');
      await file.writeAsString(json.encode(order.toJson()));

      // Also save as text bill
      final billFile = File('${directory.path}/invoice_${order.id}.txt');
      await billFile.writeAsString(generateBillText(order));

      _orders.add(order);
    } catch (e) {
      print('Error saving order: $e');
    }
  }

  String generateBillText(Order order) {
    final buffer = StringBuffer();
    buffer.writeln('=== Restaurant Invoice ===');
    buffer.writeln('Order ID: ${order.id}');
    buffer.writeln('Table: ${order.tableNumber}');
    buffer.writeln('Date: ${order.orderTime}');
    buffer.writeln('----------------------------');
    buffer.writeln('Items:');

    for (final item in order.items) {
      buffer.writeln(
        '${item.menuItem.name} x ${item.quantity} - ₹${(item.menuItem.price * item.quantity).toStringAsFixed(2)}',
      );
    }

    buffer.writeln('----------------------------');
    buffer.writeln('Subtotal: ₹${order.subtotal.toStringAsFixed(2)}');
    buffer.writeln('GST (18%): ₹${order.gst.toStringAsFixed(2)}');

    if (order.discount != null) {
      buffer.writeln(
        'Discount (${(order.discount! * 100).toStringAsFixed(0)}%): -₹${(order.subtotal * order.discount!).toStringAsFixed(2)}',
      );
    }

    buffer.writeln('----------------------------');
    buffer.writeln('Total: ₹${order.total.toStringAsFixed(2)}');
    buffer.writeln('============================');

    return buffer.toString();
  }
}

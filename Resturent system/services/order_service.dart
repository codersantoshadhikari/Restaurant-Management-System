import 'dart:io';
import 'dart:convert';
import '../models/order.dart';
import '../utils/file_handler.dart';

class OrderService {
  List<Order> _orders = [];

  List<Order> get orders => _orders;

  Future<void> loadOrders(MenuService menuService) async {
    _orders = [];
    final invoiceFiles = await FileHandler.getInvoiceFiles();
    
    for (final filePath in invoiceFiles) {
      try {
        final jsonData = await File(filePath).readAsString();
        final orderData = json.decode(jsonData);
        _orders.add(Order.fromJson(orderData, menuService.menuItems));
      } catch (e) {
        print('Error loading order from $filePath: $e');
      }
    }
  }

  Future<void> saveOrder(Order order) async {
    final file = File('${FileHandler.invoicesDir}/invoice_${order.id}.json');
    await file.writeAsString(json.encode(order.toJson()));
    
    // Also save as text bill
    final billFile = File('${FileHandler.invoicesDir}/invoice_${order.id}.txt');
    await billFile.writeAsString(generateBillText(order));
    
    _orders.add(order);
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

  List<Order> getOrdersByDate(DateTime date) {
    return _orders.where((order) => 
      order.orderTime.year == date.year &&
      order.orderTime.month == date.month &&
      order.orderTime.day == date.day
    ).toList();
  }

  List<Order> getOrdersByTable(int tableNumber) {
    return _orders.where((order) => order.tableNumber == tableNumber).toList();
  }
}
// services/billing_service.dart

import 'dart:io';
import '../models/order.dart';

class BillingService {
  int invoiceCounter = 1;

  // Generate and save bill as invoice file
  void generateBill(Order order) {
    String filename = 'data/invoices/invoice_${invoiceCounter.toString().padLeft(2, '0')}.txt';
    final file = File(filename);
    final buffer = StringBuffer();

    buffer.writeln("🧾 Invoice #$invoiceCounter");
    buffer.writeln("Table: ${order.tableNumber}");
    buffer.writeln("------------------------------");
    for (var item in order.items) {
      buffer.writeln("${item.itemName} x${item.quantity} = ₹${item.total.toStringAsFixed(2)}");
    }
    buffer.writeln("------------------------------");
    buffer.writeln("Subtotal: ₹${order.subtotal.toStringAsFixed(2)}");
    buffer.writeln("GST 18%: ₹${order.gst.toStringAsFixed(2)}");
    buffer.writeln("Discount: ₹${order.discount.toStringAsFixed(2)}");
    buffer.writeln("Total: ₹${order.total.toStringAsFixed(2)}");

    file.writeAsStringSync(buffer.toString());
    print("✅ Bill saved as: $filename");
    invoiceCounter++;
  }
}

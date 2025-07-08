// services/report_service.dart

import 'dart:io';

class ReportService {
  void generateReport() {
    final dir = Directory('data/invoices');
    final files = dir.listSync();
    double totalSales = 0;
    int totalOrders = 0;

    for (var file in files) {
      if (file is File && file.path.endsWith('.txt')) {
        totalOrders++;
        final lines = file.readAsLinesSync();
        for (var line in lines) {
          if (line.startsWith("Total: ₹")) {
            final amount = double.parse(line.split("₹")[1]);
            totalSales += amount;
          }
        }
      }
    }

    final report = StringBuffer();
    report.writeln("Total Orders,$totalOrders");
    report.writeln("Total Sales,₹${totalSales.toStringAsFixed(2)}");

    File("data/sales_report.csv").writeAsStringSync(report.toString());
    print("📊 Sales report generated: sales_report.csv");
  }
}

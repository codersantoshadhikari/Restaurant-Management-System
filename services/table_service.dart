// services/table_service.dart

import 'dart:io';
import 'dart:convert';
import '../models/table.dart';

class TableService {
  List<RestaurantTable> tables = [];

  // Load or initialize 10 tables
  void loadTables() {
    final file = File('data/tables.json');
    if (file.existsSync()) {
      final data = jsonDecode(file.readAsStringSync());
      tables = data.map<RestaurantTable>((e) => RestaurantTable.fromJson(e)).toList();
    } else {
      tables = List.generate(10, (i) => RestaurantTable(tableNumber: i + 1));
      saveTables();
    }
  }

  void saveTables() {
    final file = File('data/tables.json');
    final data = tables.map((t) => t.toJson()).toList();
    file.writeAsStringSync(jsonEncode(data));
  }

  // Book table
  bool bookTable(int number) {
    final table = tables.firstWhere((t) => t.tableNumber == number);
    if (!table.isOccupied) {
      table.isOccupied = true;
      saveTables();
      print("✅ Table $number booked.");
      return true;
    }
    print("❌ Table $number already occupied.");
    return false;
  }

  // Free table
  void freeTable(int number) {
    final table = tables.firstWhere((t) => t.tableNumber == number);
    table.isOccupied = false;
    saveTables();
    print("✅ Table $number is now free.");
  }

  // Show all table statuses
  void showTableStatus() {
    print("\n🪑 Table Status:");
    for (var t in tables) {
      print("Table ${t.tableNumber}: ${t.isOccupied ? 'Occupied' : 'Free'}");
    }
  }
}

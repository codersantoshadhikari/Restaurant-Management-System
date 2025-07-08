import 'dart:convert';
import 'dart:io';
import '../models/table.dart';

class TableService {
  List<RestaurantTable> _tables = [];
  final String _dataFilePath = 'data/tables.json';

  List<RestaurantTable> get tables => _tables;

  Future<void> loadTables() async {
    try {
      final file = File(_dataFilePath);
      if (await file.exists()) {
        final jsonData = await file.readAsString();
        final List<dynamic> data = json.decode(jsonData);
        _tables = data.map((table) => RestaurantTable.fromJson(table)).toList();
      } else {
        // Initialize with 10 tables if file doesn't exist
        _tables = List.generate(
          10,
          (index) => RestaurantTable(number: index + 1),
        );
        saveTables();
      }
    } catch (e) {
      print('Error loading tables: $e');
      _tables = List.generate(
        10,
        (index) => RestaurantTable(number: index + 1),
      );
    }
  }

  Future<void> saveTables() async {
    try {
      final file = File(_dataFilePath);
      final jsonData = json.encode(
        _tables.map((table) => table.toJson()).toList(),
      );
      await file.writeAsString(jsonData);
    } catch (e) {
      print('Error saving tables: $e');
    }
  }

  void bookTable(int tableNumber, int customerCount) {
    final table = _tables.firstWhere((t) => t.number == tableNumber);
    table.isOccupied = true;
    table.customerCount = customerCount;
    table.bookingTime = DateTime.now();
    saveTables();
  }

  void freeTable(int tableNumber) {
    final table = _tables.firstWhere((t) => t.number == tableNumber);
    table.isOccupied = false;
    table.customerCount = null;
    table.bookingTime = null;
    saveTables();
  }

  List<RestaurantTable> getAvailableTables() {
    return _tables.where((table) => !table.isOccupied).toList();
  }

  List<RestaurantTable> getOccupiedTables() {
    return _tables.where((table) => table.isOccupied).toList();
  }
}

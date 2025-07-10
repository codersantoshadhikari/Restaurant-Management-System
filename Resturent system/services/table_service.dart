import '../models/table.dart';
import '../utils/file_handler.dart';

class TableService {
  List<RestaurantTable> _tables = [];

  List<RestaurantTable> get tables => _tables;

  Future<void> loadTables() async {
    final data = await FileHandler.loadJsonFile(FileHandler.tablesFile);
    _tables = data.map((table) => RestaurantTable.fromJson(table)).toList();
    
    if (_tables.isEmpty) {
      _tables = List.generate(
        10,
        (index) => RestaurantTable(number: index + 1),
      );
      await saveTables();
    }
  }

  Future<void> saveTables() async {
    await FileHandler.saveJsonFile(
      FileHandler.tablesFile,
      _tables.map((table) => table.toJson()).toList(),
    );
  }

  Future<void> bookTable(int tableNumber, int customerCount) async {
    final table = _tables.firstWhere((t) => t.number == tableNumber);
    table.isOccupied = true;
    table.customerCount = customerCount;
    table.bookingTime = DateTime.now();
    await saveTables();
  }

  Future<void> freeTable(int tableNumber) async {
    final table = _tables.firstWhere((t) => t.number == tableNumber);
    table.isOccupied = false;
    table.customerCount = null;
    table.bookingTime = null;
    await saveTables();
  }

  List<RestaurantTable> getAvailableTables() {
    return _tables.where((table) => !table.isOccupied).toList();
  }

  List<RestaurantTable> getOccupiedTables() {
    return _tables.where((table) => table.isOccupied).toList();
  }

  RestaurantTable? getTableByNumber(int number) {
    try {
      return _tables.firstWhere((table) => table.number == number);
    } catch (e) {
      return null;
    }
  }
}
import '../models/order.dart';
import '../models/table.dart';
import '../utils/file_handler.dart';

class TableService {
  static const String _tablesFile = 'data/tables.json';

  static Future<List<Table>> loadTables() async {
    final data = await FileHandler.readJson(_tablesFile);
    return (data['tables'] as List)
        .map(
          (t) => Table(
            id: t['id'] as int,
            capacity: t['capacity'] as int,
            isOccupied: t['isOccupied'] as bool,
            orders: (t['orders'] as List)
                .map(
                  (o) => Order(
                    itemName: o['itemName'] as String,
                    price: o['price'] as double,
                    quantity: o['quantity'] as int,
                  ),
                )
                .toList(),
          ),
        )
        .toList();
  }

  static Future<void> addTable(Table newTable) async {
    final tables = await loadTables();

    // Check for duplicate ID
    if (tables.any((t) => t.id == newTable.id)) {
      throw Exception('Table with ID ${newTable.id} already exists');
    }

    tables.add(newTable);
    await saveTables(tables);
  }

  static Future<void> saveTables(List<Table> tables) async {
    await FileHandler.writeJson(_tablesFile, {
      'tables': tables.map((t) => t.toJson()).toList(),
    });
  }

  static Future<void> bookTable(int tableId) async {
    final tables = await loadTables();
    final table = tables.firstWhere((t) => t.id == tableId);
    table.isOccupied = true;
    await saveTables(tables);
  }

  static Future<void> freeTable(int tableId) async {
    final tables = await loadTables();
    final table = tables.firstWhere((t) => t.id == tableId);
    table.isOccupied = false;
    table.orders.clear();
    await saveTables(tables);
  }
}

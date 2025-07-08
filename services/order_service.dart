import '../models/order.dart';
import 'menu_service.dart';
import 'table_service.dart';

class OrderService {
  static Future<void> addOrder(int tableId, int itemId, int quantity) async {
    final menu = await MenuService.getMenu();
    final item = menu.firstWhere((i) => i.id == itemId);

    if (!item.isAvailable) {
      throw Exception('${item.name} is not available');
    }

    final tables = await TableService.loadTables();
    final table = tables.firstWhere((t) => t.id == tableId);

    table.orders.add(
      Order(itemName: item.name, price: item.price, quantity: quantity),
    );

    await TableService.saveTables(tables);
  }
}

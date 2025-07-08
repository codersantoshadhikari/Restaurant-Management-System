import '../models/inventory_item.dart';
import '../utils/file_handler.dart';

class InventoryService {
  static const String _inventoryFile = 'data/inventory.json';

  static Future<List<InventoryItem>> getInventory() async {
    final data = await FileHandler.readJson(_inventoryFile);
    return (data['items'] as List)
        .map(
          (i) => InventoryItem(
            name: i['name'] as String,
            quantity: i['quantity'] as int,
            unit: i['unit'] as String,
          ),
        )
        .toList();
  }

  static Future<void> addItem(InventoryItem item) async {
    final inventory = await getInventory();
    inventory.add(item);
    await _saveInventory(inventory);
  }

  static Future<void> updateQuantity(String itemName, int change) async {
    final inventory = await getInventory();
    final item = inventory.firstWhere((i) => i.name == itemName);
    item.quantity += change;
    await _saveInventory(inventory);
  }

  static Future<void> _saveInventory(List<InventoryItem> inventory) async {
    await FileHandler.writeJson(_inventoryFile, {
      'items': inventory.map((i) => i.toJson()).toList(),
    });
  }
}

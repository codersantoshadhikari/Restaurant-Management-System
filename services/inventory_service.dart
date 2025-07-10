import '../models/inventory_item.dart';
import '../utils/file_handler.dart';

class InventoryService {
  static Future<List<InventoryItem>> getInventory(String branch) async {
    final data = await FileHandler.readJson('data/branches/$branch.json');
    return (data['inventory'] as List)
        .map((i) => InventoryItem.fromJson(i))
        .toList();
  }

  static Future<void> addItem(String branch, InventoryItem item) async {
    final data = await FileHandler.readJson('data/branches/$branch.json');
    final inventory = (data['inventory'] as List)
        .map((i) => InventoryItem.fromJson(i))
        .toList();

    // Check for duplicate items
    if (inventory.any((i) => i.item.toLowerCase() == item.item.toLowerCase())) {
      throw Exception('Item already exists in inventory');
    }

    inventory.add(item);
    data['inventory'] = inventory.map((i) => i.toJson()).toList();
    await FileHandler.writeJson('data/branches/$branch.json', data);
  }

  static Future<void> updateQuantity(
    String branch,
    String itemName,
    int change,
  ) async {
    final data = await FileHandler.readJson('data/branches/$branch.json');
    final inventory = (data['inventory'] as List)
        .map((i) => InventoryItem.fromJson(i))
        .toList();

    final itemIndex = inventory.indexWhere(
      (i) => i.item.toLowerCase() == itemName.toLowerCase(),
    );

    if (itemIndex == -1) {
      throw Exception('Item "$itemName" not found in inventory');
    }

    final newQuantity = inventory[itemIndex].quantity + change;

    if (newQuantity < 0) {
      throw Exception(
        'Cannot update quantity. Result would be negative ($newQuantity)',
      );
    }

    inventory[itemIndex].quantity = newQuantity;
    data['inventory'] = inventory.map((i) => i.toJson()).toList();
    await FileHandler.writeJson('data/branches/$branch.json', data);
  }

  static Future<void> removeItem(String branch, String itemName) async {
    final data = await FileHandler.readJson('data/branches/$branch.json');
    final inventory = (data['inventory'] as List)
        .map((i) => InventoryItem.fromJson(i))
        .toList();

    final newInventory = inventory
        .where((i) => i.item.toLowerCase() != itemName.toLowerCase())
        .toList();

    if (newInventory.length == inventory.length) {
      throw Exception('Item not found in inventory');
    }

    data['inventory'] = newInventory.map((i) => i.toJson()).toList();
    await FileHandler.writeJson('data/branches/$branch.json', data);
  }
}

import '../models/inventory_item.dart';
import '../models/order.dart';
import '../utils/file_handler.dart';

class InventoryService {
  List<InventoryItem> _inventoryItems = [];

  List<InventoryItem> get inventoryItems => _inventoryItems;

  Future<void> loadInventory() async {
    final data = await FileHandler.loadJsonFile(FileHandler.inventoryFile);
    _inventoryItems = data.map((item) => InventoryItem.fromJson(item)).toList();
  }

  Future<void> saveInventory() async {
    await FileHandler.saveJsonFile(
      FileHandler.inventoryFile,
      _inventoryItems.map((item) => item.toJson()).toList(),
    );
  }

  Future<void> addInventoryItem(InventoryItem item) async {
    _inventoryItems.add(item);
    await saveInventory();
  }

  Future<void> updateInventoryItem(String id, InventoryItem updatedItem) async {
    final index = _inventoryItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      _inventoryItems[index] = updatedItem;
      await saveInventory();
    }
  }

  Future<void> deleteInventoryItem(String id) async {
    _inventoryItems.removeWhere((item) => item.id == id);
    await saveInventory();
  }

  List<InventoryItem> getLowStockItems() {
    return _inventoryItems
        .where((item) => item.quantity < item.threshold)
        .toList();
  }

  Future<void> updateInventoryForOrder(Order order) async {
    for (final orderItem in order.items) {
      final menuItem = orderItem.menuItem;

      for (final ingredientEntry in menuItem.ingredients.entries) {
        final ingredientId = ingredientEntry.key;
        final quantityUsed = ingredientEntry.value * orderItem.quantity;

        final inventoryItem = _inventoryItems.firstWhere(
          (item) => item.id == ingredientId,
          orElse: () => throw Exception('Inventory item $ingredientId not found'),
        );

        if (inventoryItem.quantity < quantityUsed) {
          throw Exception('Not enough ${inventoryItem.name} in stock');
        }

        inventoryItem.quantity -= quantityUsed;
      }
    }

    await saveInventory();
  }

  Future<void> restockInventoryItem(String id, double quantity) async {
    final item = _inventoryItems.firstWhere(
      (item) => item.id == id,
      orElse: () => throw Exception('Item not found'),
    );
    
    item.quantity += quantity;
    await saveInventory();
  }
}
import 'dart:convert';
import 'dart:io';
import '../models/inventory_item.dart';
import '../models/order.dart';

class InventoryService {
  List<InventoryItem> _inventoryItems = [];
  final String _dataFilePath = 'data/inventory.json';

  List<InventoryItem> get inventoryItems => _inventoryItems;

  Future<void> loadInventory() async {
    try {
      final file = File(_dataFilePath);
      if (await file.exists()) {
        final jsonData = await file.readAsString();
        final List<dynamic> data = json.decode(jsonData);
        _inventoryItems = data
            .map((item) => InventoryItem.fromJson(item))
            .toList();
      } else {
        _inventoryItems = [];
      }
    } catch (e) {
      print('Error loading inventory: $e');
      _inventoryItems = [];
    }
  }

  Future<void> saveInventory() async {
    try {
      final file = File(_dataFilePath);
      final jsonData = json.encode(
        _inventoryItems.map((item) => item.toJson()).toList(),
      );
      await file.writeAsString(jsonData);
    } catch (e) {
      print('Error saving inventory: $e');
    }
  }

  void addInventoryItem(InventoryItem item) {
    _inventoryItems.add(item);
    saveInventory();
  }

  void updateInventoryItem(String id, InventoryItem updatedItem) {
    final index = _inventoryItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      _inventoryItems[index] = updatedItem;
      saveInventory();
    }
  }

  void deleteInventoryItem(String id) {
    _inventoryItems.removeWhere((item) => item.id == id);
    saveInventory();
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
          orElse: () =>
              throw Exception('Inventory item $ingredientId not found'),
        );

        if (inventoryItem.quantity < quantityUsed) {
          throw Exception('Not enough ${inventoryItem.name} in stock');
        }

        inventoryItem.quantity -= quantityUsed;
      }
    }

    await saveInventory();
  }
}

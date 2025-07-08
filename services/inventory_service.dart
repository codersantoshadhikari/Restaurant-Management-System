// File: services/inventory_service.dart

import 'dart:convert';
import 'dart:io';
import '../models/inventory_item.dart';

class InventoryService {
  final String filePath = 'data/inventory.json';
  List<InventoryItem> inventory = [];

  // Load inventory from file
  Future<void> loadInventory() async {
    final file = File(filePath);
    if (await file.exists()) {
      final contents = await file.readAsString();
      final data = json.decode(contents) as List<dynamic>;

      inventory = data.map((itemJson) => InventoryItem.fromJson(itemJson)).toList();
      print("✅ Inventory loaded. Total items: ${inventory.length}");
    } else {
      print("⚠️ Inventory file not found at '$filePath'. Creating a new one...");
      await saveInventory();
    }
  }

  // Save inventory to file
  Future<void> saveInventory() async {
    final file = File(filePath);
    final data = inventory.map((item) => item.toJson()).toList();
    await file.writeAsString(json.encode(data), flush: true);
    print("💾 Inventory saved to '$filePath'");
  }

  // Add a new item
  void addItem(InventoryItem item) {
    inventory.add(item);
    print("✅ Item added: ${item.name}");
  }

  // View current inventory
  void viewInventory() {
    if (inventory.isEmpty) {
      print("📦 Inventory is empty.");
    } else {
      print("📋 Inventory List:");
      for (var item in inventory) {
        print(item);
      }
    }
  }

  // Remove item by name
  void removeItem(String name) {
    inventory.removeWhere((item) => item.name.toLowerCase() == name.toLowerCase());
    print("❌ Item removed: $name");
  }

  // Update quantity by name
  void updateQuantity(String name, int newQty) {
    for (var item in inventory) {
      if (item.name.toLowerCase() == name.toLowerCase()) {
        item.quantity = newQty;
        print("🔄 Updated quantity for '$name' to $newQty.");
        return;
      }
    }
    print("❌ Item '$name' not found.");
  }

  // ✅ Reduce stock quantity
  void reduceStock(String itemName, double qtyToReduce) {
    for (var item in inventory) {
      if (item.name.toLowerCase() == itemName.toLowerCase()) {
        if (item.quantity >= qtyToReduce.round()) {
          item.quantity -= qtyToReduce.round();
          print("📉 Reduced stock for '$itemName' by ${qtyToReduce.round()} units.");
        } else {
          print("⚠️ Not enough stock to reduce for '$itemName'. Available: ${item.quantity}");
        }
        return;
      }
    }
    print("❌ Item '$itemName' not found in inventory.");
  }
}

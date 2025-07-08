// services/menu_service.dart

import 'dart:io';
import 'dart:convert';
import '../models/menu_item.dart';

class MenuService {
  List<MenuItem> menuList = [];

  // Load menu from file
  void loadMenu() {
    final file = File('data/menu.json');
    if (file.existsSync()) {
      final data = jsonDecode(file.readAsStringSync());
      menuList = data.map<MenuItem>((item) => MenuItem.fromJson(item)).toList();
    }
  }

  // Save menu to file
  void saveMenu() {
    final file = File('data/menu.json');
    final data = menuList.map((item) => item.toJson()).toList();
    file.writeAsStringSync(jsonEncode(data));
  }

  // Add item
  void addMenuItem(MenuItem item) {
    menuList.add(item);
    print("✅ Menu item added: ${item.name}");
  }

  // View menu
  void viewMenu() {
    print("\n🍽 Menu:");
    for (var item in menuList) {
      print("${item.name} - ₹${item.price} - ${item.category} - ${item.isAvailable ? 'Available' : 'Unavailable'}");
    }
  }

  // Delete item by name
  void deleteMenuItem(String name) {
    menuList.removeWhere((item) => item.name.toLowerCase() == name.toLowerCase());
    print("🗑 Deleted item: $name");
  }
}

import 'dart:convert';
import 'dart:io';
import '../models/menu_item.dart';

class MenuService {
  List<MenuItem> _menuItems = [];
  final String _dataFilePath = 'data/menu.json';

  List<MenuItem> get menuItems => _menuItems;

  Future<void> loadMenu() async {
    try {
      final file = File(_dataFilePath);
      if (await file.exists()) {
        final jsonData = await file.readAsString();
        final List<dynamic> data = json.decode(jsonData);
        _menuItems = data.map((item) => MenuItem.fromJson(item)).toList();
      } else {
        _menuItems = [];
      }
    } catch (e) {
      print('Error loading menu: $e');
      _menuItems = [];
    }
  }

  Future<void> saveMenu() async {
    try {
      final file = File(_dataFilePath);
      final jsonData = json.encode(
        _menuItems.map((item) => item.toJson()).toList(),
      );
      await file.writeAsString(jsonData);
    } catch (e) {
      print('Error saving menu: $e');
    }
  }

  void addMenuItem(MenuItem item) {
    _menuItems.add(item);
    saveMenu();
  }

  void updateMenuItem(String id, MenuItem updatedItem) {
    final index = _menuItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      _menuItems[index] = updatedItem;
      saveMenu();
    }
  }

  void deleteMenuItem(String id) {
    _menuItems.removeWhere((item) => item.id == id);
    saveMenu();
  }

  MenuItem? getMenuItemById(String id) {
    return _menuItems.firstWhere((item) => item.id == id);
  }

  List<MenuItem> getMenuItemsByCategory(String category) {
    return _menuItems.where((item) => item.category == category).toList();
  }
}

import '../models/menu_item.dart';
import '../utils/file_handler.dart';

class MenuService {
  List<MenuItem> _menuItems = [];

  List<MenuItem> get menuItems => _menuItems;

  Future<void> loadMenu() async {
    final data = await FileHandler.loadJsonFile(FileHandler.menuFile);
    _menuItems = data.map((item) => MenuItem.fromJson(item)).toList();
  }

  Future<void> saveMenu() async {
    await FileHandler.saveJsonFile(
      FileHandler.menuFile,
      _menuItems.map((item) => item.toJson()).toList(),
    );
  }

  Future<void> addMenuItem(MenuItem item) async {
    _menuItems.add(item);
    await saveMenu();
  }

  Future<void> updateMenuItem(String id, MenuItem updatedItem) async {
    final index = _menuItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      _menuItems[index] = updatedItem;
      await saveMenu();
    }
  }

  Future<void> deleteMenuItem(String id) async {
    _menuItems.removeWhere((item) => item.id == id);
    await saveMenu();
  }

  MenuItem? getMenuItemById(String id) {
    try {
      return _menuItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  List<MenuItem> getMenuItemsByCategory(String category) {
    return _menuItems.where((item) => item.category == category).toList();
  }

  List<String> getCategories() {
    return _menuItems.map((item) => item.category).toSet().toList();
  }
}
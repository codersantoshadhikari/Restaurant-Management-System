// menu_service.dart
import '../models/menu_item.dart';
import '../utils/file_handler.dart';

class MenuService {
  static const String _menuFile = 'data/menu.json';

  /// Retrieves all menu items from the storage
  static Future<List<MenuItem>> getMenu() async {
    try {
      final data = await FileHandler.readJson(_menuFile);
      return (data['items'] as List)
          .map(
            (item) => MenuItem(
              id: item['id'] as int,
              name: item['name'] as String,
              price: item['price'] as double,
              category: item['category'] as String,
              isAvailable: item['isAvailable'] as bool,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to load menu: ${e.toString()}');
    }
  }

  /// Adds a new menu item after checking for duplicate IDs
  static Future<void> addItem(MenuItem item) async {
    final menu = await getMenu();

    // Check for duplicate ID
    if (menu.any((existingItem) => existingItem.id == item.id)) {
      throw Exception('An item with ID ${item.id} already exists!');
    }

    // Validate price is positive
    if (item.price <= 0) {
      throw Exception('Price must be greater than 0');
    }

    menu.add(item);
    await _saveMenu(menu);
  }

  /// Updates the availability status of a menu item
  static Future<void> toggleAvailability(int itemId) async {
    final menu = await getMenu();
    final item = menu.firstWhere(
      (i) => i.id == itemId,
      orElse: () => throw Exception('Item with ID $itemId not found'),
    );
    item.isAvailable = !item.isAvailable;
    await _saveMenu(menu);
  }

  /// Removes a menu item by ID
  static Future<void> removeItem(int itemId) async {
    final menu = await getMenu();
    menu.removeWhere((item) => item.id == itemId);
    await _saveMenu(menu);
  }

  /// Finds a menu item by ID
  static Future<MenuItem?> findItemById(int itemId) async {
    final menu = await getMenu();
    try {
      return menu.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }

  /// Private method to save the menu to storage
  static Future<void> _saveMenu(List<MenuItem> menu) async {
    try {
      await FileHandler.writeJson(_menuFile, {
        'items': menu.map((item) => item.toJson()).toList(),
      });
    } catch (e) {
      throw Exception('Failed to save menu: ${e.toString()}');
    }
  }

  /// Gets menu items by category
  static Future<List<MenuItem>> getItemsByCategory(String category) async {
    final menu = await getMenu();
    return menu.where((item) => item.category == category).toList();
  }

  /// Gets all available menu items
  static Future<List<MenuItem>> getAvailableItems() async {
    final menu = await getMenu();
    return menu.where((item) => item.isAvailable).toList();
  }
}

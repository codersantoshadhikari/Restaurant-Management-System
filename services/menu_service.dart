/*HANDLES MENU*/
import '../models/menu_item.dart';
import '../utils/file_handler.dart';

class MenuService {
  static const String _menuFile = 'data/menu.json';

  static Future<List<MenuItem>> getMenu() async {
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
  }

  static Future<void> addItem(MenuItem item) async {
    final menu = await getMenu();
    menu.add(item);
    await _saveMenu(menu);
  }

  static Future<void> toggleAvailability(int itemId) async {
    final menu = await getMenu();
    final item = menu.firstWhere((i) => i.id == itemId);
    item.isAvailable = !item.isAvailable;
    await _saveMenu(menu);
  }

  static Future<void> _saveMenu(List<MenuItem> menu) async {
    await FileHandler.writeJson(_menuFile, {
      'items': menu.map((item) => item.toJson()).toList(),
    });
  }
}

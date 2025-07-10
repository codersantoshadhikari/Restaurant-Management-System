class Validator {
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  static bool isValidPrice(String price) {
    return double.tryParse(price) != null && double.parse(price) > 0;
  }

  static bool isValidQuantity(String quantity) {
    return int.tryParse(quantity) != null && int.parse(quantity) > 0;
  }

  static bool isValidTableNumber(String number, TableService tableService) {
    final tableNumber = int.tryParse(number);
    if (tableNumber == null) return false;
    return tableService.getTableByNumber(tableNumber) != null;
  }

  static bool isValidMenuItemId(String id, MenuService menuService) {
    return menuService.getMenuItemById(id) != null;
  }

  static bool isValidInventoryItemId(String id, InventoryService inventoryService) {
    return inventoryService.inventoryItems.any((item) => item.id == id);
  }
}
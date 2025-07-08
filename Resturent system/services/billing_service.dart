import '../models/order.dart';
import 'order_service.dart';
import 'table_service.dart';
import 'menu_service.dart';
import 'inventory_service.dart';

class BillingService {
  final OrderService _orderService;
  final TableService _tableService;
  final MenuService _menuService;
  final InventoryService _inventoryService;

  BillingService({
    required OrderService orderService,
    required TableService tableService,
    required MenuService menuService,
    required InventoryService inventoryService,
  }) : _orderService = orderService,
       _tableService = tableService,
       _menuService = menuService,
       _inventoryService = inventoryService;

  Future<Order> createOrder({
    required int tableNumber,
    required List<Map<String, dynamic>>
    items, // [{menuItemId: '123', quantity: 2}]
    double? discount,
  }) async {
    // Verify table is occupied
    final table = _tableService.tables.firstWhere(
      (t) => t.number == tableNumber,
      orElse: () => throw Exception('Table not found'),
    );

    if (!table.isOccupied) {
      throw Exception('Table is not occupied');
    }

    // Create order items
    final orderItems = <OrderItem>[];
    for (final item in items) {
      final menuItem = _menuService.getMenuItemById(item['menuItemId']);
      if (menuItem == null) {
        throw Exception('Menu item ${item['menuItemId']} not found');
      }
      if (!menuItem.isAvailable) {
        throw Exception('Menu item ${menuItem.name} is not available');
      }
      orderItems.add(OrderItem(menuItem: menuItem, quantity: item['quantity']));
    }

    // Create order
    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tableNumber: tableNumber,
      items: orderItems,
      discount: discount,
    );

    // Update inventory
    await _inventoryService.updateInventoryForOrder(order);

    // Save order
    await _orderService.saveOrder(order);

    return order;
  }
}

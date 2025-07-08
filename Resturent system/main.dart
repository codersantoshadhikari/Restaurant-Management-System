import 'dart:io';
import 'models/menu_item.dart';
import 'models/inventory_item.dart';
import 'services/menu_service.dart';
import 'services/table_service.dart';
import 'services/order_service.dart';
import 'services/billing_service.dart';
import 'services/inventory_service.dart';
import 'services/report_service.dart';

void main() async {
  // Initialize services
  final menuService = MenuService();
  final tableService = TableService();
  final orderService = OrderService();
  final inventoryService = InventoryService();
  final reportService = ReportService();

  final billingService = BillingService(
    orderService: orderService,
    tableService: tableService,
    menuService: menuService,
    inventoryService: inventoryService,
  );

  // Load data
  await menuService.loadMenu();
  await tableService.loadTables();
  await inventoryService.loadInventory();
  await orderService.loadOrders(menuService);

  // Main menu
  bool exit = false;
  while (!exit) {
    print('\n=== Restaurant Management System ===');
    print('1. Menu Management');
    print('2. Table Management');
    print('3. Order & Billing');
    print('4. Sales Reports');
    print('5. Inventory Management');
    print('6. Exit');
    print('===================================');

    stdout.write('Enter your choice: ');
    final choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        await menuManagement(menuService);
        break;
      case '2':
        await tableManagement(tableService);
        break;
      case '3':
        await orderManagement(billingService, tableService, menuService);
        break;
      case '4':
        await salesReports(reportService, orderService);
        break;
      case '5':
        await inventoryManagement(inventoryService);
        break;
      case '6':
        exit = true;
        break;
      default:
        print('Invalid choice. Please try again.');
    }
  }
}

Future<void> menuManagement(MenuService menuService) async {
  bool back = false;
  while (!back) {
    print('\n=== Menu Management ===');
    print('1. View Menu');
    print('2. Add Menu Item');
    print('3. Update Menu Item');
    print('4. Delete Menu Item');
    print('5. Back to Main Menu');
    print('=======================');

    stdout.write('Enter your choice: ');
    final choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        viewMenu(menuService);
        break;
      case '2':
        await addMenuItem(menuService);
        break;
      case '3':
        await updateMenuItem(menuService);
        break;
      case '4':
        await deleteMenuItem(menuService);
        break;
      case '5':
        back = true;
        break;
      default:
        print('Invalid choice. Please try again.');
    }
  }
}

void viewMenu(MenuService menuService) {
  print('\n=== Menu Items ===');
  for (final item in menuService.menuItems) {
    print('ID: ${item.id}');
    print('Name: ${item.name}');
    print('Price: ₹${item.price.toStringAsFixed(2)}');
    print('Category: ${item.category}');
    print('Available: ${item.isAvailable ? "Yes" : "No"}');
    print('Ingredients: ${item.ingredients}');
    print('-----------------------');
  }
}

Future<void> addMenuItem(MenuService menuService) async {
  print('\n=== Add New Menu Item ===');

  stdout.write('Enter item ID: ');
  final id = stdin.readLineSync() ?? '';

  stdout.write('Enter item name: ');
  final name = stdin.readLineSync() ?? '';

  stdout.write('Enter item price: ');
  final price = double.tryParse(stdin.readLineSync() ?? '0') ?? 0.0;

  stdout.write('Enter item category: ');
  final category = stdin.readLineSync() ?? '';

  final ingredients = <String, double>{};
  print('\nAdd ingredients (enter blank to finish):');
  while (true) {
    stdout.write('Ingredient ID: ');
    final ingId = stdin.readLineSync() ?? '';
    if (ingId.isEmpty) break;

    stdout.write('Quantity used (per item): ');
    final quantity = double.tryParse(stdin.readLineSync() ?? '0') ?? 0.0;

    ingredients[ingId] = quantity;
  }

  final newItem = MenuItem(
    id: id,
    name: name,
    price: price,
    category: category,
    ingredients: ingredients,
  );

  menuService.addMenuItem(newItem);
  print('Menu item added successfully!');
}

Future<void> updateMenuItem(MenuService menuService) async {
  print('\n=== Update Menu Item ===');
  viewMenu(menuService);

  stdout.write('Enter item ID to update: ');
  final id = stdin.readLineSync() ?? '';

  final item = menuService.getMenuItemById(id);
  if (item == null) {
    print('Item not found!');
    return;
  }

  stdout.write('Enter new name (${item.name}): ');
  final name = stdin.readLineSync() ?? item.name;

  stdout.write('Enter new price (${item.price}): ');
  final price =
      double.tryParse(stdin.readLineSync() ?? item.price.toString()) ??
      item.price;

  stdout.write('Enter new category (${item.category}): ');
  final category = stdin.readLineSync() ?? item.category;

  stdout.write('Is available? (${item.isAvailable}) (y/n): ');
  final availableInput = stdin.readLineSync()?.toLowerCase() ?? '';
  final isAvailable =
      availableInput == 'y' || (availableInput.isEmpty && item.isAvailable);

  print('\nCurrent ingredients: ${item.ingredients}');
  final ingredients = Map<String, double>.from(item.ingredients);
  print('Update ingredients (enter blank to keep current):');
  while (true) {
    stdout.write('Ingredient ID: ');
    final ingId = stdin.readLineSync() ?? '';
    if (ingId.isEmpty) break;

    stdout.write('Quantity used (per item): ');
    final quantity = double.tryParse(stdin.readLineSync() ?? '0') ?? 0.0;

    ingredients[ingId] = quantity;
  }

  final updatedItem = MenuItem(
    id: item.id,
    name: name,
    price: price,
    category: category,
    isAvailable: isAvailable,
    ingredients: ingredients,
  );

  menuService.updateMenuItem(id, updatedItem);
  print('Menu item updated successfully!');
}

Future<void> deleteMenuItem(MenuService menuService) async {
  print('\n=== Delete Menu Item ===');
  viewMenu(menuService);

  stdout.write('Enter item ID to delete: ');
  final id = stdin.readLineSync() ?? '';

  menuService.deleteMenuItem(id);
  print('Menu item deleted successfully!');
}

Future<void> tableManagement(TableService tableService) async {
  bool back = false;
  while (!back) {
    print('\n=== Table Management ===');
    print('1. View Table Status');
    print('2. Book Table');
    print('3. Free Table');
    print('4. Back to Main Menu');
    print('=======================');

    stdout.write('Enter your choice: ');
    final choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        viewTableStatus(tableService);
        break;
      case '2':
        await bookTable(tableService);
        break;
      case '3':
        await freeTable(tableService);
        break;
      case '4':
        back = true;
        break;
      default:
        print('Invalid choice. Please try again.');
    }
  }
}

void viewTableStatus(TableService tableService) {
  print('\n=== Table Status ===');
  for (final table in tableService.tables) {
    print(
      'Table ${table.number}: ${table.isOccupied ? 'Occupied (${table.customerCount} people)' : 'Available'}',
    );
    if (table.bookingTime != null) {
      print('   Booked at: ${table.bookingTime}');
    }
  }
}

Future<void> bookTable(TableService tableService) async {
  print('\n=== Book Table ===');
  final availableTables = tableService.getAvailableTables();
  if (availableTables.isEmpty) {
    print('No tables available!');
    return;
  }

  print('Available Tables:');
  for (final table in availableTables) {
    print('Table ${table.number}');
  }

  stdout.write('Enter table number: ');
  final tableNumber = int.tryParse(stdin.readLineSync() ?? '') ?? 0;

  stdout.write('Enter number of customers: ');
  final customerCount = int.tryParse(stdin.readLineSync() ?? '') ?? 0;

  tableService.bookTable(tableNumber, customerCount);
  print('Table $tableNumber booked successfully!');
}

Future<void> freeTable(TableService tableService) async {
  print('\n=== Free Table ===');
  final occupiedTables = tableService.getOccupiedTables();
  if (occupiedTables.isEmpty) {
    print('No tables are occupied!');
    return;
  }

  print('Occupied Tables:');
  for (final table in occupiedTables) {
    print('Table ${table.number} (${table.customerCount} people)');
  }

  stdout.write('Enter table number to free: ');
  final tableNumber = int.tryParse(stdin.readLineSync() ?? '') ?? 0;

  tableService.freeTable(tableNumber);
  print('Table $tableNumber freed successfully!');
}

Future<void> orderManagement(
  BillingService billingService,
  TableService tableService,
  MenuService menuService,
) async {
  bool back = false;
  while (!back) {
    print('\n=== Order & Billing ===');
    print('1. Create New Order');
    print('2. View Menu');
    print('3. View Table Status');
    print('4. Back to Main Menu');
    print('=======================');

    stdout.write('Enter your choice: ');
    final choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        await createOrder(billingService, tableService, menuService);
        break;
      case '2':
        viewMenu(menuService);
        break;
      case '3':
        viewTableStatus(tableService);
        break;
      case '4':
        back = true;
        break;
      default:
        print('Invalid choice. Please try again.');
    }
  }
}

Future<void> createOrder(
  BillingService billingService,
  TableService tableService,
  MenuService menuService,
) async {
  print('\n=== Create New Order ===');

  // Show occupied tables
  final occupiedTables = tableService.getOccupiedTables();
  if (occupiedTables.isEmpty) {
    print('No tables are occupied! Please book a table first.');
    return;
  }

  print('Occupied Tables:');
  for (final table in occupiedTables) {
    print('Table ${table.number} (${table.customerCount} people)');
  }

  stdout.write('Enter table number: ');
  final tableNumber = int.tryParse(stdin.readLineSync() ?? '') ?? 0;

  // Show menu
  viewMenu(menuService);

  final items = <Map<String, dynamic>>[];
  print('\nAdd items to order (enter blank to finish):');
  while (true) {
    stdout.write('Enter menu item ID: ');
    final itemId = stdin.readLineSync() ?? '';
    if (itemId.isEmpty) break;

    final menuItem = menuService.getMenuItemById(itemId);
    if (menuItem == null) {
      print('Menu item not found!');
      continue;
    }

    stdout.write('Enter quantity: ');
    final quantity = int.tryParse(stdin.readLineSync() ?? '1') ?? 1;

    items.add({'menuItemId': itemId, 'quantity': quantity});
  }

  if (items.isEmpty) {
    print('No items added to order!');
    return;
  }

  stdout.write('Apply discount (0-100%)? (enter for none): ');
  final discountInput = stdin.readLineSync() ?? '';
  double? discount;
  if (discountInput.isNotEmpty) {
    discount = double.tryParse(discountInput) ?? 0.0;
    if (discount > 100) discount = 100.0;
    if (discount < 0) discount = 0.0;
    discount = discount / 100;
  }

  try {
    final order = await billingService.createOrder(
      tableNumber: tableNumber,
      items: items,
      discount: discount,
    );

    print('\n=== Order Created Successfully ===');
    print('Order ID: ${order.id}');
    print('Table: ${order.tableNumber}');
    print('Total: ₹${order.total.toStringAsFixed(2)}');
    print('=================================');
  } catch (e) {
    print('Error creating order: $e');
  }
}

Future<void> salesReports(
  ReportService reportService,
  OrderService orderService,
) async {
  bool back = false;
  while (!back) {
    print('\n=== Sales Reports ===');
    print('1. Generate Sales Report');
    print('2. View Orders');
    print('3. Back to Main Menu');
    print('======================');

    stdout.write('Enter your choice: ');
    final choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        await generateSalesReport(reportService, orderService);
        break;
      case '2':
        viewOrders(orderService);
        break;
      case '3':
        back = true;
        break;
      default:
        print('Invalid choice. Please try again.');
    }
  }
}

Future<void> generateSalesReport(
  ReportService reportService,
  OrderService orderService,
) async {
  await reportService.generateSalesReport(orderService.orders);
  print('Sales report generated successfully at data/sales_report.csv');
}

void viewOrders(OrderService orderService) {
  print('\n=== All Orders ===');
  for (final order in orderService.orders) {
    print('Order ID: ${order.id}');
    print('Table: ${order.tableNumber}');
    print('Date: ${order.orderTime}');
    print('Total: ₹${order.total.toStringAsFixed(2)}');
    print('Items:');
    for (final item in order.items) {
      print('  ${item.menuItem.name} x ${item.quantity}');
    }
    print('-----------------------');
  }
}

Future<void> inventoryManagement(InventoryService inventoryService) async {
  bool back = false;
  while (!back) {
    print('\n=== Inventory Management ===');
    print('1. View Inventory');
    print('2. Add Inventory Item');
    print('3. Update Inventory Item');
    print('4. Delete Inventory Item');
    print('5. View Low Stock Items');
    print('6. Back to Main Menu');
    print('============================');

    stdout.write('Enter your choice: ');
    final choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        viewInventory(inventoryService);
        break;
      case '2':
        await addInventoryItem(inventoryService);
        break;
      case '3':
        await updateInventoryItem(inventoryService);
        break;
      case '4':
        await deleteInventoryItem(inventoryService);
        break;
      case '5':
        viewLowStockItems(inventoryService);
        break;
      case '6':
        back = true;
        break;
      default:
        print('Invalid choice. Please try again.');
    }
  }
}

void viewInventory(InventoryService inventoryService) {
  print('\n=== Inventory Items ===');
  for (final item in inventoryService.inventoryItems) {
    print('ID: ${item.id}');
    print('Name: ${item.name}');
    print('Quantity: ${item.quantity} ${item.unit}');
    print('Threshold: ${item.threshold} ${item.unit}');
    print('Status: ${item.quantity < item.threshold ? 'LOW STOCK' : 'OK'}');
    print('-----------------------');
  }
}

void viewLowStockItems(InventoryService inventoryService) {
  final lowStockItems = inventoryService.getLowStockItems();
  if (lowStockItems.isEmpty) {
    print('\nNo items are low on stock!');
    return;
  }

  print('\n=== Low Stock Items ===');
  for (final item in lowStockItems) {
    print('ID: ${item.id}');
    print('Name: ${item.name}');
    print(
      'Quantity: ${item.quantity} ${item.unit} (threshold: ${item.threshold})',
    );
    print('-----------------------');
  }
}

Future<void> addInventoryItem(InventoryService inventoryService) async {
  print('\n=== Add New Inventory Item ===');

  stdout.write('Enter item ID: ');
  final id = stdin.readLineSync() ?? '';

  stdout.write('Enter item name: ');
  final name = stdin.readLineSync() ?? '';

  stdout.write('Enter unit (kg, g, pieces, etc.): ');
  final unit = stdin.readLineSync() ?? '';

  stdout.write('Enter initial quantity: ');
  final quantity = double.tryParse(stdin.readLineSync() ?? '0') ?? 0.0;

  stdout.write('Enter threshold for low stock: ');
  final threshold = double.tryParse(stdin.readLineSync() ?? '0') ?? 0.0;

  final newItem = InventoryItem(
    id: id,
    name: name,
    unit: unit,
    quantity: quantity,
    threshold: threshold,
  );

  inventoryService.addInventoryItem(newItem);
  print('Inventory item added successfully!');
}

Future<void> updateInventoryItem(InventoryService inventoryService) async {
  print('\n=== Update Inventory Item ===');
  viewInventory(inventoryService);

  stdout.write('Enter item ID to update: ');
  final id = stdin.readLineSync() ?? '';

  final item = inventoryService.inventoryItems.firstWhere(
    (item) => item.id == id,
    orElse: () => throw Exception('Item not found'),
  );

  stdout.write('Enter new name (${item.name}): ');
  final name = stdin.readLineSync() ?? item.name;

  stdout.write('Enter new unit (${item.unit}): ');
  final unit = stdin.readLineSync() ?? item.unit;

  stdout.write('Enter new quantity (${item.quantity}): ');
  final quantity =
      double.tryParse(stdin.readLineSync() ?? item.quantity.toString()) ??
      item.quantity;

  stdout.write('Enter new threshold (${item.threshold}): ');
  final threshold =
      double.tryParse(stdin.readLineSync() ?? item.threshold.toString()) ??
      item.threshold;

  final updatedItem = InventoryItem(
    id: item.id,
    name: name,
    unit: unit,
    quantity: quantity,
    threshold: threshold,
  );

  inventoryService.updateInventoryItem(id, updatedItem);
  print('Inventory item updated successfully!');
}

Future<void> deleteInventoryItem(InventoryService inventoryService) async {
  print('\n=== Delete Inventory Item ===');
  viewInventory(inventoryService);

  stdout.write('Enter item ID to delete: ');
  final id = stdin.readLineSync() ?? '';

  inventoryService.deleteInventoryItem(id);
  print('Inventory item deleted successfully!');
}

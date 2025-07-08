//importing required dart and project files.
import 'dart:io';
import 'models/menu_item.dart';
import 'models/order.dart';
import 'services/menu_service.dart';
import 'services/table_service.dart';
import 'services/order_service.dart';
import 'services/billing_service.dart';
import 'services/report_service.dart';
import 'services/inventory_service.dart';

void main() {
  // Setup folders if not exist
  Directory('data/invoices').createSync(recursive: true);
  File('data/menu.json').createSync(recursive: true);
  File('data/tables.json').createSync(recursive: true);
  File('data/inventory.json').createSync(recursive: true);

  // Initialize services
  final menuService = MenuService();
  final tableService = TableService();
  final orderService = OrderService();
  final billingService = BillingService();
  final reportService = ReportService();
  final inventoryService = InventoryService();

  // Load saved data
  menuService.loadMenu();
  tableService.loadTables();
  inventoryService.loadInventory();

  while (true) {
    print("\n👋 Welcome to Restaurant Management System");
    print("1. Admin");
    print("2. Waiter");
    print("3. Cashier");
    print("0. Exit");

    stdout.write("Enter role number: ");
    String? role = stdin.readLineSync();

    switch (role) {
      case '1':
        adminMenu(menuService, reportService, inventoryService);
        break;
      case '2':
        waiterMenu(menuService, tableService, orderService, inventoryService);
        break;
      case '3':
        cashierMenu(orderService, billingService);
        break;
      case '0':
        print("👋 Goodbye!");
        return;
      default:
        print("❌ Invalid choice");
    }
  }
}

// ================= Admin Menu =================

void adminMenu(MenuService menu, ReportService report, InventoryService inventory) {
  while (true) {
    print("\n🛠 Admin Menu:");
    print("1. Add Menu Item");
    print("2. View Menu");
    print("3. Delete Menu Item");
    print("4. View Inventory");
    print("5. Generate Sales Report");
    print("0. Back");

    stdout.write("Choice: ");
    String? choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        stdout.write("Item Name: ");
        String name = stdin.readLineSync()!;
        stdout.write("Price: ");
        double price = double.parse(stdin.readLineSync()!);
        stdout.write("Category: ");
        String category = stdin.readLineSync()!;
        stdout.write("Available (yes/no): ");
        bool available = stdin.readLineSync()!.toLowerCase() == 'yes';

        final item = MenuItem(
          name: name,
          price: price,
          category: category,
          isAvailable: available,
        );

        menu.addMenuItem(item);
        menu.saveMenu();
        break;

      case '2':
        menu.viewMenu();
        break;

      case '3':
        stdout.write("Enter item name to delete: ");
        String name = stdin.readLineSync()!;
        menu.deleteMenuItem(name);
        menu.saveMenu();
        break;

      case '4':
        inventory.viewInventory();
        break;

      case '5':
        report.generateReport();
        break;

      case '0':
        return;

      default:
        print("❌ Invalid choice.");
    }
  }
}

// ================= Waiter Menu =================

void waiterMenu(MenuService menu, TableService table, OrderService orderService, InventoryService inventory) {
  while (true) {
    print("\n🧑‍🍳 Waiter Menu:");
    print("1. View Menu");
    print("2. View Tables");
    print("3. Book Table");
    print("4. Free Table");
    print("5. Take Order");
    print("0. Back");

    stdout.write("Choice: ");
    String? choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        menu.viewMenu();
        break;

      case '2':
        table.showTableStatus();
        break;

      case '3':
        stdout.write("Enter table number to book: ");
        int num = int.parse(stdin.readLineSync()!);
        table.bookTable(num);
        break;

      case '4':
        stdout.write("Enter table number to free: ");
        int num = int.parse(stdin.readLineSync()!);
        table.freeTable(num);
        break;

      case '5':
        takeOrder(menu, table, orderService, inventory);
        break;

      case '0':
        return;

      default:
        print("❌ Invalid choice.");
    }
  }
}

// ================= Cashier Menu =================

void cashierMenu(OrderService orderService, BillingService billingService) {
  while (true) {
    print("\n💰 Cashier Menu:");
    print("1. View Orders");
    print("2. Generate Bill");
    print("0. Back");

    stdout.write("Choice: ");
    String? choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        orderService.showOrders();
        break;

      case '2':
        stdout.write("Enter table number to bill: ");
        int tableNo = int.parse(stdin.readLineSync()!);

        final order = orderService.getOrders().firstWhere(
          (o) => o.tableNumber == tableNo,
          orElse: () => Order(tableNumber: 0, items: []),
        );

        if (order.items.isEmpty) {
          print("❌ No order found for table $tableNo");
        } else {
          billingService.generateBill(order);
        }
        break;

      case '0':
        return;

      default:
        print("❌ Invalid choice.");
    }
  }
}

// ================= Take Order =================

void takeOrder(MenuService menu, TableService table, OrderService orderService, InventoryService inventory) {
  stdout.write("Enter table number: ");
  int tableNo = int.parse(stdin.readLineSync()!);

  final tableIsBooked = table.tables.any((t) => t.tableNumber == tableNo && t.isOccupied);
  if (!tableIsBooked) {
    print("⚠️ Table not booked. Please book first.");
    return;
  }

  List<OrderItem> items = [];

  while (true) {
    menu.viewMenu();
    stdout.write("Enter item name (or 'done'): ");
    String itemName = stdin.readLineSync()!;
    if (itemName.toLowerCase() == 'done') break;

    final item = menu.menuList.firstWhere(
      (i) => i.name.toLowerCase() == itemName.toLowerCase() && i.isAvailable,
      orElse: () => MenuItem(name: '', price: 0, category: '', isAvailable: false),
    );

    if (item.name == '') {
      print("❌ Item not found or unavailable.");
      continue;
    }

    stdout.write("Quantity: ");
    int qty = int.parse(stdin.readLineSync()!);

    items.add(OrderItem(itemName: item.name, quantity: qty, price: item.price));
    inventory.reduceStock(item.name, qty.toDouble());
  }

  stdout.write("Enter discount amount: ");
  double discount = double.tryParse(stdin.readLineSync()!) ?? 0.0;

  final order = Order(tableNumber: tableNo, items: items, discount: discount);
  orderService.placeOrder(order);
}

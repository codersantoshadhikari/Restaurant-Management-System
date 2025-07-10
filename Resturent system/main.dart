import 'dart:io';
import 'models/user.dart';
import 'models/menu_item.dart';
import 'models/inventory_item.dart';
import 'services/auth_service.dart';
import 'services/menu_service.dart';
import 'services/table_service.dart';
import 'services/order_service.dart';
import 'services/billing_service.dart';
import 'services/inventory_service.dart';
import 'services/report_service.dart';
import 'utils/file_handler.dart';
import 'utils/validator.dart';

void main() async {
  // Initialize data directory
  await FileHandler.initializeDataDirectory();

  // Initialize services
  final authService = AuthService();
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
  await authService.loadUsers();
  await menuService.loadMenu();
  await tableService.loadTables();
  await inventoryService.loadInventory();
  await orderService.loadOrders(menuService);

  // Check if admin user exists, if not create one
  if (authService.users.isEmpty) {
    final adminUser = User(
      id: '1',
      name: 'Admin',
      email: 'admin@restaurant.com',
      password: 'admin123',
      role: 'admin',
    );
    await authService.addUser(adminUser);
  }

  // Login
  User? currentUser;
  while (currentUser == null) {
    print('\n=== Restaurant Management System Login ===');
    stdout.write('Email: ');
    final email = stdin.readLineSync() ?? '';
    stdout.write('Password: ');
    final password = stdin.readLineSync() ?? '';

    currentUser = authService.authenticate(email, password);
    if (currentUser == null) {
      print('Invalid email or password. Please try again.');
    }
  }

  // Main menu
  bool exit = false;
  while (!exit) {
    print('\n=== Restaurant Management System ===');
    print('Logged in as: ${currentUser.name} (${currentUser.role})');
    print('1. Menu Management');
    print('2. Table Management');
    print('3. Order & Billing');
    print('4. Reports');
    print('5. Inventory Management');
    if (currentUser.role == 'admin') {
      print('6. User Management');
    }
    print('0. Exit');
    print('===================================');

    stdout.write('Enter your choice: ');
    final choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        await menuManagement(menuService, currentUser);
        break;
      case '2':
        await tableManagement(tableService, currentUser);
        break;
      case '3':
        await orderManagement(
          billingService,
          tableService,
          menuService,
          currentUser,
        );
        break;
      case '4':
        await reportManagement(
          reportService,
          orderService,
          inventoryService,
          currentUser,
        );
        break;
      case '5':
        await inventoryManagement(inventoryService, currentUser);
        break;
      case '6':
        if (currentUser.role == 'admin') {
          await userManagement(authService, currentUser);
        } else {
          print('Invalid choice. Please try again.');
        }
        break;
      case '0':
        exit = true;
        break;
      default:
        print('Invalid choice. Please try again.');
    }
  }
}

// ... [Include all the management functions from previous implementation]
// These would include:
// - menuManagement()
// - tableManagement()
// - orderManagement()
// - reportManagement()
// - inventoryManagement()
// - userManagement()
// - All their helper functions like viewMenu(), addMenuItem(), etc.

// Note: The complete implementation would be very long (1000+ lines)
// The functions would follow the same pattern as shown in the services
// with appropriate user interface handling for console input/output
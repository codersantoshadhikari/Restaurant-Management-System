import 'dart:io';
import 'models/inventory_item.dart';
import 'models/menu_item.dart';
import 'models/table.dart';
import 'models/user.dart';
import 'services/auth_service.dart';
import 'services/billing_service.dart';
import 'services/inventory_service.dart';
import 'services/menu_service.dart';
import 'services/order_service.dart';
import 'services/report_service.dart';
import 'services/table_service.dart';
import 'services/transfer_service.dart';

//MAIN FUNCTION
void main() async {
  try {
    _initializeSystem(); //Loads Data from Data Storage
    _clearScreen();
    _printWelcome();

    // USER Authentication
    final user = await _authenticateUser();
    _clearScreen();
    print('Welcome, ${user.username} (${user.role.toUpperCase()})!\n');

    // Role-based routing
    switch (user.role) {
      case 'admin':
        await _adminMainMenu();
        break;
      case 'cashier':
        await _cashierMainMenu();
        break;
      case 'waiter':
        await _waiterMainMenu();
        break;
      default:
        throw Exception('Invalid role configuration');
    }
  } catch (e) {
    _showError('System Error', e.toString());
    exit(1);
  }
}

/*AUTHENTICATION FUNCTION For LogIn INPUT*/
Future<User> _authenticateUser() async {
  while (true) {
    try {
      print('Username:');
      final username = stdin.readLineSync()?.trim() ?? '';
      print('Password:');
      final password = stdin.readLineSync()?.trim() ?? '';

      if (username.isEmpty || password.isEmpty) {
        throw Exception('Credentials cannot be empty');
      }

      return await AuthService.login(username, password);
    } catch (e) {
      _showError('Login Failed', e.toString());
    }
  }
}

/*ADMIN MENU SYSTEM*/
Future<void> _adminMainMenu() async {
  const options = [
    'Take Attendance',
    'Manage Menu',
    'Manage Tables',
    'Manage Inventory',
    'Generate Reports',
    'View Branch Inventory',
    'Handle Transfer',
    'Exit System',
  ];

  while (true) {
    _clearScreen();
    _printHeader('ADMIN DASHBOARD');
    final choice = _showMenu(options);

    switch (choice) {
      case 1:
        await _takeattendance();
        break;
      case 2:
        await _menuManagement();
        break;
      case 3:
        await _tableManagement();
        break;
      case 4:
        await _inventoryManagement();
        break;
      case 5:
        await _reportManagement();
        break;
      case 6:
        await _viewBranchInventory();
        ;
        break;
      case 7:
        await _handleTransfer();
        break;
      case 8:
        _confirmExit();
        break;
    }
  }
}

/*OPERATION FOR TAKING ATTENDANCE*/
Future<void> _takeattendance() async {
  const options = ['Check-In', 'Check-Out', 'Back'];

  while (true) {
    _clearScreen();
    _printHeader('MENU MANAGEMENT');
    final choice = _showMenu(options);

    switch (choice) {
      case 1:
        await _checkin();
        _pressEnterToContinue();
        break;
      case 2:
        await _checkout();
        break;

      case 3:
        return;
    }
  }
}

/*SUBOPERATION FOR ATTENDANCE*/
Future<void> _checkin() async {}
Future<void> _checkout() async {}

/*OPERATION OF MENUMANAGEMENT*/
Future<void> _menuManagement() async {
  const options = ['View Menu', 'Add Menu Item', 'Toggle Availability', 'Back'];

  while (true) {
    _clearScreen();
    _printHeader('MENU MANAGEMENT');
    final choice = _showMenu(options);

    switch (choice) {
      case 1:
        await _displayFullMenu();
        _pressEnterToContinue();
        break;
      case 2:
        await _addMenuItem();
        break;
      case 3:
        await _toggleMenuItemAvailability();
        break;
      case 4:
        return;
    }
  }
}

/*SUB OPERATIONS OF MENU MANAGEMENT BY ADMIN*/
Future<void> _displayFullMenu() async {
  final menu = await MenuService.getMenu();
  _clearScreen();
  _printHeader('CURRENT MENU');

  print('ID  Item                Price   Category        Status');
  print('-' * 60);

  for (final item in menu) {
    print(
      '${item.id.toString().padLeft(2)}. '
      '${item.name.padRight(18)} \$${item.price.toStringAsFixed(2).padLeft(6)} '
      '${item.category.padRight(14)} '
      '${item.isAvailable ? '✅' : '❌'}',
    );
  }
}

Future<void> _addMenuItem() async {
  _clearScreen();
  _printHeader('ADD MENU ITEM');

  final id = _promptForInt('Enter item ID:');
  final name = _promptForString('Enter item name:', required: true);
  final price = _promptForDouble('Enter price:');
  final category = _promptForString('Enter category:', required: true);

  await MenuService.addItem(
    MenuItem(id: id, name: name, price: price, category: category),
  );

  print('\nItem added successfully!✅');
  _pressEnterToContinue();
}

Future<void> _toggleMenuItemAvailability() async {
  await _displayFullMenu();
  final itemId = _promptForInt('\nEnter item ID to toggle:');
  await MenuService.toggleAvailability(itemId);
  print('\nAvailability updated!✅');
  _pressEnterToContinue();
}

/* OPERATION OF TABLE MANAGEMENT*/
Future<void> _tableManagement() async {
  const options = ['View All Tables', 'Add New Table', 'Back'];

  while (true) {
    _clearScreen();
    _printHeader('TABLE MANAGEMENT');
    final choice = _showMenu(options);

    switch (choice) {
      case 1:
        await _viewAllTables();
        _pressEnterToContinue();
        break;
      case 2:
        await _addNewTable();
        break;
      case 3:
        return;
    }
  }
}

/*SUB OPERATIONS OF TABLE MANAGEMENT BY ADMIN*/
Future<void> _viewAllTables() async {
  final tables = await TableService.loadTables();
  _clearScreen();
  _printHeader('ALL TABLES');

  print('ID  Capacity  Status      Orders');
  print('-' * 40);

  for (final table in tables) {
    print(
      '${table.id.toString().padLeft(2)}  '
      '${table.capacity.toString().padLeft(8)}  '
      '${table.isOccupied ? '🟡 Occupied'.padRight(12) : '🟢 Available'.padRight(12)}  '
      '${table.orders.length} items',
    );
  }
}

Future<void> _addNewTable() async {
  _clearScreen();
  _printHeader('ADD NEW TABLE');

  final id = _promptForInt('Enter table ID:');
  final capacity = _promptForInt('Enter table capacity:');

  await TableService.addTable(Table(id: id, capacity: capacity));
  print('\nTable added successfully!✅');
  _pressEnterToContinue();
}

/*IT CAN BE REUSED FOR WAITER TOO */
Future<void> _viewActiveOrders() async {
  final tables = await TableService.loadTables();
  final activeTables = tables
      .where((t) => t.isOccupied && t.orders.isNotEmpty)
      .toList();

  _clearScreen();
  _printHeader('ACTIVE ORDERS');

  if (activeTables.isEmpty) {
    print('No active orders found');
  } else {
    for (final table in activeTables) {
      print('\nTable ${table.id} (${table.capacity} seats)');
      print('-' * 30);
      for (final order in table.orders) {
        print(
          '${order.itemName} x${order.quantity} = \$${order.total.toStringAsFixed(2)}',
        );
      }
      print(
        'Total: \$${table.orders.fold(0.0, (sum, order) => sum + order.total).toStringAsFixed(2)}',
      );
    }
  }
  _pressEnterToContinue();
}

/* OPERATION OF INVENTORY MANAGEMENT BY ADMIN*/
Future<void> _inventoryManagement() async {
  const branch = 'lisbon'; // Or make this dynamic based on user selection
  const options = [
    'View Inventory',
    'Add Inventory Item',
    'Update Stock',
    'Remove Item',
    'Back',
  ];

  while (true) {
    _clearScreen();
    _printHeader('INVENTORY MANAGEMENT - ${branch.toUpperCase()}');
    final choice = _showMenu(options);

    switch (choice) {
      case 1:
        await _viewInventory(branch);
        _pressEnterToContinue();
        break;
      case 2:
        await _addInventoryItem(branch);
        break;
      case 3:
        await _updateInventoryItem(branch);
        break;
      case 4:
        await _removeInventoryItem(branch);
        break;
      case 5:
        return;
    }
  }
}

Future<void> _viewInventory(String branch) async {
  final inventory = await InventoryService.getInventory(branch);
  _clearScreen();
  _printHeader('CURRENT INVENTORY - ${branch.toUpperCase()}');

  print('Item                Quantity  Unit');
  print('-' * 40);

  for (final item in inventory) {
    print(
      '${item.item.padRight(20)} '
      '${item.quantity.toString().padLeft(8)}  '
      '${item.unit}',
    );
  }
}

Future<void> _addInventoryItem(String branch) async {
  _clearScreen();
  _printHeader('ADD INVENTORY ITEM - ${branch.toUpperCase()}');

  final item = _promptForString('Item name:', required: true);
  final quantity = _promptForInt('Initial quantity:');
  final unit = _promptForString('Unit (e.g., kg, liters):', required: true);

  try {
    await InventoryService.addItem(
      branch,
      InventoryItem(item: item, quantity: quantity, unit: unit),
    );
    print('\nItem added to inventory! ✅');
  } catch (e) {
    print('\n❌ Error: ${e.toString()}');
  }
  _pressEnterToContinue();
}

Future<void> _updateInventoryItem(String branch) async {
  final inventory = await InventoryService.getInventory(branch);
  if (inventory.isEmpty) {
    print('No inventory items found');
    _pressEnterToContinue();
    return;
  }

  _clearScreen();
  _printHeader('UPDATE INVENTORY - ${branch.toUpperCase()}');
  await _viewInventory(branch);

  final itemName = _promptForString(
    '\nEnter item name to update:',
    required: true,
  );

  // Show current quantity
  final currentItem = inventory.firstWhere(
    (i) => i.item.toLowerCase() == itemName.toLowerCase(),
  );
  final adjustment = _promptForInt(
    'Enter quantity change (+ to add, - to subtract):',
  );

  try {
    await InventoryService.updateQuantity(branch, itemName, adjustment);
    final newQuantity = currentItem.quantity + adjustment;
    print(
      '\n✅ Updated: ${currentItem.item} = $newQuantity ${currentItem.unit}',
    );
  } catch (e) {
    print('\n❌ Error: ${e.toString()}');
  }

  _pressEnterToContinue();
}

Future<void> _removeInventoryItem(String branch) async {
  final inventory = await InventoryService.getInventory(branch);
  if (inventory.isEmpty) {
    print('No inventory items found');
    _pressEnterToContinue();
    return;
  }

  _clearScreen();
  _printHeader('REMOVE ITEM - ${branch.toUpperCase()}');
  await _viewInventory(branch);

  final itemName = _promptForString(
    '\nEnter item name to remove:',
    required: true,
  );

  try {
    await InventoryService.removeItem(branch, itemName);
    print('\nItem removed from inventory! ✅');
  } catch (e) {
    print('\n❌ Error: ${e.toString()}');
  }
  _pressEnterToContinue();
}

/* OPERATION OF REPORT MANAGEMENT BY ADMIN*/
Future<void> _reportManagement() async {
  const options = ['Daily Sales Report', 'Inventory Report', 'Back'];
  // You might want to make this dynamic based on available branches
  const branch = 'lisbon'; // Or get this from user input

  while (true) {
    _clearScreen();
    _printHeader('REPORT GENERATION - ${branch.toUpperCase()}');
    final choice = _showMenu(options);

    switch (choice) {
      case 1:
        await ReportService.generateDailyReport(branch);
        print('\nReport generated in data/branches/$branch/reports/');
        _pressEnterToContinue();
        break;
      case 2:
        await ReportService.generateInventoryReport(branch);
        print('\nReport generated in data/branches/$branch/reports/');
        _pressEnterToContinue();
        break;
      case 3:
        return;
    }
  }
}

/* OPERATION of VIEWING BRANCH INVENTORY BY ADMIN*/
Future<void> _viewBranchInventory() async {
  _clearScreen();
  _printHeader('BRANCH INVENTORY');

  try {
    final branches = await TransferService.getAvailableBranches();
    if (branches.isEmpty) {
      print('No branches found');
      _pressEnterToContinue();
      return;
    }

    // Display clean branch names
    print('Select branch to view:');
    for (int i = 0; i < branches.length; i++) {
      print('${i + 1}. ${branches[i]}');
    }

    final branchIndex =
        _promptForInt('\nEnter choice:', min: 1, max: branches.length) - 1;
    final branchName = branches[branchIndex];

    // Get and display inventory
    final branchData = await TransferService.getBranchData(branchName);
    final inventory = branchData['inventory'] as List;

    _clearScreen();
    _printHeader('${branchName.toUpperCase()} INVENTORY');

    if (inventory.isEmpty) {
      print('No items in inventory');
    } else {
      print('Item                Quantity  Unit');
      print('-' * 40);
      for (final item in inventory) {
        print(
          '${item['item'].toString().padRight(20)} '
          '${item['quantity'].toString().padLeft(8)}  '
          '${item['unit']}',
        );
      }
    }
    _pressEnterToContinue();
  } catch (e) {
    _showError('Inventory Error', e.toString());
  }
}

/* OPERATION of HANDLING TRANSFER BY ADMIN*/
Future<void> _handleTransfer() async {
  _clearScreen();
  _printHeader('INVENTORY TRANSFER');

  try {
    // Get available branches
    final branches = await TransferService.getAvailableBranches();
    if (branches.isEmpty) {
      print('No branches available for transfer');
      _pressEnterToContinue();
      return;
    }

    // Display branches
    print('Available Branches:');
    for (int i = 0; i < branches.length; i++) {
      print('${i + 1}. ${branches[i]}');
    }

    //  SELECT SOURCE BRANCH
    final fromIndex =
        _promptForInt('\nSelect SOURCE branch:', min: 1, max: branches.length) -
        1;
    final fromBranch = branches[fromIndex];

    //SELECT DESTINATION BRANCH BY FILTERING
    final availableDestinations = branches
        .where((b) => b != fromBranch)
        .toList();
    print('\nAvailable Destination Branches:');
    for (int i = 0; i < availableDestinations.length; i++) {
      print('${i + 1}. ${availableDestinations[i]}');
    }

    final toIndex =
        _promptForInt(
          '\nSelect DESTINATION branch:',
          min: 1,
          max: availableDestinations.length,
        ) -
        1;
    final toBranch = availableDestinations[toIndex];
    // Get staff ID OF MANAGER
    final staffId = _promptForString('\nEnter your staff ID:', required: true);

    // GET DETAILS OF ITEM
    final branchData = await TransferService.getBranchData(fromBranch);
    final inventory = branchData['inventory'] as List;
    _clearScreen();
    _printHeader('AVAILABLE ${fromBranch.toUpperCase()} INVENTORY');

    if (inventory.isEmpty) {
      print('No items in inventory');
    } else {
      print('Item                Quantity  Unit');
      print('-' * 40);
      for (final item in inventory) {
        print(
          '${item['item'].toString().padRight(20)} '
          '${item['quantity'].toString().padLeft(8)}  '
          '${item['unit']}',
        );
      }
    }
    final itemName = _promptForString(
      'Enter item name to transfer:',
      required: true,
    );

    // Check available quantity
    final availableQty = await TransferService.getItemStock(
      fromBranch,
      itemName,
    );
    if (availableQty <= 0) {
      throw Exception('Item "$itemName" not available in $fromBranch');
    }

    print('Available quantity in $fromBranch: $availableQty');
    final quantity = _promptForInt(
      'Enter quantity to transfer:',
      min: 1,
      max: availableQty,
    );
    final notes = _promptForString('Enter transfer notes (optional):');

    // Confirm transfer
    print('\n=== TRANSFER SUMMARY ===');
    print('From: $fromBranch');
    print('To: $toBranch');
    print('Item: $itemName');
    print('Quantity: $quantity');
    if (notes.isNotEmpty) print('Notes: $notes');

    final confirm = _promptForString(
      '\nConfirm transfer? (y/n):',
    ).toLowerCase();
    if (confirm != 'y') {
      print('Transfer cancelled');
      _pressEnterToContinue();
      return;
    }
    // Process transfer with staff validation
    await TransferService.transferInventory(
      itemName: itemName,
      quantity: quantity,
      fromBranch: fromBranch,
      toBranch: toBranch,
      staffId: staffId, // Now using entered staff ID
      notes: notes,
    );
    print('''\n
       
   ███████ ██    ██ ███████ ███████ ███████ ███████ ████████✅
   ██╔════╝██║   ██║██╔════╝██╔════╝██╔════╝██╔════╝██╔════╝
   ███████╗██║   ██║██║     ██║     █████╗  ███████╗███████╗
   ╚════██║██║   ██║██║     ██║     ██╔══╝  ╚════██║╚════██║
   ███████║╚██████╔╝╚██████╗╚██████╗███████╗███████║███████║

''');
  } catch (e) {
    print('\n❌ Error: ${e.toString()}');
  }
  _pressEnterToContinue();
}

/*-------------------------------------------------------------------------------------------------------------------------------------------*/
/*CASHIER MENU SYSTEM*/
Future<void> _cashierMainMenu() async {
  const options = [
    'Take Attendance',
    'View Active Orders',
    'Generate Bill',
    'Exit',
  ];

  while (true) {
    _clearScreen();
    _printHeader('CASHIER DASHBOARD');
    final choice = _showMenu(options);

    switch (choice) {
      case 2:
        await _takeattendance();
        break;
      case 3:
        await _viewActiveOrders();
        break;
      case 4:
        await _generateBill();
        break;
      case 5:
        _confirmExit();
        break;
    }
  }
}

/*SUB OPERATION OF CASHIER MENU SYSTEM*/
Future<void> _generateBill() async {
  final tables = await TableService.loadTables();
  final occupiedTables = tables.where((t) => t.isOccupied).toList();

  if (occupiedTables.isEmpty) {
    print('No occupied tables found');
    _pressEnterToContinue();
    return;
  }

  _clearScreen();
  _printHeader('GENERATE BILL');
  print('Occupied Tables:');
  for (final table in occupiedTables) {
    print('${table.id}. Table ${table.id} (${table.orders.length} items)');
  }

  final tableId = _promptForInt('\nEnter table number:');
  await BillingService.generateBill(tableId);
  print('\nBill generated for Table $tableId!✅ ');
  _pressEnterToContinue();
}

/*-------------------------------------------------------------------------------------------------------------------------------------------*/
/*WAITER MENU SYSTEM*/
Future<void> _waiterMainMenu() async {
  const options = [
    'Take Attendance',
    'View Table Status',
    'Book Table',
    'Take Order',
    'Exit',
  ];

  while (true) {
    _clearScreen();
    _printHeader('WAITER DASHBOARD');
    final choice = _showMenu(options);

    switch (choice) {
      case 1:
        await _takeattendance();
        break;
      case 2:
        await _viewTableStatus();
        break;
      case 3:
        await _bookTable();
        break;
      case 4:
        await _takeOrder();
        break;
      case 5:
        _confirmExit();
        break;
    }
  }
}

/*SUB OPERATIONS OF WAITER MENU SYSTEM*/
Future<void> _viewTableStatus() async {
  final tables = await TableService.loadTables();
  _clearScreen();
  _printHeader('TABLE STATUS');

  for (final table in tables) {
    print(
      'Table ${table.id} (${table.capacity} seats) - '
      '${table.isOccupied ? '🟡 Occupied' : '🟢 Available'}',
    );

    if (table.isOccupied && table.orders.isNotEmpty) {
      print('  Current Orders:');
      for (final order in table.orders) {
        print(
          '  - ${order.itemName} x${order.quantity} '
          '= \$${order.total.toStringAsFixed(2)}',
        );
      }
    }
  }
  _pressEnterToContinue();
}

Future<void> _bookTable() async {
  final tables = await TableService.loadTables();
  final availableTables = tables.where((t) => !t.isOccupied).toList();

  if (availableTables.isEmpty) {
    print('No tables available for booking');
    _pressEnterToContinue();
    return;
  }

  _clearScreen();
  _printHeader('BOOK TABLE');
  print('Available Tables:');
  for (final table in availableTables) {
    print('${table.id}. Table ${table.id} (${table.capacity} seats)');
  }

  final tableId = _promptForInt('\nEnter table number:');
  await TableService.bookTable(tableId);
  print('\nTable $tableId booked successfully!✅');
  _pressEnterToContinue();
}

Future<void> _takeOrder() async {
  final tables = await TableService.loadTables();
  final occupiedTables = tables.where((t) => t.isOccupied).toList();

  if (occupiedTables.isEmpty) {
    print('No occupied tables found');
    _pressEnterToContinue();
    return;
  }

  _clearScreen();
  _printHeader('TAKE ORDER');
  print('Occupied Tables:');
  for (final table in occupiedTables) {
    print('${table.id}. Table ${table.id}');
  }

  final tableId = _promptForInt('\nEnter table number:');
  await _displayFullMenu();

  while (true) {
    print('\nEnter item ID to add (0 to finish):');
    final itemId = _promptForInt('', min: 0);
    if (itemId == 0) break;

    final quantity = _promptForInt('Enter quantity:');

    try {
      await OrderService.addOrder(tableId, itemId, quantity);
      print('Added to order!✅');
    } catch (e) {
      print('❌ Error: ${e.toString()}');
    }
  }
}

/* UTILITY FUNCTIONS */
void _initializeSystem() {
  // Create required directories
  Directory('data/invoices').createSync(recursive: true);

  // Verify required files exist
  const requiredFiles = [
    'data/users.json',
    'data/menu.json',
    'data/tables.json',
    'data/inventory.json',
  ];

  for (final file in requiredFiles) {
    if (!File(file).existsSync()) {
      throw Exception('Missing required file: $file');
    }
  }
  Directory('data/invoices').createSync(recursive: true);
  Directory('data/branches').createSync(recursive: true); // Add this line

  // Verify required files exist
  const requiredFiless = [
    'data/users.json',
    'data/menu.json',
    'data/tables.json',
    'data/inventory.json',
    'data/staff.json', // Add this line
  ];

  for (final file in requiredFiless) {
    if (!File(file).existsSync()) {
      throw Exception('Missing required file: $file');
    }
  }
}

void _clearScreen() {
  print('\x1B[2J\x1B[0;0H'); // ANSI escape codes
}

void _printWelcome() {
  print('''
███████╗███╗   ███╗ █████╗ ██╗████████╗    ██████╗ ███████╗███████╗████████╗ █████╗ ██╗   ██╗██████╗  █████╗ ███╗   ██╗████████╗
██╔════╝████╗ ████║██╔══██╗██║╚══██╔══╝    ██╔══██╗██╔════╝██╔════╝╚══██╔══╝██╔══██╗██║   ██║██╔══██╗██╔══██╗████╗  ██║╚══██╔══╝
███████╗██╔████╔██║███████║██║   ██║       ██████╔╝█████╗  ███████╗   ██║   ███████║██║   ██║██████╔╝███████║██╔██╗ ██║   ██║   
╚════██║██║╚██╔╝██║██╔══██║██║   ██║       ██╔══██╗██╔══╝  ╚════██║   ██║   ██╔══██║██║   ██║██╔══██╗██╔══██║██║╚██╗██║   ██║   
███████║██║ ╚═╝ ██║██║  ██║██║   ██║       ██║  ██║███████╗███████║   ██║   ██║  ██║╚██████╔╝██║  ██║██║  ██║██║ ╚████║   ██║   
╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝   ╚═╝       ╚═╝  ╚═╝╚══════╝╚══════╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝                                                                                                                          
  ''');
}

void _printHeader(String title) {
  print('=== $title ===\n');
}

int _showMenu(List<String> options) {
  for (int i = 0; i < options.length; i++) {
    print('${i + 1}. ${options[i]}');
  }
  return _promptForInt('\nEnter choice:', min: 1, max: options.length);
}

String _promptForString(String prompt, {bool required = false}) {
  while (true) {
    print(prompt);
    final input = stdin.readLineSync()?.trim() ?? '';

    if (!required || input.isNotEmpty) {
      return input;
    }
    print('❌ This field is required');
  }
}

int _promptForInt(String prompt, {int min = 1, int max = 999999}) {
  while (true) {
    print(prompt);
    final input = stdin.readLineSync()?.trim();
    final value = int.tryParse(input ?? '');

    if (value != null && value >= min && value <= max) {
      return value;
    }
    print('❌ Please enter a valid number between $min and $max');
  }
}

double _promptForDouble(String prompt, {double min = 0.01}) {
  while (true) {
    print(prompt);
    final input = stdin.readLineSync()?.trim();
    final value = double.tryParse(input ?? '');

    if (value != null && value >= min) {
      return value;
    }
    print('❌ Please enter a valid amount (minimum \$$min)');
  }
}

void _pressEnterToContinue() {
  print('\nPress Enter to continue...');
  stdin.readLineSync();
}

void _showError(String title, String message) {
  _clearScreen();
  print('❌ ERROR: $title ❌');
  print('=' * (title.length + 10));
  print(message);
  _pressEnterToContinue();
}

void _confirmExit() {
  print('\nAre you sure you want to exit? (y/n)');
  final input = stdin.readLineSync()?.trim().toLowerCase();
  if (input == 'y') {
    _clearScreen();
    print('''
 Thank you for using SMAIT Restaurant Management System!
   ██████╗  ██████╗  ██████╗ ██████╗     ██████╗ ██╗   ██╗███████╗███████╗👋
  ██╔════╝ ██╔═══██╗██╔═══██╗██╔══██╗    ██╔══██╗╚██╗ ██╔╝██╔════╝██╔════╝👋
  ██║  ███╗██║   ██║██║   ██║██║  ██║    ██████╔╝ ╚████╔╝ █████╗  █████╗  
  ██║   ██║██║   ██║██║   ██║██║  ██║    ██╔══██╗  ╚██╔╝  ██╔══╝  ██╔══╝  
  ╚██████╔╝╚██████╔╝╚██████╔╝██████╔╝    ██████╔╝   ██║   ███████╗███████╗👋
   ╚═════╝  ╚═════╝  ╚═════╝ ╚═════╝     ╚═════╝    ╚═╝   ╚══════╝╚══════╝👋
    ''');
    exit(0);
  }
}

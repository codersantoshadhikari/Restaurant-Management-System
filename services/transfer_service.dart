import 'dart:convert';
import 'dart:io';
import 'dart:math';

class TransferService {
  static const String _branchesDir = 'data/branches';
  static const String _transfersDir = 'data/transfers';
  static const String _staffFile = 'data/staff.json';

  // Helper to load staff data
  static Future<List<Map<String, dynamic>>> _loadStaff() async {
    final file = File(_staffFile);
    if (!await file.exists()) {
      throw Exception('Staff database not found at ${file.path}');
    }
    final content = await file.readAsString();
    return List<Map<String, dynamic>>.from(json.decode(content));
  }

  // Validate staff exists and has manager role
  static Future<void> _validateStaff(
    String staffId,
    String requiredBranch,
  ) async {
    final staffList = await _loadStaff();
    final staff = staffList.firstWhere(
      (emp) => emp['id'] == staffId,
      orElse: () => throw Exception('Staff ID $staffId not found'),
    );

    if (staff['role']?.toLowerCase() != 'manager') {
      throw Exception('Only managers can perform transfers');
    }

    if (staff['branch']?.toLowerCase() != requiredBranch.toLowerCase()) {
      throw Exception(
        'Manager ${staff['name']} is not authorized for branch $requiredBranch',
      );
    }
  }

  static String _formatDate(DateTime date) {
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
  }

  static Future<List<String>> getAvailableBranches() async {
    final dir = Directory(_branchesDir);
    if (!await dir.exists()) {
      throw Exception('Branches directory not found at ${dir.path}');
    }

    return await dir
        .list()
        .where((entity) => entity.path.endsWith('.json'))
        .map((entity) {
          final fileName = entity.path.split(Platform.pathSeparator).last;
          return fileName.substring(0, fileName.length - 5); // Remove '.json'
        })
        .toList();
  }

  static Future<Map<String, dynamic>> getBranchData(String branchName) async {
    final file = File('$_branchesDir${Platform.pathSeparator}$branchName.json');
    if (!await file.exists()) {
      final available = await getAvailableBranches();
      throw Exception(
        'Branch "$branchName" not found at ${file.path}. Available branches: ${available.join(', ')}',
      );
    }

    final content = await file.readAsString();
    return json.decode(content);
  }

  static Future<void> updateBranchData(
    String branchName,
    Map<String, dynamic> data,
  ) async {
    final file = File('$_branchesDir${Platform.pathSeparator}$branchName.json');
    await file.writeAsString(json.encode(data));
  }

  static Future<int> getItemStock(String branch, String itemName) async {
    final branchData = await getBranchData(branch);
    final inventory = branchData['inventory'] as List;

    final item = inventory.firstWhere(
      (item) => item['item'].toString().toLowerCase() == itemName.toLowerCase(),
      orElse: () => null,
    );

    return item?['quantity'] ?? 0;
  }

  static Future<void> transferInventory({
    required String itemName,
    required int quantity,
    required String fromBranch,
    required String toBranch,
    required String staffId,
    String notes = '',
  }) async {
    // Validate manager permissions
    await _validateStaff(staffId, fromBranch);

    // Validate transfer parameters
    if (quantity <= 0) throw Exception('Quantity must be positive');
    if (fromBranch == toBranch)
      throw Exception('Cannot transfer to same branch');

    // Load branch data
    final fromData = await getBranchData(fromBranch);
    final toData = await getBranchData(toBranch);

    // Process source inventory
    final fromInventory = fromData['inventory'] as List;
    final fromItem = fromInventory.firstWhere(
      (item) => item['item'].toString().toLowerCase() == itemName.toLowerCase(),
      orElse: () =>
          throw Exception('Item "$itemName" not found in $fromBranch'),
    );

    if (fromItem['quantity'] < quantity) {
      throw Exception(
        'Insufficient stock (Available: ${fromItem['quantity']}, Requested: $quantity)',
      );
    }

    // Process destination inventory
    final toInventory = toData['inventory'] as List;
    final toItemIndex = toInventory.indexWhere(
      (item) => item['item'].toString().toLowerCase() == itemName.toLowerCase(),
    );

    // Update quantities
    fromItem['quantity'] -= quantity;
    if (toItemIndex != -1) {
      toInventory[toItemIndex]['quantity'] += quantity;
    } else {
      toInventory.add({
        'item': itemName,
        'quantity': quantity,
        'unit': fromItem['unit'] ?? 'units',
      });
    }

    // Create transfer record
    final now = DateTime.now();
    final transferId =
        'TRANS-${_formatDate(now)}-${Random().nextInt(9000) + 1000}';
    final transferRecord = {
      'id': transferId,
      'date': now.toIso8601String(),
      'item': itemName,
      'quantity': quantity,
      'from': fromBranch,
      'to': toBranch,
      'staffId': staffId,
      'status': 'completed',
      'notes': notes,
    };

    // Update transfer history
    fromData['transfers'] = [...fromData['transfers'] ?? [], transferRecord];
    toData['transfers'] = [...toData['transfers'] ?? [], transferRecord];

    // Save changes
    await updateBranchData(fromBranch, fromData);
    await updateBranchData(toBranch, toData);

    // Save transfer document
    await _saveTransferDocument(transferRecord);
  }

  static Future<void> _saveTransferDocument(
    Map<String, dynamic> transfer,
  ) async {
    final dir = Directory(_transfersDir);
    if (!await dir.exists()) await dir.create(recursive: true);

    final file = File(
      '${dir.path}${Platform.pathSeparator}${transfer['id']}.json',
    );
    await file.writeAsString(json.encode(transfer));
  }

  static Future<List<Map<String, dynamic>>> getTransferHistory(
    String branchName,
  ) async {
    final branchData = await getBranchData(branchName);
    return List<Map<String, dynamic>>.from(branchData['transfers'] ?? []);
  }

  static Future<Map<String, dynamic>?> getStaffMember(String staffId) async {
    final staffList = await _loadStaff();
    return staffList.firstWhere((emp) => emp['id'] == staffId);
  }
}

/*HANDLES BRANCHES */
import 'dart:convert';
import 'dart:io';

class BranchService {
  static const String _branchesDir = 'data/branches';

  static Future<List<String>> getAvailableBranches() async {
    final dir = Directory(_branchesDir);
    if (!await dir.exists()) return [];

    return await dir
        .list()
        .where((entity) => entity.path.endsWith('.json'))
        .map((entity) => entity.path.split('/').last.split('.').first)
        .toList();
  }

  static Future<Map<String, dynamic>> getBranchData(String branchName) async {
    final file = File('$_branchesDir/$branchName.json');
    if (!await file.exists()) throw Exception('Branch $branchName not found');

    final content = await file.readAsString();
    return json.decode(content);
  }

  static Future<void> updateBranchData(
    String branchName,
    Map<String, dynamic> data,
  ) async {
    final file = File('$_branchesDir/$branchName.json');
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
}

import 'dart:io';
import 'dart:convert';

class FileHandler {
  static const String dataDir = 'data';
  static const String usersFile = '$dataDir/users.json';
  static const String menuFile = '$dataDir/menu.json';
  static const String tablesFile = '$dataDir/tables.json';
  static const String inventoryFile = '$dataDir/inventory.json';
  static const String invoicesDir = '$dataDir/invoices';

  static Future<void> initializeDataDirectory() async {
    final dataDirectory = Directory(dataDir);
    if (!await dataDirectory.exists()) {
      await dataDirectory.create();
    }

    final invoicesDirectory = Directory(invoicesDir);
    if (!await invoicesDirectory.exists()) {
      await invoicesDirectory.create();
    }
  }

  static Future<List<Map<String, dynamic>>> loadJsonFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final jsonData = await file.readAsString();
        final decodedData = json.decode(jsonData);
        if (decodedData is List) {
          return List<Map<String, dynamic>>.from(decodedData);
        }
        return [Map<String, dynamic>.from(decodedData)];
      }
      return [];
    } catch (e) {
      print('Error loading $filePath: $e');
      return [];
    }
  }

  static Future<void> saveJsonFile(
      String filePath, List<Map<String, dynamic>> data) async {
    try {
      final file = File(filePath);
      await file.writeAsString(json.encode(data));
    } catch (e) {
      print('Error saving $filePath: $e');
    }
  }

  static Future<List<String>> getInvoiceFiles() async {
    final directory = Directory(invoicesDir);
    if (await directory.exists()) {
      return await directory
          .list()
          .where((file) => file.path.endsWith('.json'))
          .map((file) => file.path)
          .toList();
    }
    return [];
  }

  static Future<void> saveReport(String fileName, String content) async {
    final file = File('$invoicesDir/$fileName');
    await file.writeAsString(content);
  }

  static Future<String?> readReport(String fileName) async {
    final file = File('$invoicesDir/$fileName');
    if (await file.exists()) {
      return await file.readAsString();
    }
    return null;
  }
}
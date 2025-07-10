/*FILE TO HANDLE FILES OF TABLES AND MENUS*/
import 'dart:convert';
import 'dart:io';

class FileHandler {
  static Future<Map<String, dynamic>> readJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw Exception('File not found: $path');
    }
    final content = await file.readAsString();
    return jsonDecode(content) as Map<String, dynamic>;
  }

  static Future<void> writeJson(String path, Map<String, dynamic> data) async {
    await File(path).writeAsString(jsonEncode(data));
  }
}

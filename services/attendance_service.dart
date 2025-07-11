import 'dart:io';

class AttendanceService {
  static const String _attendanceDir = 'data/attendance';
  static const String _attendanceFile = '$_attendanceDir/attendance.csv';

  static Future<void> initialize() async {
    final dir = Directory(_attendanceDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final file = File(_attendanceFile);
    if (!await file.exists()) {
      await file.writeAsString('staffId,name,date,checkIn,checkOut\n');
    }
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  static Future<void> checkIn(String staffId, String name) async {
    final now = DateTime.now();
    final file = File(_attendanceFile);
    // Add newline character before appending new record
    await file.writeAsString(
      '\n$staffId,$name,${_formatDate(now)},${_formatTime(now)},',
      mode: FileMode.append,
    );
  }

  static Future<void> checkOut(String staffId) async {
    final now = DateTime.now();
    final file = File(_attendanceFile);
    final lines = await file.readAsLines();

    // Find the last check-in without check-out
    for (int i = lines.length - 1; i >= 0; i--) {
      if (lines[i].startsWith('$staffId,') && lines[i].endsWith(',')) {
        lines[i] = '${lines[i]}${_formatTime(now)}';
        await file.writeAsString(lines.join('\n'));
        return;
      }
    }

    throw Exception('No open check-in found for staff $staffId');
  }

  static Future<List<Map<String, dynamic>>> getAttendanceRecords() async {
    final file = File(_attendanceFile);
    if (!await file.exists()) return [];

    final lines = await file.readAsLines();
    if (lines.length <= 1) return []; // Skip header

    return lines.skip(1).where((line) => line.trim().isNotEmpty).map((line) {
      final parts = line.split(',');
      return {
        'staffId': parts[0],
        'name': parts[1],
        'date': parts[2],
        'checkIn': parts[3],
        'checkOut': parts.length > 4 && parts[4].isNotEmpty ? parts[4] : null,
      };
    }).toList();
  }
}

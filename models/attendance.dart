// attendance.dart
class AttendanceRecord {
  final String staffId;
  final String name;
  final String date;
  final String checkIn;
  final String? checkOut;

  AttendanceRecord({
    required this.staffId,
    required this.name,
    required this.date,
    required this.checkIn,
    this.checkOut,
  });

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      staffId: map['staffId'],
      name: map['name'],
      date: map['date'],
      checkIn: map['checkIn'],
      checkOut: map['checkOut'],
    );
  }
}

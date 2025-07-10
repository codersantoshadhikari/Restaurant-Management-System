class RestaurantTable {
  final int number;
  bool isOccupied;
  int? customerCount;
  DateTime? bookingTime;

  RestaurantTable({
    required this.number,
    this.isOccupied = false,
    this.customerCount,
    this.bookingTime,
  });

  factory RestaurantTable.fromJson(Map<String, dynamic> json) {
    return RestaurantTable(
      number: json['number'],
      isOccupied: json['isOccupied'],
      customerCount: json['customerCount'],
      bookingTime: json['bookingTime'] != null
          ? DateTime.parse(json['bookingTime'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'isOccupied': isOccupied,
      'customerCount': customerCount,
      'bookingTime': bookingTime?.toIso8601String(),
    };
  }
}
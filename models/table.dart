class RestaurantTable {
  int tableNumber;
  bool isOccupied;

  RestaurantTable({
    required this.tableNumber,
    this.isOccupied = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'tableNumber': tableNumber,
      'isOccupied': isOccupied,
    };
  }

  factory RestaurantTable.fromJson(Map<String, dynamic> json) {
    return RestaurantTable(
      tableNumber: json['tableNumber'],
      isOccupied: json['isOccupied'],
    );
  }
}

import 'order.dart';

class Table {
  final int id;
  final int capacity;
  bool isOccupied;
  List<Order> orders;

  Table({
    required this.id,
    required this.capacity,
    this.isOccupied = false,
    this.orders = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'capacity': capacity,
    'isOccupied': isOccupied,
    'orders': orders.map((o) => o.toJson()).toList(),
  };
}

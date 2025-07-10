class OrderItem {
  final MenuItem menuItem;
  int quantity;

  OrderItem({required this.menuItem, required this.quantity});
}

class Order {
  final String id;
  final int tableNumber;
  final DateTime orderTime;
  final List<OrderItem> items;
  double? discount;
  bool isPaid;

  Order({
    required this.id,
    required this.tableNumber,
    required this.items,
    this.discount,
    this.isPaid = false,
  }) : orderTime = DateTime.now();

  double get subtotal {
    return items.fold(
      0,
      (sum, item) => sum + (item.menuItem.price * item.quantity),
    );
  }

  double get gst => subtotal * 0.18;

  double get total {
    double amount = subtotal + gst;
    if (discount != null) {
      amount -= amount * discount!;
    }
    return amount;
  }

  factory Order.fromJson(Map<String, dynamic> json, List<MenuItem> menuItems) {
    final items = (json['items'] as List).map((item) {
      final menuItem = menuItems.firstWhere((m) => m.id == item['menuItemId']);
      return OrderItem(menuItem: menuItem, quantity: item['quantity']);
    }).toList();

    return Order(
      id: json['id'],
      tableNumber: json['tableNumber'],
      items: items,
      discount: json['discount']?.toDouble(),
      isPaid: json['isPaid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tableNumber': tableNumber,
      'orderTime': orderTime.toIso8601String(),
      'items': items
          .map(
            (item) => {
              'menuItemId': item.menuItem.id,
              'quantity': item.quantity,
            },
          )
          .toList(),
      'discount': discount,
      'isPaid': isPaid,
    };
  }
}
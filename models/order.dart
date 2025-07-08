class OrderItem {
  String itemName;
  int quantity;
  double price;

  OrderItem({
    required this.itemName,
    required this.quantity,
    required this.price,
  });

  double get total => quantity * price;
}

class Order {
  int tableNumber;
  List<OrderItem> items;
  double discount;

  Order({
    required this.tableNumber,
    required this.items,
    this.discount = 0.0,
  });

  double get subtotal => items.fold(0, (sum, item) => sum + item.total);
  double get gst => subtotal * 0.18;
  double get total => subtotal + gst - discount;
}

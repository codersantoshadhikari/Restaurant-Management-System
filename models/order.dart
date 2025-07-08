class Order {
  final String itemName;
  final double price;
  final int quantity;

  Order({required this.itemName, required this.price, required this.quantity});

  double get total => price * quantity;

  Map<String, dynamic> toJson() => {
    'itemName': itemName,
    'price': price,
    'quantity': quantity,
  };
}

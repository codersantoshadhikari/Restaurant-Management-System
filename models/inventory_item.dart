// File: models/inventory_item.dart

class InventoryItem {
  String name;
  double price;
  int quantity;

  InventoryItem({
    required this.name,
    required this.price,
    required this.quantity,
  });

  // Factory constructor to create an item from JSON data
  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      name: json['name'],
      price: (json['price'] as num).toDouble(), // Handles int or double
      quantity: json['quantity'],
    );
  }

  // Convert InventoryItem to JSON format
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  // String representation for easy printing
  @override
  String toString() {
    return 'Item: $name | Price: \$${price.toStringAsFixed(2)} | Qty: $quantity';
  }
}

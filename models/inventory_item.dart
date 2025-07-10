class InventoryItem {
  final String item; // Changed from 'name' to 'item' to match JSON
  int quantity;
  final String unit;

  InventoryItem({
    required this.item,
    required this.quantity,
    required this.unit,
  });

  Map<String, dynamic> toJson() => {
    'item': item,
    'quantity': quantity,
    'unit': unit,
  };

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      item: json['item'] as String,
      quantity: json['quantity'] as int,
      unit: json['unit'] as String,
    );
  }
}

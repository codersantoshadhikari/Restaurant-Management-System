class InventoryItem {
  final String name;
  int quantity;
  final String unit;

  InventoryItem({
    required this.name,
    required this.quantity,
    required this.unit,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'quantity': quantity,
    'unit': unit,
  };
}

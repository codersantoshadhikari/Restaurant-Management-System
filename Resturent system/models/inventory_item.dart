class InventoryItem {
  final String id;
  final String name;
  final String unit;
  double quantity;
  final double threshold;

  InventoryItem({
    required this.id,
    required this.name,
    required this.unit,
    required this.quantity,
    required this.threshold,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'],
      name: json['name'],
      unit: json['unit'],
      quantity: json['quantity'].toDouble(),
      threshold: json['threshold'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'unit': unit,
      'quantity': quantity,
      'threshold': threshold,
    };
  }
}

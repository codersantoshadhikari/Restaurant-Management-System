class MenuItem {
  final int id;
  final String name;
  final double price;
  final String category;
  bool isAvailable;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.isAvailable = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'category': category,
    'isAvailable': isAvailable,
  };
}

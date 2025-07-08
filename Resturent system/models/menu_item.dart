class MenuItem {
  final String id;
  final String name;
  final double price;
  final String category;
  bool isAvailable;
  final Map<String, double> ingredients;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.isAvailable = true,
    required this.ingredients,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      category: json['category'],
      isAvailable: json['isAvailable'],
      ingredients: Map<String, double>.from(json['ingredients']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'isAvailable': isAvailable,
      'ingredients': ingredients,
    };
  }
}

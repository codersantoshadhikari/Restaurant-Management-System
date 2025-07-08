

class MenuItem {
  String name;
  double price;
  String category;
  bool isAvailable;

  MenuItem({
    required this.name,
    required this.price,
    required this.category,
    required this.isAvailable,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'category': category,
      'isAvailable': isAvailable,
    };
  }


  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      name: json['name'],
      price: json['price'],
      category: json['category'],
      isAvailable: json['isAvailable'],
    );
  }
}

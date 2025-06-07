class MenuItem {
  final int? id;
  final String name;
  final int price;
  final String imagePath;

  MenuItem({
    this.id,
    required this.name,
    required this.price,
    required this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image_path': imagePath,
    };
  }

  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      imagePath: map['image_path'],
    );
  }
}
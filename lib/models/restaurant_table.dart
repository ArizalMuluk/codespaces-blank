class RestaurantTable {
  final int? id;
  final String name;
  final String status; // "Kosong", "Belum Bayar", "Sudah Bayar"

  RestaurantTable({
    this.id,
    required this.name,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'status': status,
    };
  }

  factory RestaurantTable.fromMap(Map<String, dynamic> map) {
    return RestaurantTable(
      id: map['id'],
      name: map['name'],
      status: map['status'],
    );
  }
}
class TransactionDetail {
  final int? id;
  final int transactionId;
  final int menuItemId;
  final int quantity;
  final int pricePerItem;

  TransactionDetail({
    this.id,
    required this.transactionId,
    required this.menuItemId,
    required this.quantity,
    required this.pricePerItem,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'menu_item_id': menuItemId,
      'quantity': quantity,
      'price_per_item': pricePerItem,
    };
  }

  factory TransactionDetail.fromMap(Map<String, dynamic> map) {
    return TransactionDetail(
      id: map['id'],
      transactionId: map['transaction_id'],
      menuItemId: map['menu_item_id'],
      quantity: map['quantity'],
      pricePerItem: map['price_per_item'],
    );
  }
}
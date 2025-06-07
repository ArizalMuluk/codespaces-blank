class Transaction {
  final int? id;
  final int totalAmount;
  final int cashReceived;
  final int changeGiven;
  final String? tableName;
  final String createdAt;

  Transaction({
    this.id,
    required this.totalAmount,
    required this.cashReceived,
    required this.changeGiven,
    this.tableName,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'total_amount': totalAmount,
      'cash_received': cashReceived,
      'change_given': changeGiven,
      'table_name': tableName,
      'created_at': createdAt,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      totalAmount: map['total_amount'],
      cashReceived: map['cash_received'],
      changeGiven: map['change_given'],
      tableName: map['table_name'],
      createdAt: map['created_at'],
    );
  }
}
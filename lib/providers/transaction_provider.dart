import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../models/transaction_detail.dart';
import '../database/database_helper.dart';

class TransactionProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Transaction> _transactions = [];

  List<Transaction> get transactions => _transactions;

  Future<void> loadTransactions() async {
    _transactions = await _dbHelper.getTransactions();
    notifyListeners();
  }

  Future<int> addTransaction(Transaction transaction, List<TransactionDetail> details) async {
    final transactionId = await _dbHelper.insertTransaction(transaction);
    
    for (final detail in details) {
      final updatedDetail = TransactionDetail(
        transactionId: transactionId,
        menuItemId: detail.menuItemId,
        quantity: detail.quantity,
        pricePerItem: detail.pricePerItem,
      );
      await _dbHelper.insertTransactionDetail(updatedDetail);
    }
    
    await loadTransactions();
    return transactionId;
  }

  Future<Map<String, dynamic>> getFinancialSummary() async {
    return await _dbHelper.getFinancialSummary();
  }
}
import 'package:flutter/foundation.dart';
import '../models/restaurant_table.dart';
import '../database/database_helper.dart';

class TableProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<RestaurantTable> _tables = [];

  List<RestaurantTable> get tables => _tables;

  Future<void> loadTables() async {
    _tables = await _dbHelper.getTables();
    notifyListeners();
  }

  Future<void> addTable(RestaurantTable table) async {
    await _dbHelper.insertTable(table);
    await loadTables();
  }

  Future<void> updateTable(RestaurantTable table) async {
    await _dbHelper.updateTable(table);
    await loadTables();
  }

  Future<void> deleteTable(int id) async {
    await _dbHelper.deleteTable(id);
    await loadTables();
  }
}
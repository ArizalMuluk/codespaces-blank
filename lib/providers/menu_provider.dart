import 'package:flutter/foundation.dart';
import '../models/menu_item.dart';
import '../database/database_helper.dart';

class MenuProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<MenuItem> _menuItems = [];

  List<MenuItem> get menuItems => _menuItems;

  Future<void> loadMenuItems() async {
    _menuItems = await _dbHelper.getMenuItems();
    notifyListeners();
  }

  Future<void> addMenuItem(MenuItem item) async {
    await _dbHelper.insertMenuItem(item);
    await loadMenuItems();
  }

  Future<void> updateMenuItem(MenuItem item) async {
    await _dbHelper.updateMenuItem(item);
    await loadMenuItems();
  }

  Future<void> deleteMenuItem(int id) async {
    await _dbHelper.deleteMenuItem(id);
    await loadMenuItems();
  }
}
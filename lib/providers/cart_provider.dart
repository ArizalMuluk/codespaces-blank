import 'package:flutter/foundation.dart';
import '../models/menu_item.dart';

class CartItem {
  final MenuItem menuItem;
  int quantity;

  CartItem({required this.menuItem, this.quantity = 1});
}

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  int get totalPrice => _items.fold(0, (sum, item) => sum + (item.menuItem.price * item.quantity));

  void addItem(MenuItem menuItem) {
    final existingIndex = _items.indexWhere((item) => item.menuItem.id == menuItem.id);
    
    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(menuItem: menuItem));
    }
    notifyListeners();
  }

  void removeItem(MenuItem menuItem) {
    final existingIndex = _items.indexWhere((item) => item.menuItem.id == menuItem.id);
    
    if (existingIndex >= 0) {
      if (_items[existingIndex].quantity > 1) {
        _items[existingIndex].quantity--;
      } else {
        _items.removeAt(existingIndex);
      }
      notifyListeners();
    }
  }

  void updateQuantity(MenuItem menuItem, int quantity) {
    final existingIndex = _items.indexWhere((item) => item.menuItem.id == menuItem.id);
    
    if (existingIndex >= 0) {
      if (quantity <= 0) {
        _items.removeAt(existingIndex);
      } else {
        _items[existingIndex].quantity = quantity;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

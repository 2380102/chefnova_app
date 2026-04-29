import 'package:flutter/material.dart';

class CartModel extends ChangeNotifier {
  final List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => _items;

  int get count => _items.length;

  void addItem(Map<String, dynamic> item) {
    final exists = _items.any((i) => i['name'] == item['name']);
    if (!exists) {
      _items.add(item);
      notifyListeners();
    }
  }

  void removeItem(String name) {
    _items.removeWhere((i) => i['name'] == name);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
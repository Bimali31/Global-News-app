import 'package:flutter/material.dart';

class Category {
  final String name;

  Category({required this.name});
}

class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];

  List<Category> get categories => _categories;

  get selectedCategory => null;

  void addCategory(String categoryName) {
    _categories.add(Category(name: categoryName));
    notifyListeners();
  }

  void removeCategory(String categoryName) {
    _categories.removeWhere((category) => category.name == categoryName);
    notifyListeners();
  }

  void changeCategory(String value) {}
}

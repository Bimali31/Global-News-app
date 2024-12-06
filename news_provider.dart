import 'package:flutter/material.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/services/api_service.dart';

class NewsProvider with ChangeNotifier {
  List<Article> _articles = [];
  bool _isLoading = false;

  List<Article> get articles => _articles;
  bool get isLoading => _isLoading;

  Future<void> fetchNews(String query) async {
    _isLoading = true;
    notifyListeners();

    // Create an instance of ApiService and call fetchArticles
    final apiService = ApiService();
    final news = await apiService.fetchArticles(query);

    _articles = news;
    _isLoading = false;
    notifyListeners();
  }
}

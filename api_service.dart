import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';
import '../utils/constants.dart';

class ApiService {
  static const String _baseUrl = 'https://newsapi.org/v2';

  Future<List<Article>> fetchArticles(String category) async {
    final url = Uri.parse('$_baseUrl/top-headlines?category=$category&apiKey=$newsApiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['articles'] as List).map((e) => Article.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load news');
    }
  }
}

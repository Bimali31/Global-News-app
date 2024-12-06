import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/article_card.dart';
// ignore: duplicate_import
import 'package:news_app/widgets/article_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Global News App')),
      body: Column(
        children: [
          DropdownButton<String>(
            value: categoryProvider.selectedCategory,
            items: categoryProvider.categories
                .map((cat) => DropdownMenuItem(
                      value: cat.name,
                      child: Text(cat.name),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                categoryProvider.changeCategory(value);
                newsProvider.fetchNews(value.toLowerCase());
              }
            },
          ),
          Expanded(
            child: newsProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: newsProvider.articles.length,
                    itemBuilder: (context, index) {
                      return ArticleCard(article: newsProvider.articles[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

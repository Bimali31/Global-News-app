import 'package:flutter/material.dart';
import 'package:news_app/models/article.dart';

class ArticleCard extends StatelessWidget {
  final Article article;

  const ArticleCard({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: article.imageUrl.isNotEmpty
            ? Image.network(article.imageUrl, width: 50, height: 50)
            : const Icon(Icons.article, size: 50),
        title: Text(article.title),
        subtitle: Text(article.description),
        onTap: () {
          Navigator.pushNamed(context, '/article-detail', arguments: article);
        },
      ),
    );
  }
}

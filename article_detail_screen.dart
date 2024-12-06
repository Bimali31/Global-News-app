import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/article.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Article Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            article.imageUrl.isNotEmpty
                ? Image.network(article.imageUrl)
                : const SizedBox(height: 200, child: Center(child: Text('No Image Available'))),
            const SizedBox(height: 16),
            Text(
              article.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              article.description,
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // Open the article in a browser
                _openArticle(article.url, context);
              },
              child: const Text('Read Full Article'),
            ),
          ],
        ),
      ),
    );
  }

  void _openArticle(String url, BuildContext context) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open article')),
      );
    }
  }
}

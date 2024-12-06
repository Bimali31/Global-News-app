import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../widgets/article_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  void _performSearch(BuildContext context) {
    if (_query.isNotEmpty) {
      Provider.of<NewsProvider>(context, listen: false).fetchNews(_query.toLowerCase());
    }
  }

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search News'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                hintText: 'Enter keyword...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onSubmitted: (value) {
                setState(() {
                  _query = value;
                  _performSearch(context);
                });
              },
            ),
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

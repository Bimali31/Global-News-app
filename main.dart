import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Global News App',
      theme: ThemeData(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        primarySwatch: Colors.orange,
      ),
      initialRoute: '/splash', // Initial route is the splash screen
      routes: {
        '/splash': (context) => SplashScreen(),
        '/': (context) => HomeScreen(toggleTheme: () {
              setState(() {
                isDarkMode = !isDarkMode;
              });
            }),
        '/favorites': (context) => FavoritesScreen(favorites: [], removeFromFavorites: (article) {}),
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Global News App',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color.fromARGB(255, 241, 157, 1), backgroundColor: const Color.fromARGB(255, 0, 0, 0), // Changes the icon color to black
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
              child: const Icon(Icons.arrow_forward),
            ),
          ],
        ),
      ),
    );
  }
}

class Article {
  final String title;
  final String description;
  final String urlToImage;
  final String content;
  final String category;
  final String publishedAt;

  Article({
    required this.title,
    required this.description,
    required this.urlToImage,
    required this.content,
    required this.category,
    required this.publishedAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      urlToImage: json['urlToImage'] ?? 'https://via.placeholder.com/150',
      content: json['content'] ?? 'No Content Available',
      category: json['source']['name'] ?? 'General',
      publishedAt: json['publishedAt'] ?? '',
    );
  }
}

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  const HomeScreen({Key? key, required this.toggleTheme}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  List<Article> articles = [];
  List<Article> filteredArticles = [];
  List<Article> favorites = [];
  String selectedCategory = 'All';
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchNews(); // Fetch all news initially
  }

  Future<void> fetchNews() async {
    const apiKey = '6d0d4a5ab3834a41b3a19ba07e66e2ab';
    String categoryQuery = selectedCategory == 'All' ? '' : '&category=$selectedCategory';
    final url =
        'https://newsapi.org/v2/top-headlines?country=us&apiKey=$apiKey$categoryQuery';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          articles = (data['articles'] as List)
              .map((json) => Article.fromJson(json))
              .toList();

          filteredArticles = List.from(articles); // Show all news initially
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void toggleFavorite(Article article) {
    setState(() {
      if (favorites.contains(article)) {
        favorites.remove(article);
      } else {
        favorites.add(article);
      }
    });
  }

  void filterByCategory(String category) {
    setState(() {
      selectedCategory = category;
      fetchNews(); // Fetch all news with the new category
    });
  }

  void searchArticles(String query) {
    setState(() {
      filteredArticles = articles
          .where((article) =>
              article.title.toLowerCase().contains(query.toLowerCase()) ||
              article.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void shareArticle(Article article) {
    final text = '${article.title}\n${article.description}\nRead more at: ${article.urlToImage}';
    Share.share(text);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        // Filter articles based on the selected date
        filteredArticles = articles.where((article) {
          final articleDate = DateTime.parse(article.publishedAt);
          return articleDate.year == selectedDate.year &&
              articleDate.month == selectedDate.month &&
              articleDate.day == selectedDate.day;
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['All', 'General', 'Technology', 'Sports', 'Health', 'Business'];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Global News',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
              color: Colors.black,
            ),
            onPressed: widget.toggleTheme,
          ),
          IconButton(
            icon: const Icon(
              Icons.favorite,
              color: Colors.black,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FavoritesScreen(
                  favorites: favorites,
                  removeFromFavorites: (article) {
                    setState(() {
                      favorites.remove(article);
                    });
                  },
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((category) {
                final isSelected = selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? Colors.orangeAccent : Colors.grey[300],
                    ),
                    onPressed: () => filterByCategory(category),
                    child: Text(
                      category,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search articles...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: searchArticles,
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredArticles.isEmpty
                    ? const Center(child: Text('No news available for the selected date'))
                    : ListView.builder(
                        itemCount: filteredArticles.length,
                        itemBuilder: (context, index) {
                          final article = filteredArticles[index];
                          final isFavorite = favorites.contains(article);
                          return Card(
                            child: ListTile(
                              leading: Image.network(
                                article.urlToImage,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                              title: Text(article.title),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailScreen(article: article),
                                  ),
                                );
                              },
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isFavorite ? const Color.fromARGB(255, 106, 173, 250) : null,
                                    ),
                                    onPressed: () => toggleFavorite(article),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.share),
                                    onPressed: () => shareArticle(article),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
class DetailScreen extends StatelessWidget {
  final Article article;

  const DetailScreen({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(article.urlToImage),
            const SizedBox(height: 8.0),
            Text(
              article.title,
              style: const TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              article.publishedAt,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8.0),
            Text(
              article.content,
              style: const TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  final List<Article> favorites;
  final Function(Article) removeFromFavorites;

  const FavoritesScreen({Key? key, required this.favorites, required this.removeFromFavorites}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final article = favorites[index];
          return ListTile(
            title: Text(article.title),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(article: article),
                ),
              );
            },
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                removeFromFavorites(article);
                Navigator.pop(context); // Go back after removing
              },
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final TextEditingController _controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: categoryProvider.categories.length,
              itemBuilder: (context, index) {
                final category = categoryProvider.categories[index];
                return ListTile(
                  title: Text(category.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      categoryProvider.removeCategory(category.name);
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Add Category',
                hintText: 'Enter category name...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  categoryProvider.addCategory(value);
                  _controller.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

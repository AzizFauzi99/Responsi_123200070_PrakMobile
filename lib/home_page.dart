import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'meal_list_page.dart';
import 'base_network.dart';

class Category {
  final String id;
  final String name;
  final String image;

  Category({required this.id, required this.name, required this.image});
}

class CategoryList extends StatefulWidget {
  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  late Future<List<Category>> _categoryList;

  @override
  void initState() {
    super.initState();
    _categoryList = _fetchCategories();
  }

  Future<List<Category>> _fetchCategories() async {
    final response = await http.get(Uri.parse(base_net_category));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final categoryList = data['categories'] as List<dynamic>;

      return categoryList.map((category) {
        return Category(
          id: category['idCategory'],
          name: category['strCategory'],
          image: category['strCategoryThumb'],
        );
      }).toList();
    } else {
      throw Exception('Failed to fetch categories');
    }
  }

  void _navigateToCategoryMeals(String categoryName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryMealList(categoryName: categoryName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Categories'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Category>>(
        future: _categoryList,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final categories = snapshot.data!;
            return ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return ListTile(
                  onTap: () {
                    _navigateToCategoryMeals(category.name);
                  },
                  leading: Image.network(category.image),
                  title: Text(category.name),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

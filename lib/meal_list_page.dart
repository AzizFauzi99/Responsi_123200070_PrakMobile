import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'base_network.dart';
import 'home_page.dart';
import 'detail_meal_page.dart';

class Meal {
  final String id;
  final String name;
  final String thumbnail;

  Meal({required this.id, required this.name, required this.thumbnail});
}

class CategoryMealList extends StatefulWidget {
  final String categoryName;

  const CategoryMealList({required this.categoryName});

  @override
  _CategoryMealListState createState() => _CategoryMealListState();
}

class _CategoryMealListState extends State<CategoryMealList> {
  late Future<List<Meal>> _mealList;

  @override
  void initState() {
    super.initState();
    _mealList = _fetchMeals();
  }

  Future<List<Meal>> _fetchMeals() async {
    final response = await http.get(Uri.parse(
        '$base_net_meal${widget.categoryName}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final mealList = data['meals'] as List<dynamic>;

      return mealList.map((meal) {
        return Meal(
          id: meal['idMeal'],
          name: meal['strMeal'],
          thumbnail: meal['strMealThumb'],
        );
      }).toList();
    } else {
      throw Exception('Failed to fetch meals');
    }
  }

  void _navigateToDetailMeal(String id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailMealList(idMeal: id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(widget.categoryName),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Meal>>(
        future: _mealList,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final meal = snapshot.data![index];
                return ListTile(
                  onTap: () {
                    _navigateToDetailMeal(meal.id);
                  },
                  leading: Image.network(meal.thumbnail),
                  title: Text(meal.name),
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
     

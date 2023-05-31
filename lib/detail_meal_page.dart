import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'base_network.dart';

class Detail {
  final String id;
  final String name;
  final String category;
  final String area;
  final String instructions;
  final String thumbnail;
  final String youtube;

  Detail({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.instructions,
    required this.thumbnail,
    required this.youtube,
  });
}

class DetailMealList extends StatefulWidget {
  final String idMeal;
  const DetailMealList({required this.idMeal});
  @override
  State<DetailMealList> createState() => _DetailMealListState();
}

class _DetailMealListState extends State<DetailMealList> {
  late Future<List<Detail>> _detailMeal;

  @override
  void initState() {
    super.initState();
    _detailMeal = _fetchDetail();
  }

  Future<List<Detail>> _fetchDetail() async {
    final response =
        await http.get(Uri.parse('$base_net_detail${widget.idMeal}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final detailList = data['meals'] as List<dynamic>;

      return detailList.map((detail) {
        return Detail(
          id: detail['idMeal'],
          name: detail['strMeal'],
          category: detail['strCategory'],
          area: detail['strArea'],
          instructions: detail['strInstructions'],
          thumbnail: detail['strMealThumb'],
          youtube: detail['strYoutube'],
        );
      }).toList();
    } else {
      throw Exception('Failed to fetch meals');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Meal Detail"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Detail>>(
        future: _detailMeal,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Text(
                            snapshot.data![index].name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Image.network(
                            snapshot.data![index].thumbnail,
                            width: 200,
                            height: 400,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Category: " + snapshot.data![index].category,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Area: " + snapshot.data![index].area,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            snapshot.data![index].instructions,
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () async {
                              var url = snapshot.data![index].youtube;
                              if (await canLaunch(url)) {
                                await launch(url,
                                    forceWebView: true, enableJavaScript: true);
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                            child: Text("Buka Youtube"),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

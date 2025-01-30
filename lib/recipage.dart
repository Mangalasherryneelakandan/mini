import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecipeGridPage extends StatefulWidget {
  @override
  _RecipeGridPageState createState() => _RecipeGridPageState();
}

class _RecipeGridPageState extends State<RecipeGridPage> {
  List<dynamic> recipes = [];

  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }

  // Fetch data from the API
  Future<void> fetchRecipes() async {
    final response = await http.get(Uri.parse("http://127.0.0.1:8000/scrape/?url=https://example-recipe-site.com"));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        recipes = data['recipe'];  // Adjust based on your API response structure
      });
    } else {
      print("Failed to load data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Recipe Grid")),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 items per row (you can change this)
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.0, // Makes items square-shaped
        ),
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: InkWell(
              onTap: () {
                // Navigate to recipe details page (optional)
              },
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      recipes[index]['title'],  // Display title of the recipe
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Ingredients: ${recipes[index]['ingredients'].join(", ")}",  // Display ingredients
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'specirecipepage.dart'; // Import the detail page

class RecipeGridPage extends StatefulWidget {
  @override
  _RecipeListPageState createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeGridPage> {
  List recipes = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchRecipes("Chicken"); // Default ingredient
  }

  Future<void> fetchRecipes(String ingredient) async {
    setState(() {
      isLoading = true;
    });

    final url = "https://www.themealdb.com/api/json/v1/1/filter.php?i=$ingredient";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        recipes = data["meals"] ?? [];
        isLoading = false;
      });
    } else {
      setState(() {
        recipes = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recipes"),
        centerTitle: true,
        backgroundColor: Colors.orangeAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : recipes.isEmpty
          ? Center(child: Text("No recipes found"))
          : ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return Card(
            margin: EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  recipe["strMealThumb"],
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(recipe["strMeal"], style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                // Navigate to the RecipeDetailPage with mealId
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeDetailPage(mealId: recipe["idMeal"]),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

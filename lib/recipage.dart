import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecipeGridPage extends StatefulWidget {
  @override
  _RecipeGridPageState createState() => _RecipeGridPageState();
}

class _RecipeGridPageState extends State<RecipeGridPage> {
  List<dynamic> recipes = [];
  bool _isLoading = true; // Add a loading indicator

  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }

  // Fetch data from the API
  Future<void> fetchRecipes() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      final response = await http.get(
        Uri.parse("http://127.0.0.1:8000/scrape/?url=https://example-recipe-site.com"),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          recipes = data['recipe'];  // Adjust based on your API response structure
          _isLoading = false; // Stop loading
        });
      } else {
        print("Failed to load data: ${response.statusCode}"); // Log status code
        setState(() {
          _isLoading = false; // Stop loading even on error
        });
        // Show an error message to the user (see below)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load recipes. Status code: ${response.statusCode}')),
        );

      }
    } catch (e) {
      print("Error fetching recipes: $e"); // Log the error
      setState(() {
        _isLoading = false; // Stop loading even on error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching recipes: $e')),
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Recipe Grid")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : recipes.isEmpty
          ? Center(child: Text("No recipes found.")) // Show message if empty
          : GridView.builder(
        padding: EdgeInsets.all(10), // Add padding to the grid
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.8, // Adjust for ingredient text (important)
        ),
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          return RecipeCard(recipe: recipes[index]); // Use a separate widget
        },
      ),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final dynamic recipe;

  const RecipeCard({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to recipe details page (optional)
          // Example:
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => RecipeDetailsPage(recipe: recipe),
          //   ),
          // );
        },
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
            children: [
              Text(
                recipe['title'] ?? "No Title", // Handle null title
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), // Increase title size
                maxLines: 2, // Limit title lines
                overflow: TextOverflow.ellipsis, // Handle overflow
              ),
              SizedBox(height: 5),
              Expanded( // Use Expanded for the ingredients text
                child: SingleChildScrollView( // Make ingredients scrollable
                  child: Text(
                    "Ingredients: ${(recipe['ingredients'] as List?)?.join(", ") ?? "No Ingredients"}", // Handle null ingredients
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
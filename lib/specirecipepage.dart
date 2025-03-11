import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class RecipeDetailPage extends StatefulWidget {
  final String mealId;

  RecipeDetailPage({required this.mealId});

  @override
  _RecipeDetailPageState createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  Map<String, dynamic>? recipe;
  List<String> inventory = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInventory(); // Load inventory from local file
    fetchRecipeById(widget.mealId);
  }

  // 🔹 Load Inventory from Local File
  Future<void> _loadInventory() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/inventory.txt');

      if (await file.exists()) {
        List<String> lines = await file.readAsLines();
        setState(() {
          inventory = lines.map((e) => e.trim().toLowerCase()).toList();
        });
      }
    } catch (e) {
      print("Error loading inventory: $e");
    }
  }

  // 🔹 Fetch Recipe by ID
  Future<void> fetchRecipeById(String mealId) async {
    setState(() {
      isLoading = true;
    });

    final url = "https://www.themealdb.com/api/json/v1/1/lookup.php?i=$mealId";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        recipe = data["meals"]?[0];
        isLoading = false;
      });
    } else {
      setState(() {
        recipe = null;
        isLoading = false;
      });
    }
  }

  // 🔹 Open YouTube as a Website
  void _openURL(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recipe Details"),
        backgroundColor: Colors.black87,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : recipe == null
          ? Center(child: Text("Recipe not found", style: TextStyle(fontSize: 18)))
          : Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.network(
              recipe!["strMealThumb"],
              fit: BoxFit.cover,
            ),
          ),

          // Dark Overlay for Readability
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),

          // Content Section
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),

                // Title
                Center(
                  child: Text(
                    recipe!["strMeal"],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                SizedBox(height: 10),

                // Category & Cuisine
                Center(
                  child: Text(
                    "${recipe!["strCategory"]} | ${recipe!["strArea"]}",
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                ),

                SizedBox(height: 20),

                // Ingredients Section
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "📝 Ingredients:",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),

                      // Display Ingredients with Inventory Check
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: List.generate(20, (index) {
                          String ingredient = recipe!["strIngredient${index + 1}"] ?? "";
                          String measure = recipe!["strMeasure${index + 1}"] ?? "";

                          if (ingredient.isNotEmpty) {
                            bool isAvailable = inventory.contains(ingredient.toLowerCase());

                            return Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    "https://www.themealdb.com/images/ingredients/$ingredient.png",
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Icon(Icons.fastfood, size: 60),
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "$ingredient\n$measure",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isAvailable ? Colors.green : Colors.grey,
                                    fontWeight: isAvailable ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            );
                          }
                          return Container();
                        }),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Instructions Section
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "📖 Instructions:",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(recipe!["strInstructions"], style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // YouTube Video Button
                if (recipe!["strYoutube"] != null && recipe!["strYoutube"].isNotEmpty)
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _openURL(recipe!["strYoutube"]),
                      icon: Icon(Icons.play_circle_fill, color: Colors.white),
                      label: Text("Watch on YouTube", style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ),

                SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

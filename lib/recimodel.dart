import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  final String id;
  final String recipeName;
  final String course;
  final String cuisine;
  final String diet;
  final List<String> ingredients;
  final List<String> instructions;
  final int cookTimeInMins;
  final int prepTimeInMins;
  final int totalTimeInMins;
  final int servings;
  final String translatedRecipeName;
  final List<String> translatedIngredients;
  final List<String> translatedInstructions;
  final String url;
  final String imageURL; // ✅ New field for image URL

  Recipe({
    required this.id,
    required this.recipeName,
    required this.course,
    required this.cuisine,
    required this.diet,
    required this.ingredients,
    required this.instructions,
    required this.cookTimeInMins,
    required this.prepTimeInMins,
    required this.totalTimeInMins,
    required this.servings,
    required this.translatedRecipeName,
    required this.translatedIngredients,
    required this.translatedInstructions,
    required this.url,
    required this.imageURL, // ✅ Initialize imageURL
  });

  factory Recipe.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Recipe(
      id: doc.id,
      recipeName: data['RecipeName'] ?? '',
      course: data['Course'] ?? '',
      cuisine: data['Cuisine'] ?? '',
      diet: data['Diet'] ?? '',
      ingredients: List<String>.from(data['Ingredients'] ?? []),
      instructions: List<String>.from(data['Instructions'] ?? []),
      cookTimeInMins: data['CookTimeInMins'] ?? 0,
      prepTimeInMins: data['PrepTimeInMins'] ?? 0,
      totalTimeInMins: data['TotalTimeInMins'] ?? 0,
      servings: data['Servings'] ?? 0,
      translatedRecipeName: data['TranslatedRecipeName'] ?? '',
      translatedIngredients: List<String>.from(data['TranslatedIngredients'] ?? []),
      translatedInstructions: List<String>.from(data['TranslatedInstructions'] ?? []),
      url: data['URL'] ?? '',
      imageURL: data['image_URL'] ?? '', // ✅ Corrected to 'image_URL'
    );
  }
}

// Fetching recipes with a limit of 20
Stream<List<Recipe>> getRecipes() {
  return FirebaseFirestore.instance
      .collection('recipes')
      .limit(20) // ✅ Limit query to 20 recipes
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Recipe.fromFirestore(doc)).toList());
}

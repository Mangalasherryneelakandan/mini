import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery/recimodel.dart'; // Assuming this is where your Recipe model is
import 'package:grocery/shimmer.dart';
import 'package:grocery/specirecipepage.dart'; // Assuming this is for your shimmer effect

class RecipesPage extends StatefulWidget {
  @override
  _RecipesPageState createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  List<Recipe> recipes = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  String searchQuery = '';
  String selectedFilter = '';
  int recipeLimit = 20;
  DocumentSnapshot? lastDocument;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchRecipes();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      loadMoreRecipes();
    }
  }

  Future<void> fetchRecipes() async {
    try {
      setState(() {
        isLoading = true;
      });

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('recipes')
          .limit(recipeLimit)
          .get();

      List<Recipe> fetchedRecipes = [];
      try {
        fetchedRecipes = querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          try {
            return Recipe(
              id: doc.id,
              recipeName: data['RecipeName'] ?? '',
              translatedRecipeName: data['TranslatedRecipeName'] ?? '',
              ingredients: _parseList(data['Ingredients']),
              translatedIngredients: _parseList(data['TranslatedIngredients']),
              prepTimeInMins: _parseToInt(data['PrepTimeInMins']),
              cookTimeInMins: _parseToInt(data['CookTimeInMins']),
              totalTimeInMins: _parseToInt(data['TotalTimeInMins']),
              servings: _parseToInt(data['Servings']),
              cuisine: data['Cuisine'] ?? '',
              course: data['Course'] ?? '',
              diet: data['Diet'] ?? '',
              instructions: _parseList(data['Instructions']),
              translatedInstructions: _parseList(data['TranslatedInstructions']),
              url: data['URL'] ?? '',
              imageURL: data['Image_URL'] ?? '',
            );
          } catch (e) {
            print('Error creating Recipe object: $e');
            return Recipe(  // Return a default/placeholder Recipe instead of null
              id: '', // Provide a default ID or generate one
              recipeName: 'Error Recipe', // Indicate an error
              translatedRecipeName: '',
              ingredients: [],
              translatedIngredients: [],
              prepTimeInMins: 0,
              cookTimeInMins: 0,
              totalTimeInMins: 0,
              servings: 0,
              cuisine: '',
              course: '',
              diet: '',
              instructions: [],
              translatedInstructions: [],
              url: '',
              imageURL: '',
            );
          }
        }).toList();

      } catch (e) {
        print('Error mapping documents: $e');
      }

      if (querySnapshot.docs.isNotEmpty) {
        lastDocument = querySnapshot.docs.last;
      }

      setState(() {
        recipes = fetchedRecipes;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('General error fetching recipes: $e');
      _showErrorSnackBar('Error loading recipes. Please try again.');
    }
  }

  // Helper function to parse to integer safely
  int _parseToInt(dynamic value) {
    if (value == null) {
      return 0; // Default value if null
    }
    if (value is num) {
      return value.toInt(); // If already a number, convert to int
    }
    if (value is String) {
      try {
        return int.parse(value); // Try parsing as int
      } catch (e) {
        print('Error parsing to int: $e');
        return 0; // Default value if parsing fails
      }
    }
    print('Unexpected type for numeric value: ${value.runtimeType}');
    return 0; // Default value for unexpected types
  }

  Future<void> loadMoreRecipes() async {
    try {
      setState(() {
        isLoadingMore = true;
      });

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('recipes')
          .startAfterDocument(lastDocument!)
          .limit(recipeLimit)
          .get();

      List<Recipe> moreRecipes = [];
      try {
        moreRecipes = querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          try {
            return Recipe(
              id: doc.id,
              recipeName: data['RecipeName'] ?? '',
              translatedRecipeName: data['TranslatedRecipeName'] ?? '',
              ingredients: _parseList(data['Ingredients']),
              translatedIngredients: _parseList(data['TranslatedIngredients']),
              prepTimeInMins: data['PrepTimeInMins'] != null ? (data['PrepTimeInMins'] as num).toInt() : 0,
              cookTimeInMins: data['CookTimeInMins'] != null ? (data['CookTimeInMins'] as num).toInt() : 0,
              totalTimeInMins: data['TotalTimeInMins'] != null ? (data['TotalTimeInMins'] as num).toInt() : 0,
              servings: data['Servings'] != null ? (data['Servings'] as num).toInt() : 0,
              cuisine: data['Cuisine'] ?? '',
              course: data['Course'] ?? '',
              diet: data['Diet'] ?? '',
              instructions: _parseList(data['Instructions']),
              translatedInstructions: _parseList(data['TranslatedInstructions']),
              url: data['URL'] ?? '',
              imageURL: data['Image_URL'] ?? '',
            );
          } catch (e) {
            print('Error creating Recipe object: $e');
            return Recipe(  // Return a default/placeholder Recipe instead of null
              id: '', // Provide a default ID or generate one
              recipeName: 'Error Recipe', // Indicate an error
              translatedRecipeName: '',
              ingredients: [],
              translatedIngredients: [],
              prepTimeInMins: 0,
              cookTimeInMins: 0,
              totalTimeInMins: 0,
              servings: 0,
              cuisine: '',
              course: '',
              diet: '',
              instructions: [],
              translatedInstructions: [],
              url: '',
              imageURL: '',
            );
          }
        }).toList();
      } catch (e) {
        print('Error mapping documents: $e');
      }

      if (querySnapshot.docs.isNotEmpty) {
        lastDocument = querySnapshot.docs.last;
      }

      setState(() {
        recipes.addAll(moreRecipes);
        isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        isLoadingMore = false;
      });
      print('General error loading more recipes: $e');
      _showErrorSnackBar('Failed to load more recipes.');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent.withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 3),
      ),
    );
  }

  List<String> _parseList(dynamic field) {
    if (field == null) {
      return [];
    }
    if (field is String) {
      return field.split(',').map((item) => item.trim()).toList();
    }
    return [];
  }

  List<Recipe> getFilteredRecipes() {
    return recipes.where((recipe) {
      final matchesSearch = recipe.recipeName
          .toLowerCase()
          .contains(searchQuery.toLowerCase());

      final matchesFilter = selectedFilter.isEmpty ||
          recipe.course == selectedFilter ||
          recipe.cuisine == selectedFilter ||
          recipe.diet == selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecipes = getFilteredRecipes();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Color(0xFFF8F8F8),
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        title: Text(
          'Explore Recipes',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list_rounded, color: Color(0xFF777777)),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
        iconTheme: IconThemeData(color: Color(0xFF333333)),
      ),
      body: isLoading
          ? ShimmerEffect()
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for delicious recipes...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: theme.primaryColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          if (selectedFilter.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8.0,
                children: [
                  Chip(
                    label: Text(selectedFilter),
                    backgroundColor:
                    theme.colorScheme.primary.withOpacity(0.15),
                    labelStyle: TextStyle(color: theme.colorScheme.primary),
                    deleteIconColor: theme.colorScheme.primary,
                    onDeleted: () {
                      setState(() {
                        selectedFilter = '';
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: filteredRecipes.isEmpty
                ? Center(
              child: Text(
                'No recipes found for your search.',
                style: TextStyle(color: Colors.grey[600]),
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              itemCount:
              filteredRecipes.length + (isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == filteredRecipes.length) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary),
                      ),
                    ),
                  );
                }

                final recipe = filteredRecipes[index];
                return _buildRecipeCard(recipe, context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe, BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetail(recipe: recipe),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            recipe.imageURL.isNotEmpty
                ? ClipRRect(
              borderRadius:
              BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(
                recipe.imageURL,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  return const SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: Center(
                      child: Icon(Icons.image_not_supported),
                    ),
                  );
                },
              ),
            )
                : const SizedBox(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.recipeName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF333333),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      _buildInfoChip(
                          context, Icons.restaurant_rounded, recipe.cuisine),
                      SizedBox(width: 8),
                      _buildInfoChip(context, Icons.timer_rounded,
                          '${recipe.totalTimeInMins} min'),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        recipe.diet.isNotEmpty ? recipe.diet : recipe.course,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Recipes by',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              SizedBox(height: 24),
              _buildFilterOption(context, 'All Recipes', ''),
              _buildFilterOption(context, 'Course', 'Course'),
              _buildFilterOption(context, 'Cuisine', 'Cuisine'),
              _buildFilterOption(context, 'Diet', 'Diet'),
              SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(BuildContext context, String title, String filter) {
    final theme = Theme.of(context);
    final isSelected = selectedFilter == filter;

    return InkWell(
      onTap: () {
        setState(() {
          selectedFilter = filter;
        });
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? theme.colorScheme.primary
                    : Color(0xFF444444),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: theme.colorScheme.primary,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
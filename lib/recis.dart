import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery/recimodel.dart';
import 'package:grocery/recipage.dart';
import 'package:grocery/shimmer.dart';
import 'package:grocery/specirecipepage.dart';

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
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
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

      List<Recipe> fetchedRecipes = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Recipe(
          id: doc.id,
          recipeName: data['RecipeName'] ?? '',
          course: data['Course'] ?? '',
          cuisine: data['Cuisine'] ?? '',
          diet: data['Diet'] ?? '',
          ingredients: _parseList(data['Ingredients']),
          instructions: _parseList(data['Instructions']),
          cookTimeInMins: data['CookTimeInMins'] ?? 0,
          prepTimeInMins: data['PrepTimeInMins'] ?? 0,
          totalTimeInMins: data['TotalTimeInMins'] ?? 0,
          servings: data['Servings'] ?? 0,
          translatedRecipeName: data['TranslatedRecipeName'] ?? '',
          translatedIngredients: _parseList(data['TranslatedIngredients']),
          translatedInstructions: _parseList(data['TranslatedInstructions']),
          url: data['URL'] ?? '',
        );
      }).toList();

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
      _showErrorSnackBar('Error loading recipes. Please try again.');
    }
  }

  Future<void> loadMoreRecipes() async {
    if (isLoadingMore || lastDocument == null) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('recipes')
          .startAfterDocument(lastDocument!)
          .limit(recipeLimit)
          .get();

      List<Recipe> moreRecipes = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Recipe(
          id: doc.id,
          recipeName: data['RecipeName'] ?? '',
          course: data['Course'] ?? '',
          cuisine: data['Cuisine'] ?? '',
          diet: data['Diet'] ?? '',
          ingredients: _parseList(data['Ingredients']),
          instructions: _parseList(data['Instructions']),
          cookTimeInMins: data['CookTimeInMins'] ?? 0,
          prepTimeInMins: data['PrepTimeInMins'] ?? 0,
          totalTimeInMins: data['TotalTimeInMins'] ?? 0,
          servings: data['Servings'] ?? 0,
          translatedRecipeName: data['TranslatedRecipeName'] ?? '',
          translatedIngredients: _parseList(data['TranslatedIngredients']),
          translatedInstructions: _parseList(data['TranslatedInstructions']),
          url: data['URL'] ?? '',
        );
      }).toList();

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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Recipes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.tune, color: Colors.black54),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: isLoading
          ? ShimmerEffect()
          : Column(
        children: [
          // Search bar with minimalist design
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),

          // Filter chips
          if (selectedFilter.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Chip(
                    label: Text(selectedFilter),
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    labelStyle: TextStyle(color: theme.colorScheme.primary),
                    deleteIconColor: theme.colorScheme.primary,
                    onDeleted: () {
                      setState(() {
                        selectedFilter = '';
                      });
                    },
                  ),
                ],
              ),
            ),

          // Recipe list
          Expanded(
            child: filteredRecipes.isEmpty
                ? Center(
              child: Text(
                'No recipes found',
                style: TextStyle(color: Colors.grey[600]),
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              itemCount: filteredRecipes.length + (isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == filteredRecipes.length) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
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
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetail(recipe: recipe),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recipe.recipeName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  _buildInfoChip(context, Icons.restaurant, recipe.cuisine),
                  SizedBox(width: 8),
                  _buildInfoChip(context, Icons.timer, '${recipe.totalTimeInMins} min'),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    recipe.diet.isNotEmpty ? recipe.diet : recipe.course,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter by',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 20),
              _buildFilterOption(context, 'All Recipes', ''),
              _buildFilterOption(context, 'Course', 'Course'),
              _buildFilterOption(context, 'Cuisine', 'Cuisine'),
              _buildFilterOption(context, 'Diet', 'Diet'),
              SizedBox(height: 16),
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
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? theme.colorScheme.primary : Colors.black87,
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                color: theme.colorScheme.primary,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'recimodel.dart'; // Ensure this path is correct

class RecipeDetail extends StatefulWidget {
  final Recipe recipe;

  RecipeDetail({required this.recipe});

  @override
  _RecipeDetailState createState() => _RecipeDetailState();
}

class _RecipeDetailState extends State<RecipeDetail> {
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Could not open $url'),
      )); // more user-friendly feedback
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA), // Light background
      body: CustomScrollView( // Use CustomScrollView for flexible layout
        slivers: [
          SliverAppBar(
            expandedHeight: 250, // increased for better visual appeal
            pinned: true, // Appbar stays visible while scrolling
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.recipe.translatedRecipeName.isNotEmpty
                    ? widget.recipe.translatedRecipeName
                    : widget.recipe.recipeName,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white, // White Title for contrast
                  fontSize: 20,
                ),
              ),
              background: widget.recipe.imageURL.isNotEmpty
                  ? Image.network(
                widget.recipe.imageURL,
                fit: BoxFit.cover,
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(Icons.image_not_supported,
                          color: Colors.grey[600]),
                    ),
                  );
                },
              )
                  : Container(
                color: Colors.grey[300],
                child: Center(
                  child: Icon(Icons.no_photography, color: Colors.grey[600]),
                ),
              ), // Placeholder if no image
            ),
            iconTheme: IconThemeData(color: Colors.white), // White back arrow
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildMetadataSection(),
                const Divider(height: 40, thickness: 1),
                _buildSectionTitle('Ingredients'),
                const SizedBox(height: 16),
                ..._buildIngredientsList(),
                const Divider(height: 40, thickness: 1),
                _buildSectionTitle('Instructions'),
                const SizedBox(height: 16),
                ..._buildInstructionsList(),
                const SizedBox(height: 32),
                if (widget.recipe.url.isNotEmpty)
                  Center(
                    child: ElevatedButton( // Using ElevatedButton for better styling
                      onPressed: () => _launchURL(widget.recipe.url),
                      child: Text(
                        'View Original Recipe',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white, // White text on button
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor, // Use theme's primary color
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataSection() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
        _buildMetadataChip(widget.recipe.course),
        _buildMetadataChip(widget.recipe.cuisine),
        _buildMetadataChip(widget.recipe.diet),
        _buildMetadataChip("${widget.recipe.servings} servings"),
      ],
    );
  }

  Widget _buildMetadataChip(String label) {
    return Chip( // Using Chip widget for more modern look
      label: Text(
        label,
        style: TextStyle(
          fontSize: 14, // Slightly larger
          color: Colors.grey[800], // Darker text
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: Colors.grey[200], // Lighter background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), // more padding
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 16, // larger
        fontWeight: FontWeight.w700, // bolder
        letterSpacing: 1.2,
        color: Color(0xFF333333), // Darker text
      ),
    );
  }

  List<Widget> _buildIngredientsList() {
    final items = widget.recipe.translatedIngredients.isNotEmpty
        ? widget.recipe.translatedIngredients
        : widget.recipe.ingredients;

    return items
        .map((item) => _buildListItem(item))
        .toList();
  }

  List<Widget> _buildInstructionsList() {
    final items = widget.recipe.translatedInstructions.isNotEmpty
        ? widget.recipe.translatedInstructions
        : widget.recipe.instructions;

    return items.asMap().entries.map((entry) {
      int idx = entry.key;
      String instruction = entry.value;
      return _buildNumberedListItem(idx + 1, instruction);
    }).toList();
  }

  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0), // More spacing
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, // Changed to a better icon
              size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16, // Larger font
                height: 1.6, // Improved line height
                color: Color(0xFF444444), // Darker text
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberedListItem(int number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number.toString() + ".", // Added period
            style: TextStyle(
              fontSize: 16, // Larger font
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16, // Larger font
                height: 1.6,
                color: Color(0xFF444444), // Darker text
              ),
            ),
          ),
        ],
      ),
    );
  }
}
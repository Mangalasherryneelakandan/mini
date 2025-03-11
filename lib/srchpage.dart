import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'gropage.dart';  // Import ProductListPage

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;

  // URL of the backend Flask server (update this if needed)
  final String apiUrl = 'http://127.0.0.1:5000/scrape';

  // Function to search products by calling the backend
  Future<void> searchProducts(BuildContext context) async {
    String query = searchController.text.trim();

    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a search term")),
      );
      return;
    }

    // Start loading
    setState(() {
      isLoading = true;
    });

    // Construct the URL for the search query
    String url = '$apiUrl?query=$query';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Parse the JSON response
        Map<String, dynamic> data = json.decode(response.body);

        // If products are returned, navigate to the ProductListPage
        if (data.containsKey('products')) {
          setState(() {
            isLoading = false;
          });
          // Show the 'Go to Product List' button after successful search
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Search Successful'),
                content: Text('Found products!'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProductListPage()),
                      );
                    },
                    child: Text('Go to Product List'),
                  ),
                ],
              );
            },
          );
        } else {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("No products found")),
          );
        }
      } else {
        // Handle unsuccessful API response
        setState(() {
          isLoading = false;
        });
        throw Exception('Failed to load products');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching products. Check backend.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Search Products")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Search input field and button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Enter search term',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => searchProducts(context),
                  child: Text('Search'),
                ),
              ],
            ),
            // Loading indicator
            if (isLoading)
              CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

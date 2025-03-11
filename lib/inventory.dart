import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ManageInventoryPage extends StatefulWidget {
  @override
  _ManageInventoryPageState createState() => _ManageInventoryPageState();
}

class _ManageInventoryPageState extends State<ManageInventoryPage> {
  List<String> inventory = [];
  TextEditingController ingredientController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  // 🔹 Get the file location
  Future<File> _getInventoryFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('backend/inventory.txt');
  }

  // 🔹 Load inventory from file
  Future<void> _loadInventory() async {
    try {
      final file = await _getInventoryFile();
      if (await file.exists()) {
        List<String> lines = await file.readAsLines();
        setState(() {
          inventory = lines;
        });
      }
    } catch (e) {
      print("Error loading inventory: $e");
    }
  }

  // 🔹 Save inventory to file
  Future<void> _saveInventory() async {
    final file = await _getInventoryFile();
    await file.writeAsString(inventory.join("\n"));
  }

  // 🔹 Add an ingredient
  void _addIngredient() {
    String ingredient = ingredientController.text.trim();
    if (ingredient.isNotEmpty && !inventory.contains(ingredient)) {
      setState(() {
        inventory.add(ingredient);
      });
      _saveInventory();
    }
    ingredientController.clear();
  }

  // 🔹 Remove an ingredient
  void _removeIngredient(String ingredient) {
    setState(() {
      inventory.remove(ingredient);
    });
    _saveInventory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Ingredients"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔹 Input field to add an ingredient
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: ingredientController,
                    decoration: InputDecoration(
                      labelText: "Enter ingredient",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addIngredient,
                  child: Text("Add"),
                ),
              ],
            ),
            SizedBox(height: 20),

            // 🔹 Display the list of saved ingredients
            Expanded(
              child: inventory.isEmpty
                  ? Center(child: Text("No ingredients added"))
                  : ListView.builder(
                itemCount: inventory.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(inventory[index]),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeIngredient(inventory[index]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

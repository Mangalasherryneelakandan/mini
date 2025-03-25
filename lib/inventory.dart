import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // 🔹 Load inventory from shared preferences
  Future<void> _loadInventory() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? savedInventory = prefs.getStringList('inventory');
      if (savedInventory != null) {
        setState(() {
          inventory = savedInventory;
        });
      }
    } catch (e) {
      print("Error loading inventory: $e");
    }
  }

  // 🔹 Save inventory to shared preferences
  Future<void> _saveInventory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('inventory', inventory);
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
        title: const Text("Manage Ingredients"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔹 Input field to add an ingredient
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: ingredientController,
                    decoration: const InputDecoration(
                      labelText: "Enter ingredient",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addIngredient,
                  child: const Text("Add"),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 🔹 Display the list of saved ingredients
            Expanded(
              child: inventory.isEmpty
                  ? const Center(child: Text("No ingredients added"))
                  : ListView.builder(
                itemCount: inventory.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(inventory[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
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

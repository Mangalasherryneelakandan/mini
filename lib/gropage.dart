import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductListPage extends StatefulWidget {
  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<dynamic> _products = [];
  List<dynamic> _cart = [];
  List<dynamic> _inventory = []; // Inventory list
  final double usdToInrRate = 83.0; // Static conversion rate

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final response = await http.get(Uri.parse('https://dummyjson.com/products/category/groceries'));
    if (response.statusCode == 200) {
      setState(() {
        _products = jsonDecode(response.body)['products'];
      });
    } else {
      throw Exception('Failed to load products');
    }
  }

  void addToCart(dynamic product) {
    setState(() {
      _cart.add(product);
    });
  }

  void removeFromCart(dynamic product) {
    setState(() {
      _cart.remove(product);
    });
  }

  void checkout() {
    if (_cart.isEmpty) return;
    setState(() {
      _inventory.addAll(_cart); // Move items to inventory
      _cart.clear(); // Empty the cart
    });
    Navigator.pop(context); // Close the cart modal
    showInventory(); // Show the updated inventory
  }

  void showCart() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Cart', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Divider(),
              _cart.isEmpty
                  ? Text('Cart is empty')
                  : Expanded(
                child: ListView(
                  children: _cart.map((item) {
                    return ListTile(
                      leading: Image.network(item['thumbnail'], width: 50),
                      title: Text(item['title']),
                      subtitle: Text(
                        '₹${(item['price'] * usdToInrRate).toStringAsFixed(2)}',
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => removeFromCart(item),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: checkout,
                child: Text('Checkout'),
              ),
            ],
          ),
        );
      },
    );
  }

  void showInventory() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Inventory', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Divider(),
              _inventory.isEmpty
                  ? Text('Inventory is empty')
                  : Expanded(
                child: ListView(
                  children: _inventory.map((item) {
                    return ListTile(
                      leading: Image.network(item['thumbnail'], width: 50),
                      title: Text(item['title']),
                      subtitle: Text(
                        '₹${(item['price'] * usdToInrRate).toStringAsFixed(2)}',
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grocery Store'),
        actions: [
          IconButton(
            icon: Icon(Icons.inventory),
            onPressed: showInventory, // Show Inventory
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: showCart, // Show Cart
          ),
        ],
      ),
      body: _products.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.75,
          ),
          itemCount: _products.length,
          itemBuilder: (context, index) {
            final product = _products[index];
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Image.network(
                      product['thumbnail'],
                      fit: BoxFit.contain,
                      width: double.infinity,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      product['title'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      '₹${(product['price'] * usdToInrRate).toStringAsFixed(2)}', // Converted to INR
                      style: TextStyle(color: Colors.green, fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => addToCart(product),
                    child: Text('Add to Cart'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

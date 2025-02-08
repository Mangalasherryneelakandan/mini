import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductListPage extends StatefulWidget {
  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<dynamic> products = [];

  Future<void> fetchProducts() async {
    final response = await http.get(Uri.parse("http://127.0.0.1:5000/fetch_products"));

    if (response.statusCode == 200) {
      setState(() {
        products = jsonDecode(response.body);
      });
    } else {
      throw Exception("Failed to load products");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Blinkit Products")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: fetchProducts,
            child: Text("Fetch Products"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    leading: Image.network(product["image"], width: 50, height: 50, fit: BoxFit.cover),
                    title: Text(product["name"]),
                    subtitle: Text(product["price"]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:csv/csv.dart';

class ProductListPage extends StatefulWidget {
  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<List<dynamic>> products = [];

  Future<void> loadCSV() async {
    final rawData = await rootBundle.loadString("backend/blinkit_products.csv");
    List<List<dynamic>> csvData = const CsvToListConverter().convert(rawData);

    setState(() {
      products = csvData.sublist(1); // Skip the header row
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Blinkit Products")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: loadCSV,
            child: Text("Load Products"),
          ),
          Expanded(
            child: products.isEmpty
                ? Center(child: Text("No products loaded"))
                : GridView.builder(
              padding: EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.8,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Image.network(
                          product[2], // Assuming 3rd column has image URLs
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Text(
                              product[0], // Assuming 1st column has product name
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            Text("Price: ${product[1]}", style: TextStyle(color: Colors.green)),
                          ],
                        ),
                      ),
                    ],
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

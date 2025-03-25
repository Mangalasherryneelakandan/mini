import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final DateTime expiryDate; // expiryDate is DateTime
  final String? imageURL;
  int quantity;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.expiryDate,
    this.imageURL,
    this.quantity = 1,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    DateTime parsedExpiryDate;

    try {
      if (data['expiryDate'] is String) {
        try {
          parsedExpiryDate = DateFormat('yyyy-MM-dd').parse(data['expiryDate']);
        } catch (e) {
          try {
            parsedExpiryDate = DateFormat('MM/dd/yyyy').parse(data['expiryDate']);
          } catch (e) {
            print(
                "Error parsing expiry date: ${data['expiryDate']}. Using default.");
            parsedExpiryDate = DateTime.now();
          }
        }
      } else if (data['expiryDate'] is Timestamp) {
        parsedExpiryDate = (data['expiryDate'] as Timestamp).toDate();
      } else {
        print("Unexpected type for expiry date: ${data['expiryDate'].runtimeType}. Using default.");
        parsedExpiryDate = DateTime.now();
      }
    } catch (e) {
      print("General error parsing expiry date: $e. Using default.");
      parsedExpiryDate = DateTime.now();
    }

    return Product(
      id: doc.id,
      name: data['name'] ?? 'Product Name',
      price: double.tryParse(data['price'].toString()) ?? 0.0,
      expiryDate: parsedExpiryDate,
      imageURL: data['imageURL'],
      quantity: data['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'expiryDate': DateFormat('yyyy-MM-dd').format(expiryDate),
      'imageURL': imageURL,
      'quantity': quantity,
    };
  }
}
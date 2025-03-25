import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery/prodcut.dart';
import 'package:intl/intl.dart';
import 'recimodel.dart'; // Ensure the path to your Recipe model is correct

class CartPage extends StatefulWidget {
  final String userId;
  const CartPage({Key? key, required this.userId}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Fetch cart items from Firestore
  Stream<List<Product>> fetchCartItems() {
    try {
      return FirebaseFirestore.instance
          .collection('carts')
          .doc(widget.userId)
          .collection('items')
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Product(
          id: doc.id,
          name: data['name'] ?? 'Product Name',
          price: double.tryParse(data['price'].toString()) ?? 0.0,
          expiryDate: data['expiryDate'] ?? 'No Expiry',
          imageURL: data['imageURL'],
          quantity: data['quantity'] ?? 1,
        );
      })
          .toList());
    } catch (e) {
      print('Error fetching cart items: $e');
      return Stream.value([]); // Return an empty stream on error
    }
  }

  // The function to add to pantry with the user ID
  Future<void> addToPantry(Product product) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      CollectionReference pantryRef = firestore
          .collection('pantries')
          .doc(widget.userId)
          .collection('items');

      // Create a map to hold the data we want to add to Firestore
      Map<String, dynamic> pantryData = {
        'name': product.name,
        'price': product.price,
        'expiryDate': DateFormat('yyyy-MM-dd').format(product.expiryDate),
        'imageURL': product.imageURL,
        'quantity': product.quantity,
      };
      await pantryRef.add(pantryData);

      // Optional: Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product.name} added to your pantry!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add ${product.name} to pantry.')));
    }
  }

  // Function to clear the cart
  Future<void> clearCart() async {
    try {
      final cartCollection = FirebaseFirestore.instance
          .collection('carts')
          .doc(widget.userId)
          .collection('items');

      // Get all documents in the cart
      final cartItems = await cartCollection.get();

      // Delete each document
      for (var doc in cartItems.docs) {
        await cartCollection.doc(doc.id).delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cart cleared successfully!')),
      );
      setState(() {}); // Refresh UI
    } catch (e) {
      print('Error clearing cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error clearing cart!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: theme.primaryColor,
        elevation: 0,
      ),
      body: StreamBuilder<List<Product>>(
        stream: fetchCartItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Your cart is empty',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                            context); // Navigate back to shopping page
                      },
                      child: Text('Continue Shopping'),
                    ),
                  ],
                ));
          }

          // Cart Items
          final cartItems = snapshot.data!;
          double totalPrice = 0;
          for (var item in cartItems) {
            totalPrice += (item.price * item.quantity);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final product = cartItems[index];
                    return _buildCartItem(product, theme);
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, -3), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total:',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                        Text('₹${totalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                                fontSize: 18,
                                color: theme.primaryColor,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Implement Checkout logic here
                        clearCart();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        textStyle: TextStyle(fontSize: 16),
                      ),
                      child: Center(child: Text('Clear Cart')),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(Product product, ThemeData theme) {
    final expiryDateFormatted = DateFormat('MMM dd, yyyy')
        .format(product.expiryDate);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[200],
              ),
              child: product.imageURL != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  product.imageURL!,
                  fit: BoxFit.cover,
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
                    return Center(child: Icon(Icons.image_not_supported));
                  },
                ),
              )
                  : Center(child: Icon(Icons.image_not_supported)),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '₹${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 15,
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Expiry: $expiryDateFormatted', // Use the formatted date string
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.red[600],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                // Quantity management for each item
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove, color: Colors.red),
                      onPressed: () {
                        decreaseQuantity(product);
                      },
                    ),
                    Text('${product.quantity}'), // Show quantity
                    IconButton(
                      icon: Icon(Icons.add, color: theme.primaryColor),
                      onPressed: () {
                        increaseQuantity(product);
                      },
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.add_home, color: theme.primaryColor), // Home Icon
                  onPressed: () {
                    addToPantry(product);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    removeFromCart(product);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // The function to add to pantry with the user ID


  // Method that increase the quantity
  Future<void> increaseQuantity(Product product) async {
    try {
      final cartCollection = FirebaseFirestore.instance
          .collection('carts')
          .doc(widget.userId)
          .collection('items');

      await cartCollection.doc(product.id).update({'quantity': FieldValue.increment(1)});
      setState(() {}); // Refresh UI to update cart badge
    } catch (e) {
      print('Error increasing quantity: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error increasing ${product.name} quantity !')
          )
      );
    }
  }

  //Method that decrease the quantity.
  Future<void> decreaseQuantity(Product product) async {
    try {
      final cartCollection = FirebaseFirestore.instance
          .collection('carts')
          .doc(widget.userId)
          .collection('items');

      if (product.quantity > 1) {
        await cartCollection.doc(product.id).update({'quantity': FieldValue.increment(-1)});
        setState(() {}); // Refresh UI to update cart badge
      } else {
        removeFromCart(product);
      }
    } catch (e) {
      print('Error decreasing quantity: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error decreasing ${product.name} quantity!'))
      );
    }
  }

  // Remove product from cart in Firestore
  Future<void> removeFromCart(Product product) async {
    try {
      final cartCollection = FirebaseFirestore.instance
          .collection('carts')
          .doc(widget.userId)
          .collection('items');

      // Delete product from cart in Firestore
      await cartCollection.doc(product.id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} removed from cart!')),
      );
      setState(() {}); // Refresh UI to update cart badge
    } catch (e) {
      print('Error removing from cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing ${product.name} from cart!')),
      );
    }
  }
}
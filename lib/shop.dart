import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery/cart.dart';
import 'package:grocery/prodcut.dart';
import 'package:intl/intl.dart';

// Shopping Page
class ShoppingPage extends StatefulWidget {
  final String userId;

  const ShoppingPage({Key? key, required this.userId}) : super(key: key);

  @override
  _ShoppingPageState createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  // Fetching products from Firestore
  Future<List<Product>> fetchProducts() async {
    final querySnapshot =
    await FirebaseFirestore.instance.collection('shop').get();
    return querySnapshot.docs
        .map((doc) => Product.fromFirestore(doc))
        .toList();
  }

  // Add product to cart in Firestore
  Future<void> addToCart(Product product) async {
    try {
      final cartCollection = FirebaseFirestore.instance
          .collection('carts')
          .doc(widget.userId)
          .collection('items');

      final existingProduct = await cartCollection.doc(product.id).get();

      if (!existingProduct.exists) {
        final productWithQuantity = product.toMap();
        productWithQuantity['quantity'] = 1;
        await cartCollection.doc(product.id).set(productWithQuantity);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product.name} added to cart!')),
        );
      } else {
        await cartCollection
            .doc(product.id)
            .update({'quantity': FieldValue.increment(1)});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product.name} quantity updated!')),
        );
      }
      setState(() {}); // Refresh UI to update the cart badge
    } catch (e) {
      print('Error adding to cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding ${product.name} to cart!')),
      );
    }
  }

  // Clear the cart
  Future<void> clearCart() async {
    try {
      final cartCollection = FirebaseFirestore.instance
          .collection('carts')
          .doc(widget.userId)
          .collection('items');

      final cartItems = await cartCollection.get();
      for (var doc in cartItems.docs) {
        await cartCollection.doc(doc.id).delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cart cleared successfully!')),
      );
      setState(() {});
    } catch (e) {
      print('Error clearing cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error clearing cart!')),
      );
    }
  }

  // Navigate to CartPage
  void goToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(userId: widget.userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Grocery Shopping',
            style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: theme.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, size: 28),
            onPressed: goToCart,
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products available'));
          }

          final products = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.70,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                theme: theme,
                userId: widget.userId,
              );
            },
          );
        },
      ),
    );
  }
}

// Product Card
class ProductCard extends StatefulWidget {
  final Product product;
  final ThemeData theme;
  final String userId;

  const ProductCard({
    Key? key,
    required this.product,
    required this.theme,
    required this.userId,
  }) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isInCart = false;
  int _quantityInCart = 0;

  @override
  void initState() {
    super.initState();
    _checkIfInCart();
  }

  Future<void> _checkIfInCart() async {
    try {
      final cartCollection = FirebaseFirestore.instance
          .collection('carts')
          .doc(widget.userId)
          .collection('items');

      final docSnapshot = await cartCollection.doc(widget.product.id).get();

      if (docSnapshot.exists) {
        setState(() {
          _isInCart = true;
          _quantityInCart =
              int.tryParse(docSnapshot.data()?['quantity']?.toString() ?? '0') ??
                  0;
        });
      } else {
        setState(() {
          _isInCart = false;
          _quantityInCart = 0;
        });
      }
    } catch (e) {
      print('Error checking cart: $e');
      setState(() {
        _isInCart = false;
        _quantityInCart = 0;
      });
    }
  }

  Future<void> _addToCart(Product product) async {
    try {
      final cartCollection = FirebaseFirestore.instance
          .collection('carts')
          .doc(widget.userId)
          .collection('items');

      final docSnapshot = await cartCollection.doc(product.id).get();

      if (!docSnapshot.exists) {
        final productWithQuantity = product.toMap();
        productWithQuantity['quantity'] = 1;
        await cartCollection.doc(product.id).set(productWithQuantity);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product.name} added to cart!')),
        );

        setState(() {
          _isInCart = true;
          _quantityInCart = 1;
        });
      } else {
        await cartCollection
            .doc(product.id)
            .update({'quantity': FieldValue.increment(1)});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product.name} quantity updated!')),
        );

        setState(() {
          _isInCart = true;
          _quantityInCart++;
        });
      }
    } catch (e) {
      print('Error adding to cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding ${product.name} to cart!')),
      );
    }
  }

  Future<void> _removeFromCart(Product product) async {
    try {
      final cartCollection = FirebaseFirestore.instance
          .collection('carts')
          .doc(widget.userId)
          .collection('items');

      await cartCollection.doc(product.id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} removed from cart!')),
      );
      setState(() {
        _isInCart = false;
        _quantityInCart = 0;
      });
    } catch (e) {
      print('Error removing from cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing ${product.name} from cart!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final expiryDateFormatted =
    DateFormat('MMM dd, yyyy').format(widget.product.expiryDate);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Image.network(
                  widget.product.imageURL,
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.product.name,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '₹${widget.product.price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 14, color: Colors.green),
            ),
            Text(
              'Expiry: $expiryDateFormatted',
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
            const SizedBox(height: 8),
            _isInCart
                ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('In Cart: $_quantityInCart',
                    style: const TextStyle(fontSize: 12)),
                IconButton(
                  icon: const Icon(Icons.remove_shopping_cart),
                  onPressed: () => _removeFromCart(widget.product),
                ),
              ],
            )
                : ElevatedButton(
              onPressed: () => _addToCart(widget.product),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.theme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartProvider with ChangeNotifier {
  List<String> _cartItems = [];

  List<String> get cartItems => _cartItems;

  // Fetch the cart items from Firestore for the logged-in user
  Future<void> fetchCartItems(String userId) async {
    final cartSnapshot = await FirebaseFirestore.instance
        .collection('cart')
        .where('userId', isEqualTo: userId)
        .get();

    if (cartSnapshot.docs.isNotEmpty) {
      final cartData = cartSnapshot.docs.first.data();
      _cartItems = List<String>.from(cartData['items'] ?? []);
      notifyListeners();
    }
  }

  // Add items to the cart
  Future<void> addToCart(String userId, List<String> items) async {
    final existingCart = await FirebaseFirestore.instance
        .collection('cart')
        .where('userId', isEqualTo: userId)
        .get();

    if (existingCart.docs.isNotEmpty) {
      final cartDoc = existingCart.docs.first;
      final cartData = cartDoc.data();
      final currentItems = List<String>.from(cartData['items'] ?? []);
      currentItems.addAll(items);

      await FirebaseFirestore.instance
          .collection('cart')
          .doc(cartDoc.id)
          .update({'items': currentItems, 'addedAt': Timestamp.now()});
    } else {
      await FirebaseFirestore.instance.collection('cart').add({
        'userId': userId,
        'items': items,
        'addedAt': Timestamp.now(),
      });
    }

    _cartItems.addAll(items);
    notifyListeners();
  }

  // Remove items from the cart
  Future<void> removeFromCart(String userId, String item) async {
    final cartSnapshot = await FirebaseFirestore.instance
        .collection('cart')
        .where('userId', isEqualTo: userId)
        .get();

    if (cartSnapshot.docs.isNotEmpty) {
      final cartDoc = cartSnapshot.docs.first;
      final cartData = cartDoc.data();
      final currentItems = List<String>.from(cartData['items'] ?? []);
      currentItems.remove(item);

      await FirebaseFirestore.instance
          .collection('cart')
          .doc(cartDoc.id)
          .update({'items': currentItems});
    }

    _cartItems.remove(item);
    notifyListeners();
  }
}

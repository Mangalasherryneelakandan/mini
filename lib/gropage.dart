import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'pantrymodel.dart';

class PantryPage extends StatefulWidget {
  const PantryPage({Key? key}) : super(key: key);

  @override
  _PantryPageState createState() => _PantryPageState();
}

class _PantryPageState extends State<PantryPage> {
  late CollectionReference pantryRef;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _initializePantry();
    _setupFCM(); // ✅ Initialize FCM
  }

  // Initialize pantry reference directly from Firestore
  void _initializePantry() {
    pantryRef = FirebaseFirestore.instance
        .collection('pantries')
        .doc('defaultUser123')
        .collection('items');

    _checkForExpiringItems(); // ✅ Check for expiring items
  }

  // Setup Firebase Cloud Messaging (FCM) for web and mobile
  void _setupFCM() async {
    // Request permission for notifications
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Notification permission granted.');

      // Get FCM token
      String? token = await _firebaseMessaging.getToken();
      print('FCM Token: $token');
    } else {
      print('❌ Notification permission denied.');
    }

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showForegroundNotification(
          message.notification!.title!,
          message.notification!.body!,
        );
      }
    });
  }

  // Show notification when app is in foreground
  void _showForegroundNotification(String title, String body) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Check for items expiring in less than 2 days and send notifications
  Future<void> _checkForExpiringItems() async {
    QuerySnapshot snapshot = await pantryRef.get();
    DateTime now = DateTime.now();

    for (var doc in snapshot.docs) {
      PantryItem item = PantryItem.fromDocument(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );

      if (item.expiryDate != null &&
          item.expiryDate!.difference(now).inDays <= 2) {
        // Trigger notification for expiring items
        _sendNotification(
          'Expiry Alert',
          '${item.name} is expiring in less than 2 days!',
        );
      }
    }
  }

  // Send notification through FCM or show dialog
  Future<void> _sendNotification(String title, String body) async {
    _showForegroundNotification(title, body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pantry'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: pantryRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No items in your pantry.'),
            );
          }

          var items = snapshot.data!.docs
              .map((doc) => PantryItem.fromDocument(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ))
              .toList();

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              PantryItem item = items[index];
              return ListTile(
                title: Text(item.name),
                subtitle: Text(
                  'Expires on: ${_formatDate(item.expiryDate)}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteItem(item.id),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Delete item from Firestore
  Future<void> _deleteItem(String id) async {
    await pantryRef.doc(id).delete();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';
  }
}

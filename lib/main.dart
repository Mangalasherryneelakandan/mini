import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:grocery/recis.dart'; // Recipes page
import 'package:grocery/shop.dart'; // Shopping page
import 'gropage.dart'; // Pantry page
import 'pantrymodel.dart'; // PantryItem model
import 'package:firebase_messaging/firebase_messaging.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCsXT3crd7EX2GcUWVUGATysu39-TEG8Yw",
      authDomain: "mini-34f09.firebaseapp.com",
      projectId: "mini-34f09",
      storageBucket: "mini-34f09.appspot.com",
      messagingSenderId: "730089535973",
      appId: "1:730089535973:web:63a37ee6037d48aed7d70c",
      measurementId: "G-FTC61RJPVJ",
    ),
  );
  if (await FirebaseMessaging.instance.isSupported()) {
    FirebaseMessaging.instance.setAutoInitEnabled(true);
  }

  // Initialize local notifications
  await NotificationService().initNotification();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
      title: 'GROCIP',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MainHomeScreen(),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  @override
  _MainHomeScreenState createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _selectedIndex = 0; // Track the selected index
  late List<Widget> _pages; // Declare the pages list

  // User ID will be loaded after successful authentication
  String userId = '';

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  // Initialize user data from FirebaseAuth
  Future<void> _initializeUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      setState(() {
        userId = user.uid; // Assign userId if authenticated
      });
    } else {
      // Handle user not logged in
      setState(() {
        userId = 'defaultUser123'; // Assign a default value
      });
    }

    // Initialize the pages list after userId is set
    _pages = [
      PantryPage(), // Pass userId to load pantry data
      RecipesPage(), // Recipes page
      ShoppingPage(userId: userId), // Shopping page
    ];
  }

  // Handle navigation between pages
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator if userId is not ready
    if (userId.isEmpty) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('GROCIP'),
        backgroundColor: Colors.green,
      ),
      body: _pages[_selectedIndex], // Show selected page
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.kitchen),
            label: 'Pantry',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Shop',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, // Handle item tap
      ),
    );
  }
}

// ============================
// 🔔 Notification Service
// ============================
class NotificationService {
  static final NotificationService _notificationService =
  NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(settings);
  }

  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'channel_id',
      'Expiry Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformDetails,
    );
  }
}

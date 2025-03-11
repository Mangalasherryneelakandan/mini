import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'recipage.dart'; // Import the Recipe Page
import 'gropage.dart'; // Import the Groceries Page
import 'srchpage.dart'; // Import the SearchPage
import 'inventory.dart'; // Import the Inventory Page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeMode = await ThemeManager.getThemeMode();
  runApp(MyApp(themeMode: themeMode));
}

class MyApp extends StatefulWidget {
  final ThemeMode themeMode;
  MyApp({required this.themeMode});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.themeMode;
  }

  void _toggleTheme() async {
    final newTheme = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await ThemeManager.saveThemeMode(newTheme);
    setState(() {
      _themeMode = newTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GROCIP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: HomePage(onThemeToggle: _toggleTheme),
      routes: {
        '/recipes': (context) => RecipeGridPage(),
        '/groceries': (context) => ProductListPage(),
        '/search': (context) => SearchPage(),
        '/inventory': (context) => ManageInventoryPage(),
      },
    );
  }
}

class ThemeManager {
  static const String _themeKey = 'themeMode';

  static Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, mode == ThemeMode.dark);
  }

  static Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false ? ThemeMode.dark : ThemeMode.light;
  }
}

class HomePage extends StatelessWidget {
  final VoidCallback onThemeToggle;

  HomePage({required this.onThemeToggle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GROCIP'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Colors.blue),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Welcome!',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'user@example.com',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.food_bank),
              title: Text('Recipes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/recipes');
              },
            ),
            ListTile(
              leading: Icon(Icons.search),
              title: Text('Search Groceries'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/search');
              },
            ),
            ListTile(
              leading: Icon(Icons.inventory),
              title: Text('Manage Inventory'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/inventory');
              },
            ),
            ListTile(
              leading: Icon(Icons.store),
              title: Text('Go to Product List'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/groceries');
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Swipe from the left or click on the menu icon to open the drawer.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/inventory');
              },
              child: Text('Manage Inventory'),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: onThemeToggle,
        child: Icon(Icons.brightness_6),
      ),
    );
  }
}

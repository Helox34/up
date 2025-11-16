// lib/main.dart
import 'package:flutter/material.dart';

// --- TWOJE IMPORTY ---
import 'pages/profile_page.dart';
import 'modules/challenges/screens/challenge_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WK Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          primary: Colors.red,
        ),
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const PlaceholderWidget(title: 'Strona główna'),
      const PlaceholderWidget(title: 'Społeczność'),

      /// 🔥 Poprawiona wersja – przekazujemy wymagane parametry
      ChallengeListScreen(
        primary: Colors.red,
        muted: Colors.grey,
      ),

      const PlaceholderWidget(title: 'Sklep'),

      /// Profil
      const ProfilePage(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Strona główna'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Społeczność'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Wyzwania'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Sklep'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// Placeholder dla pustych ekranów
class PlaceholderWidget extends StatelessWidget {
  final String title;
  const PlaceholderWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}

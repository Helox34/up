// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Twoje importy
import 'pages/profile_page.dart';
import 'pages/shop_page.dart';
import 'modules/challenges/screens/challenge_list_with_achievements_screen.dart'; // 👈 IMPORTUJEMY NOWY SCREEN
import 'services/progress_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (error) {
    print('❌ Firebase initialization error: $error');
  }

  try {
    ProgressService.instance.initializeChallenges();
  } catch (error) {
    print('❌ ProgressService error: $error');
  }

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
        ),
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
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
  int _currentIndex = 2; // 👈 DOMYŚLNIE WYZWANIA NA ŚRODKU

  final List<Widget> screens = [
    const PlaceholderWidget(title: 'Strona główna'),
    const PlaceholderWidget(title: 'Społeczność'),
    const ChallengeListWithAchievementsScreen(), // 👈 TEN SCREEN MA 2 ZAKŁADKI WEWNĘTRZNE
    const ShopPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Główna'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Społeczność'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Wyzwania'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Sklep'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

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
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:provider/provider.dart';

// AUTH
import 'modules/auth/auth_provider.dart';
import 'modules/auth/screens/splash_screen.dart';
import 'screens/auth_page.dart';

// COMMUNITY
import 'modules/community/community_provider.dart';
import 'modules/community/screens/community_page.dart';
import 'modules/community/screens/create_post_screen.dart';

// SERVICES
import 'services/units_service.dart';

// TWOJE IMPORTY
import 'pages/profile_page.dart';
import 'pages/shop_page.dart';
import 'modules/challenges/screens/challenge_list_with_achievements_screen.dart';
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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
        ChangeNotifierProvider(create: (_) => UnitsService()), // DODANY UNITS SERVICE
      ],
      child: const MyApp(),
    ),
  );
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
      home: const SplashScreen(),
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

  final List<Widget> screens = [
    const PlaceholderWidget(title: 'Strona główna'),
    const CommunityPage(),
    const ChallengeListWithAchievementsScreen(),
    const ShopPage(),
    const ProfilePage(),
  ];

  void _openCreatePost(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: const CreatePostScreen(),
      ),
    );
  }

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
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
        onPressed: () => _openCreatePost(context),
        backgroundColor: Colors.red,
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
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
// lib/widgets/app.dart
import 'package:flutter/material.dart';
import 'package:wkmobile/modules/pages/home_page.dart';
import 'package:wkmobile/modules/pages/community_page.dart';
import 'package:wkmobile/modules/challenges/screens/challenge_list_screen.dart';
import 'package:wkmobile/modules/pages/shop_page.dart';
import 'package:wkmobile/modules/pages/profile_page.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const CommunityPage(),
    const ChallengeListScreen(primary: Colors.red, muted: Colors.grey),
    const ShopPage(),
    const ProfilePage(),
  ];

  final List<BottomNavigationBarItem> _bottomNavItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Strona główna',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.people),
      label: 'Społeczność',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.emoji_events),
      label: 'Wyzwania',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.shopping_cart),
      label: 'Sklep',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: _bottomNavItems,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 12,
      ),
    );
  }
}
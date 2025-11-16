// lib/modules/pages/home_page.dart
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Strona główna'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[100],
      body: const Center(
        child: Text(
          'Strona główna WK Mobile',
          style: TextStyle(fontSize: 20, color: Colors.black87),
        ),
      ),
    );
  }
}

// lib/modules/pages/community_page.dart
class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Społeczność'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[100],
      body: const Center(
        child: Text(
          'Społeczność WK Mobile',
          style: TextStyle(fontSize: 20, color: Colors.black87),
        ),
      ),
    );
  }
}

// lib/modules/pages/shop_page.dart
class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sklep'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[100],
      body: const Center(
        child: Text(
          'Sklep WK Mobile',
          style: TextStyle(fontSize: 20, color: Colors.black87),
        ),
      ),
    );
  }
}
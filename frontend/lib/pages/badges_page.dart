import 'package:flutter/material.dart';
import '../models/badge_model.dart';
import '../components/badge_card.dart';

class BadgesPage extends StatefulWidget {
  const BadgesPage({super.key});

  @override
  State<BadgesPage> createState() => _BadgesPageState();
}

class _BadgesPageState extends State<BadgesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<AchievementBadge> allBadges = [ // Używamy AchievementBadge
    AchievementBadge(
      id: '1',
      title: 'Mistrz Podciągania',
      description: 'Wykonaj 100 podciągnięć',
      category: 'badges',
      currentProgress: 0,
      targetProgress: 100,
      icon: '💪',
      isSecret: false,
    ),
    AchievementBadge(
      id: '2',
      title: 'Spamer',
      description: 'Powtórz to samo ćwiczenie 50 razy',
      category: 'badges',
      currentProgress: 0,
      targetProgress: 50,
      icon: '🔁',
      isSecret: false,
    ),
    AchievementBadge(
      id: '3',
      title: 'Toksyczny Przyjaciel',
      description: 'Opuść 10 treningów z przyjaciółmi',
      category: 'badges',
      currentProgress: 0,
      targetProgress: 10,
      icon: '👥',
      isSecret: false,
    ),
    AchievementBadge(
      id: '4',
      title: 'Wyciskanie - Brąz',
      description: 'Wyciśnij 0.75x masy ciała',
      category: 'badges',
      currentProgress: 0,
      targetProgress: 10,
      icon: '🏋️',
      isSecret: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Odznaki'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Zdobyte'),
            Tab(text: 'Wszystkie'),
            Tab(text: 'Punkty'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ZDOBYTE TAB
          _buildBadgeList('badges', showOnlyEarned: true),

          // WSZYSTKIE TAB
          _buildBadgeList('badges', showOnlyEarned: false),

          // PUNKTY TAB
          _buildPointsTab(),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: const Icon(Icons.home), onPressed: () {}),
            IconButton(icon: const Icon(Icons.people), onPressed: () {}),
            IconButton(icon: const Icon(Icons.fitness_center), onPressed: () {}),
            IconButton(icon: const Icon(Icons.shopping_cart), onPressed: () {}),
            IconButton(icon: const Icon(Icons.person), onPressed: () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeList(String category, {bool showOnlyEarned = false}) {
    List<AchievementBadge> categoryBadges = allBadges.where((badge) => badge.category == category).toList();

    if (showOnlyEarned) {
      categoryBadges = categoryBadges.where((badge) => badge.currentProgress >= badge.targetProgress).toList();
    }

    if (categoryBadges.isEmpty) {
      return const Center(
        child: Text('Brak odznak do wyświetlenia'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categoryBadges.length,
      itemBuilder: (context, index) {
        final badge = categoryBadges[index];
        return BadgeCard(badge: badge); // Teraz powinno działać
      },
    );
  }

  Widget _buildPointsTab() {
    final totalPoints = allBadges.fold(0, (sum, badge) {
      if (badge.currentProgress >= badge.targetProgress) {
        return sum + 10;
      }
      return sum;
    });

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Łączna liczba punktów',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$totalPoints pkt',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _buildBadgeList('badges', showOnlyEarned: true),
          ),
        ],
      ),
    );
  }
}
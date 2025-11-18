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

  final List<Badge> allBadges = [
    // TROPHIES
    Badge(
      id: '1',
      title: 'Double Dipper',
      hint: '???',
      description: 'Complete multiple workouts in one day',
      category: 'trophies',
      currentProgress: 0,
      targetProgress: 10,
      icon: '🏆',
      isSecret: true,
    ),
    Badge(
      id: '2',
      title: 'Wanted Man',
      hint: 'Run!',
      description: 'Run 100km total distance',
      category: 'trophies',
      currentProgress: 0,
      targetProgress: 100,
      icon: '🏃',
      isSecret: true,
    ),

    // BADGES
    Badge(
      id: '3',
      title: 'One Upper',
      hint: 'Can you do one?',
      description: 'Complete 100 pull-ups',
      category: 'badges',
      currentProgress: 0,
      targetProgress: 100,
      icon: '💪',
      isSecret: false,
    ),
    Badge(
      id: '4',
      title: 'Spammer',
      hint: 'Having a boring lift',
      description: 'Repeat same exercise 50 times',
      category: 'badges',
      currentProgress: 0,
      targetProgress: 50,
      icon: '🔁',
      isSecret: false,
    ),

    // PROFICIENCY
    Badge(
      id: '5',
      title: 'Bench Press Proficiency',
      description: 'Reach 100kg bench press',
      category: 'proficiency',
      currentProgress: 83,
      targetProgress: 100,
      icon: '📊',
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
        title: Text('Your Display'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Trophies'),
            Tab(text: 'Badges'),
            Tab(text: 'Proficiency'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TROPHIES TAB
          _buildBadgeList('trophies'),

          // BADGES TAB
          _buildBadgeList('badges'),

          // PROFICIENCY TAB
          _buildBadgeList('proficiency'),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: Icon(Icons.person), onPressed: () {}),
            IconButton(icon: Icon(Icons.people), onPressed: () {}),
            IconButton(icon: Icon(Icons.fitness_center), onPressed: () {}),
            IconButton(icon: Icon(Icons.bar_chart), onPressed: () {}),
            IconButton(icon: Icon(Icons.shopping_cart), onPressed: () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeList(String category) {
    final categoryBadges = allBadges.where((badge) => badge.category == category).toList();

    return ListView.builder(
      itemCount: categoryBadges.length,
      itemBuilder: (context, index) {
        return BadgeCard(badge: categoryBadges[index]);
      },
    );
  }
}
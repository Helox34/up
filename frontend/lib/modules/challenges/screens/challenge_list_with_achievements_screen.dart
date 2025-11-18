import 'package:flutter/material.dart';
import 'challenge_list_screen.dart';
import '../../../pages/achievements_page.dart';

class ChallengeListWithAchievementsScreen extends StatefulWidget {
  const ChallengeListWithAchievementsScreen({super.key});

  @override
  State<ChallengeListWithAchievementsScreen> createState() => _ChallengeListWithAchievementsScreenState();
}

class _ChallengeListWithAchievementsScreenState extends State<ChallengeListWithAchievementsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wyzwania'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(
              icon: Icon(Icons.emoji_events),
              text: 'Wyzwania',
            ),
            Tab(
              icon: Icon(Icons.workspace_premium),
              text: 'Odznaki',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ChallengeListScreen(), // 👈 TWOJE 45 WYZWAŃ
          AchievementsPage(),    // 👈 SYSTEM ODZNAK/TROFEÓW
        ],
      ),
    );
  }
}
// lib/pages/achievements_page.dart
import 'package:flutter/material.dart';
import '../services/badge_service.dart';
import '../widgets/badge_card.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  Widget _buildCategoryList(String category) {
    final badges = BadgeService.getBadgesByCategory(category);

    if (badges.isEmpty) {
      return const Center(
        child: Text(
          'Brak odznak w tej kategorii',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        return BadgeCard(badge: badges[index]);
      },
    );
  }

  // Statystyki header
  Widget _buildStatsHeader() {
    final allBadges = BadgeService.allBadges;
    final completedBadges = allBadges.where((badge) => badge.isCompleted).length;
    final totalPoints = allBadges.fold(0, (sum, badge) => sum + (badge.isCompleted ? 100 : 0));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade600, Colors.red.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Twoje Odznaki',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                completedBadges.toString(),
                'Zdobyte',
                Icons.check_circle,
              ),
              _buildStatItem(
                allBadges.length.toString(),
                'Wszystkie',
                Icons.workspace_premium,
              ),
              _buildStatItem(
                totalPoints.toString(),
                'Punkty',
                Icons.star,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildStatsHeader(),
          Expanded(
            child: _buildCategoryList('badges'), // 👈 POKAZUJEMY TYLKO ODZNAKI
          ),
        ],
      ),
    );
  }
}
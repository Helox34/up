import 'package:flutter/material.dart';
import '../models/badge_model.dart';
import '../widgets/badge_card.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  late List<AchievementBadge> allBadges;

  @override
  void initState() {
    super.initState();
    _initializeBadges();
  }

  void _initializeBadges() {
    allBadges = [
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
      AchievementBadge(
        id: '5',
        title: 'Maraton Biegowy',
        description: 'Przebiegnij 42 km',
        category: 'badges',
        currentProgress: 0,
        targetProgress: 42,
        icon: '🏃',
        isSecret: false,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Zabezpieczenie przed pustą listą
    if (allBadges.isEmpty) {
      return const Center(
        child: Text('Brak osiągnięć do wyświetlenia'),
      );
    }

    final completedBadges = allBadges.where((badge) => badge.isCompleted).length;
    final totalBadges = allBadges.length;
    final completionPercentage = totalBadges > 0 ? (completedBadges / totalBadges * 100).round() : 0;

    return Scaffold(
      body: Column(
        children: [
          // Nagłówek ze statystykami
          _buildStatsHeader(completedBadges, totalBadges, completionPercentage),

          // Lista osiągnięć
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: allBadges.length,
              itemBuilder: (context, index) {
                return BadgeCard(badge: allBadges[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader(int completed, int total, int percentage) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Postęp osiągnięć',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: total > 0 ? completed / total : 0,
              backgroundColor: Colors.grey[300],
              color: Colors.blue,
              minHeight: 12,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ukończone: $completed/$total',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  '$percentage%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../models/badge_model.dart'; // Upewnij się że importujesz właściwy model

class BadgeCard extends StatelessWidget {
  final AchievementBadge badge; // Używamy AchievementBadge zamiast Badge

  const BadgeCard({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tytuł i ikona
          Row(
            children: [
              Text(
                badge.icon,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  badge.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Opis
          Text(
            badge.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),

          // Progress Bar
          LinearProgressIndicator(
            value: badge.currentProgress / badge.targetProgress,
            backgroundColor: Colors.grey[300],
            color: _getProgressColor(badge.category),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 6),

          // Procenty i postęp
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${((badge.currentProgress / badge.targetProgress) * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _getProgressColor(badge.category),
                ),
              ),
              Text(
                '${badge.currentProgress}/${badge.targetProgress}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(String category) {
    switch (category) {
      case 'trophies':
        return Colors.amber;
      case 'badges':
        return Colors.red;
      case 'proficiency':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }
}
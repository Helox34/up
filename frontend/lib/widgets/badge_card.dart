import 'package:flutter/material.dart';
import '../models/badge_model.dart';

class BadgeCard extends StatelessWidget {
  final AchievementBadge badge;

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
          // Tytuł
          Text(
            badge.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          // Opis/Hint
          Text(
            badge.displayText,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),

          // Progress Bar
          LinearProgressIndicator(
            value: badge.progressPercentage,
            backgroundColor: Colors.grey[300],
            color: _getProgressColor(badge.category),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 6),

          // Procenty
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(badge.progressPercentage * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _getProgressColor(badge.category),
                ),
              ),
              if (badge.targetProgress > 1)
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
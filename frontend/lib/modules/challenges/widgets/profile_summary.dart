// lib/modules/challenges/widgets/profile_summary.dart
import 'package:flutter/material.dart';
import '../models/challenge.dart';
import 'package:wkmobile/services/achievement_service.dart';

class ProfileSummary extends StatelessWidget {
  final List<Challenge> challenges;
  final Color primary;
  final Color muted;

  const ProfileSummary({
    Key? key,
    required this.challenges,
    required this.primary,
    required this.muted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userChallenges = challenges.where((c) => c.isJoined).toList();
    final completedChallenges = userChallenges.where((c) => c.isCompleted).length;
    final activeChallenges = userChallenges.where((c) => !c.isCompleted).length;

    final totalProgress = userChallenges.isNotEmpty
        ? userChallenges.map((c) => c.progress).reduce((a, b) => a + b) / userChallenges.length
        : 0.0;

    final achievementService = AchievementService.instance;
    final medals = achievementService.userMedals;

    String getLevel(double progress) {
      if (progress < 0.3) return 'Początkujący';
      if (progress < 0.6) return 'Średni';
      if (progress < 0.8) return 'Zaawansowany';
      return 'Ekspert';
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Twój profil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),
            const SizedBox(height: 16),

            // Punkty/Postęp
            Row(
              children: [
                Icon(Icons.emoji_events, color: primary),
                const SizedBox(width: 8),
                Text(
                  'Postęp: ${(totalProgress * 100).round()}%',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Tabela z wyzwaniami
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('Wyzwania ukończone', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('Aktualne', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('Poziom', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Text('$completedChallenges', style: TextStyle(fontSize: 16)),
                    Text('$activeChallenges', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
                    Text(getLevel(totalProgress), style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Pasek postępu
            LinearProgressIndicator(
              value: totalProgress,
              backgroundColor: muted.withOpacity(0.3),
              color: primary,
            ),

            const SizedBox(height: 16),

            // Sekcja medali
            _buildMedalsSection(medals, achievementService),
          ],
        ),
      ),
    );
  }

  Widget _buildMedalsSection(Map<String, int> medals, AchievementService achievementService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Zdobyte medale',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: primary,
          ),
        ),
        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMedalDisplay('🥉', 'Brązowe', medals['bronze'] ?? 0),
            _buildMedalDisplay('🥈', 'Srebrne', medals['silver'] ?? 0),
            _buildMedalDisplay('🥇', 'Złote', medals['gold'] ?? 0),
            _buildMedalDisplay('💎', 'Diamentowe', medals['diamond'] ?? 0),
          ],
        ),

        const SizedBox(height: 8),
        Text(
          'Łącznie medali: ${achievementService.totalMedals}',
          style: TextStyle(
            fontSize: 14,
            color: muted,
          ),
        ),
      ],
    );
  }

  Widget _buildMedalDisplay(String icon, String label, int count) {
    return Column(
      children: [
        Text(icon, style: TextStyle(fontSize: 24)),
        Text('$count', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 12, color: muted)),
      ],
    );
  }
}
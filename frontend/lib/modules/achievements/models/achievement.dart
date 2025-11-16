// lib/modules/achievements/models/achievement.dart
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementType type;
  final AchievementTier tier;
  final int points;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final Map<String, dynamic> requirements;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.tier,
    required this.points,
    required this.isUnlocked,
    this.unlockedAt,
    required this.requirements,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'icon': icon,
    'type': type.toString(),
    'tier': tier.toString(),
    'points': points,
    'isUnlocked': isUnlocked,
    'unlockedAt': unlockedAt?.millisecondsSinceEpoch,
    'requirements': requirements,
  };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    icon: json['icon'],
    type: AchievementType.values.firstWhere(
          (e) => e.toString() == json['type'],
      orElse: () => AchievementType.challenge,
    ),
    tier: AchievementTier.values.firstWhere(
          (e) => e.toString() == json['tier'],
      orElse: () => AchievementTier.bronze,
    ),
    points: json['points'],
    isUnlocked: json['isUnlocked'],
    unlockedAt: json['unlockedAt'] != null
        ? DateTime.fromMillisecondsSinceEpoch(json['unlockedAt'])
        : null,
    requirements: Map<String, dynamic>.from(json['requirements']),
  );
}

enum AchievementType {
  challenge,
  consistency,
  strength,
  endurance,
  social,
  special,
}

enum AchievementTier {
  bronze,
  silver,
  gold,
  platinum,
  diamond,
}

// lib/services/achievement_service.dart
import 'package:wkmobile/modules/achievements/models/achievement.dart';
import '../modules/challenges/models/challenge.dart';

class AchievementService {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  final List<Achievement> _achievements = [];

  List<Achievement> get achievements => _achievements;

  void initializeAchievements() {
    _achievements.addAll([
      // Wyzwania
      Achievement(
        id: 'first_challenge',
        title: 'Pierwsze Kroki',
        description: 'Ukończ swoje pierwsze wyzwanie',
        icon: '🎯',
        type: AchievementType.challenge,
        tier: AchievementTier.bronze,
        points: 10,
        isUnlocked: false,
        requirements: {'completed_challenges': 1},
      ),
      Achievement(
        id: 'challenge_master',
        title: 'Mistrz Wyzwań',
        description: 'Ukończ 10 wyzwań',
        icon: '🏆',
        type: AchievementType.challenge,
        tier: AchievementTier.silver,
        points: 50,
        isUnlocked: false,
        requirements: {'completed_challenges': 10},
      ),
      Achievement(
        id: 'challenge_legend',
        title: 'Legenda Wyzwań',
        description: 'Ukończ wszystkie wyzwania',
        icon: '👑',
        type: AchievementType.challenge,
        tier: AchievementTier.diamond,
        points: 500,
        isUnlocked: false,
        requirements: {'completed_challenges': 30},
      ),

      // Konsekwencja
      Achievement(
        id: 'week_warrior',
        title: 'Wojownik Tygodnia',
        description: 'Utrzymaj 7-dniową passę treningową',
        icon: '🔥',
        type: AchievementType.consistency,
        tier: AchievementTier.bronze,
        points: 25,
        isUnlocked: false,
        requirements: {'streak_days': 7},
      ),
      Achievement(
        id: 'month_master',
        title: 'Mistrz Miesiąca',
        description: 'Utrzymaj 30-dniową passę treningową',
        icon: '📅',
        type: AchievementType.consistency,
        tier: AchievementTier.gold,
        points: 100,
        isUnlocked: false,
        requirements: {'streak_days': 30},
      ),

      // Siła
      Achievement(
        id: 'strength_novice',
        title: 'Nowicjusz Siły',
        description: 'Osiągnij łączny wynik 300kg w trzech bojach',
        icon: '💪',
        type: AchievementType.strength,
        tier: AchievementTier.bronze,
        points: 30,
        isUnlocked: false,
        requirements: {'total_lift': 300},
      ),
      Achievement(
        id: 'strength_pro',
        title: 'Profesjonalista Siły',
        description: 'Osiągnij łączny wynik 500kg w trzech bojach',
        icon: '🏋️',
        type: AchievementType.strength,
        tier: AchievementTier.gold,
        points: 150,
        isUnlocked: false,
        requirements: {'total_lift': 500},
      ),

      // Społeczność
      Achievement(
        id: 'social_butterfly',
        title: 'Motyl Społeczny',
        description: 'Zdobyj miejsce w top 10 rankingu społeczności',
        icon: '🦋',
        type: AchievementType.social,
        tier: AchievementTier.silver,
        points: 75,
        isUnlocked: false,
        requirements: {'community_rank': 10},
      ),
    ]);
  }

  void checkAchievements(List<Challenge> challenges, int streakDays, int communityRank) {
    final completedChallenges = challenges.where((c) => c.progress >= 1.0).length;
    final totalLift = _calculateTotalLift(challenges);

    for (final achievement in _achievements) {
      if (!achievement.isUnlocked) {
        final unlocked = _evaluateAchievement(
          achievement,
          completedChallenges,
          streakDays,
          totalLift,
          communityRank,
        );

        if (unlocked) {
          _unlockAchievement(achievement);
        }
      }
    }
  }

  bool _evaluateAchievement(
      Achievement achievement,
      int completedChallenges,
      int streakDays,
      double totalLift,
      int communityRank,
      ) {
    final req = achievement.requirements;

    switch (achievement.id) {
      case 'first_challenge':
      case 'challenge_master':
      case 'challenge_legend':
        return completedChallenges >= (req['completed_challenges'] as int);

      case 'week_warrior':
      case 'month_master':
        return streakDays >= (req['streak_days'] as int);

      case 'strength_novice':
      case 'strength_pro':
        return totalLift >= (req['total_lift'] as int);

      case 'social_butterfly':
        return communityRank <= (req['community_rank'] as int);

      default:
        return false;
    }
  }

  double _calculateTotalLift(List<Challenge> challenges) {
    double total = 0;
    final strengthChallenges = challenges.where((c) => c.type == ChallengeType.proficiency);

    for (final challenge in strengthChallenges) {
      if (challenge.progress >= 1.0) {
        total += (challenge.target['weight'] as num).toDouble();
      }
    }

    return total;
  }

  void _unlockAchievement(Achievement achievement) {
    final index = _achievements.indexWhere((a) => a.id == achievement.id);
    if (index != -1) {
      _achievements[index] = Achievement(
        id: achievement.id,
        title: achievement.title,
        description: achievement.description,
        icon: achievement.icon,
        type: achievement.type,
        tier: achievement.tier,
        points: achievement.points,
        isUnlocked: true,
        unlockedAt: DateTime.now(),
        requirements: achievement.requirements,
      );

      // Tutaj możesz dodać powiadomienie
      _showAchievementNotification(_achievements[index]);
    }
  }

  void _showAchievementNotification(Achievement achievement) {
    // Implementacja powiadomienia
    print('🎉 Odblokowano osiągnięcie: ${achievement.title}');
  }

  int get totalPoints {
    return _achievements
        .where((a) => a.isUnlocked)
        .fold(0, (sum, a) => sum + a.points);
  }

  int get unlockedCount {
    return _achievements.where((a) => a.isUnlocked).length;
  }
}
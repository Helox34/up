// lib/modules/challenges/models/challenge.dart
import 'package:flutter/foundation.dart';

enum ChallengeType {
  proficiency,
  specialization,
  streak,
  activity,
  exercise,
  endurance,
}

enum ChallengeCategory {
  strength,
  volume,
  consistency,
  variety,
  endurance,
  bodyweight,
}

enum MedalTier {
  none(0, 'Brak', 0),
  bronze(1, 'Brązowy', 1),
  silver(2, 'Srebrny', 2),
  gold(3, 'Złoty', 3),
  diamond(4, 'Diamentowy', 4);

  final int level;
  final String displayName;
  final int points;

  const MedalTier(this.level, this.displayName, this.points);
}

class ChallengeLevel {
  final MedalTier tier;
  final double targetValue;
  final String description;
  final bool isCompleted;
  final DateTime? completedAt;

  ChallengeLevel({
    required this.tier,
    required this.targetValue,
    required this.description,
    this.isCompleted = false,
    this.completedAt,
  });

  Map<String, dynamic> toJson() => {
    'tier': tier.level,
    'targetValue': targetValue,
    'description': description,
    'isCompleted': isCompleted,
    'completedAt': completedAt?.millisecondsSinceEpoch,
  };

  factory ChallengeLevel.fromJson(Map<String, dynamic> json) => ChallengeLevel(
    tier: MedalTier.values.firstWhere(
          (e) => e.level == json['tier'],
      orElse: () => MedalTier.none,
    ),
    targetValue: (json['targetValue'] as num).toDouble(),
    description: json['description'] as String,
    isCompleted: json['isCompleted'] as bool? ?? false,
    completedAt: json['completedAt'] != null
        ? DateTime.fromMillisecondsSinceEpoch(json['completedAt'])
        : null,
  );
}

class Challenge {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final int days;
  double progress;
  final String difficulty;
  final ChallengeType type;
  final ChallengeCategory category;
  final String unit;
  final String icon;
  bool isJoined;
  bool isCompleted;
  final DateTime? joinedAt;
  DateTime? completedAt;

  final List<ChallengeLevel> levels;
  MedalTier currentTier;
  double currentProgressValue;
  MedalTier highestAchievedTier;
  bool isUnlocked;

  Challenge({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.days,
    required this.progress,
    required this.difficulty,
    required this.type,
    required this.category,
    required this.unit,
    required this.icon,
    this.isJoined = false,
    this.isCompleted = false,
    this.joinedAt,
    this.completedAt,
    required this.levels,
    this.currentTier = MedalTier.bronze,
    this.currentProgressValue = 0.0,
    this.highestAchievedTier = MedalTier.none,
    this.isUnlocked = true,
  });

  factory Challenge.simple({
    required String id,
    required String title,
    required String subtitle,
    required String description,
    required String difficulty,
    required String type,
    required String category,
    required String icon,
    double progress = 0.0,
    bool isJoined = true, // ZAWSZE DOŁĄCZONE
    String unit = 'powtórzeń',
    double? bronzeTarget,
    double? silverTarget,
    double? goldTarget,
    double? diamondTarget,
    bool isUnlocked = true,
  }) {
    final bronze = bronzeTarget ?? 100;
    final silver = silverTarget ?? 500;
    final gold = goldTarget ?? 1000;
    final diamond = diamondTarget ?? 2500;

    final levels = [
      ChallengeLevel(
        tier: MedalTier.bronze,
        targetValue: bronze,
        description: 'Ukończ $bronze $unit',
      ),
      ChallengeLevel(
        tier: MedalTier.silver,
        targetValue: silver,
        description: 'Ukończ $silver $unit',
      ),
      ChallengeLevel(
        tier: MedalTier.gold,
        targetValue: gold,
        description: 'Ukończ $gold $unit',
      ),
      ChallengeLevel(
        tier: MedalTier.diamond,
        targetValue: diamond,
        description: 'Ukończ $diamond $unit',
      ),
    ];

    return Challenge(
      id: id,
      title: title,
      subtitle: subtitle,
      description: description,
      days: 0, // BRAK OGRANICZENIA CZASOWEGO
      progress: progress,
      difficulty: difficulty,
      type: parseType(type),
      category: parseCategory(category),
      unit: unit,
      icon: icon,
      isJoined: true, // ZAWSZE DOŁĄCZONE
      levels: levels,
      currentProgressValue: progress * bronze,
      isUnlocked: isUnlocked,
    );
  }

  static ChallengeType parseType(String s) {
    return ChallengeType.values.firstWhere(
          (e) => _enumToString(e).toLowerCase() == s.toLowerCase(),
      orElse: () => ChallengeType.proficiency,
    );
  }

  static ChallengeCategory parseCategory(String s) {
    return ChallengeCategory.values.firstWhere(
          (e) => _enumToString(e).toLowerCase() == s.toLowerCase(),
      orElse: () => ChallengeCategory.strength,
    );
  }

  ChallengeLevel get currentLevel {
    return levels.firstWhere(
          (level) => level.tier == currentTier,
      orElse: () => levels.first,
    );
  }

  double get currentTarget => currentLevel.targetValue;

  bool get canLevelUp => progress >= 1.0 && currentTier.level < MedalTier.diamond.level;

  String get dynamicDifficulty {
    switch (currentTier) {
      case MedalTier.bronze:
        return 'bardzo łatwy';
      case MedalTier.silver:
        return 'łatwy';
      case MedalTier.gold:
        return 'średni';
      case MedalTier.diamond:
        return 'trudny';
      default:
        return 'bardzo łatwy';
    }
  }

  Challenge levelUp() {
    if (!canLevelUp) return this;

    final nextTierIndex = currentTier.level;
    if (nextTierIndex >= levels.length) return this;

    final nextTier = MedalTier.values.firstWhere(
          (t) => t.level == nextTierIndex,
      orElse: () => MedalTier.diamond,
    );

    final updatedLevels = levels.map((level) {
      if (level.tier == currentTier) {
        return ChallengeLevel(
          tier: level.tier,
          targetValue: level.targetValue,
          description: level.description,
          isCompleted: true,
          completedAt: DateTime.now(),
        );
      }
      return level;
    }).toList();

    return copyWith(
      currentTier: nextTier,
      progress: 0.0,
      currentProgressValue: 0.0,
      highestAchievedTier: nextTier.level > highestAchievedTier.level ? nextTier : highestAchievedTier,
      levels: updatedLevels,
    );
  }

  Challenge updateProgress(double newValue) {
    final currentTarget = this.currentTarget;
    final newProgress = (newValue / currentTarget).clamp(0.0, 1.0);

    return copyWith(
      progress: newProgress,
      currentProgressValue: newValue,
    );
  }

  Challenge copyWith({
    double? progress,
    bool? isJoined,
    bool? isCompleted,
    DateTime? joinedAt,
    DateTime? completedAt,
    MedalTier? currentTier,
    double? currentProgressValue,
    MedalTier? highestAchievedTier,
    List<ChallengeLevel>? levels,
    bool? isUnlocked,
  }) =>
      Challenge(
        id: id,
        title: title,
        subtitle: subtitle,
        description: description,
        days: days,
        progress: progress ?? this.progress,
        difficulty: difficulty,
        type: type,
        category: category,
        unit: unit,
        icon: icon,
        isJoined: isJoined ?? this.isJoined,
        isCompleted: isCompleted ?? this.isCompleted,
        joinedAt: joinedAt ?? this.joinedAt,
        completedAt: completedAt ?? this.completedAt,
        levels: levels ?? this.levels,
        currentTier: currentTier ?? this.currentTier,
        currentProgressValue: currentProgressValue ?? this.currentProgressValue,
        highestAchievedTier: highestAchievedTier ?? this.highestAchievedTier,
        isUnlocked: isUnlocked ?? this.isUnlocked,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'description': description,
    'days': days,
    'progress': progress,
    'difficulty': difficulty,
    'type': _enumToString(type),
    'category': _enumToString(category),
    'unit': unit,
    'icon': icon,
    'isJoined': isJoined,
    'isCompleted': isCompleted,
    'joinedAt': joinedAt?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'levels': levels.map((l) => l.toJson()).toList(),
    'currentTier': currentTier.level,
    'currentProgressValue': currentProgressValue,
    'highestAchievedTier': highestAchievedTier.level,
    'isUnlocked': isUnlocked,
  };

  factory Challenge.fromJson(Map<String, dynamic> json) {
    final levelsRaw = (json['levels'] as List<dynamic>?);
    final levels = levelsRaw != null
        ? levelsRaw
        .map((e) => ChallengeLevel.fromJson(Map<String, dynamic>.from(e)))
        .toList()
        : <ChallengeLevel>[];

    return Challenge(
      id: json['id'] as String,
      title: json['title'] as String? ?? json['id'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      description: json['description'] as String? ?? '',
      days: (json['days'] as num?)?.toInt() ?? 0,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      difficulty: json['difficulty'] as String? ?? 'bardzo łatwy',
      type: parseType(json['type'] as String),
      category: parseCategory(json['category'] as String),
      unit: json['unit'] as String? ?? '',
      icon: json['icon'] as String? ?? '🏆',
      isJoined: json['isJoined'] as bool? ?? true,
      isCompleted: json['isCompleted'] as bool? ?? false,
      joinedAt: json['joinedAt'] != null ? DateTime.parse(json['joinedAt'] as String) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
      levels: levels,
      currentTier: MedalTier.values.firstWhere(
            (t) => t.level == (json['currentTier'] as num?)?.toInt(),
        orElse: () => MedalTier.bronze,
      ),
      currentProgressValue: (json['currentProgressValue'] as num?)?.toDouble() ?? 0.0,
      highestAchievedTier: MedalTier.values.firstWhere(
            (t) => t.level == (json['highestAchievedTier'] as num?)?.toInt(),
        orElse: () => MedalTier.none,
      ),
      isUnlocked: json['isUnlocked'] as bool? ?? true,
    );
  }

  Challenge mergeWith(Challenge saved) {
    return copyWith(
      progress: saved.progress,
      isJoined: saved.isJoined,
      isCompleted: saved.isCompleted,
      joinedAt: saved.joinedAt,
      completedAt: saved.completedAt,
      currentTier: saved.currentTier,
      currentProgressValue: saved.currentProgressValue,
      highestAchievedTier: saved.highestAchievedTier,
      levels: saved.levels,
      isUnlocked: saved.isUnlocked,
    );
  }
}

String _enumToString(dynamic enumValue) {
  return enumValue.toString().split('.').last;
}
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

class LevelDef {
  final String id; // e.g. 'bronze'
  final String name; // 'Bronze'
  final double? target; // absolute (kg, count)
  final double? targetMultiplier; // x bodyWeight
  final String medalType; // bronze/silver/gold/diamond

  LevelDef({
    required this.id,
    required this.name,
    this.target,
    this.targetMultiplier,
    required this.medalType,
  });

  factory LevelDef.fromJson(Map<String, dynamic> j) => LevelDef(
    id: j['id'] as String,
    name: j['name'] as String,
    target: j['target'] != null ? (j['target'] as num).toDouble() : null,
    targetMultiplier: j['targetMultiplier'] != null
        ? (j['targetMultiplier'] as num).toDouble()
        : null,
    medalType: j['medalType'] as String? ?? j['id'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (target != null) 'target': target,
    if (targetMultiplier != null) 'targetMultiplier': targetMultiplier,
    'medalType': medalType,
  };
}

class Challenge {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final int days;
  double progress; // 0.0 - 1.0 (kept for compatibility, computed from user progress)
  final String difficulty;
  final ChallengeType type;
  final ChallengeCategory category;
  final Map<String, dynamic> target; // legacy
  Map<String, dynamic> current; // legacy
  final String unit;
  final String icon;
  bool isJoined;
  bool isCompleted;
  final DateTime? joinedAt;
  DateTime? completedAt;
  final String? parentChallengeId;
  final String medalType;
  bool isUnlocked;
  final List<LevelDef> levels;

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
    required this.target,
    required this.current,
    required this.unit,
    required this.icon,
    this.isJoined = false,
    this.isCompleted = false,
    this.joinedAt,
    this.completedAt,
    this.parentChallengeId,
    this.medalType = 'none',
    this.isUnlocked = true,
    this.levels = const [],
  });

  Challenge copyWith({
    double? progress,
    Map<String, dynamic>? current,
    bool? isJoined,
    bool? isCompleted,
    DateTime? joinedAt,
    DateTime? completedAt,
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
        target: target,
        current: current ?? this.current,
        unit: unit,
        icon: icon,
        isJoined: isJoined ?? this.isJoined,
        isCompleted: isCompleted ?? this.isCompleted,
        joinedAt: joinedAt ?? this.joinedAt,
        completedAt: completedAt ?? this.completedAt,
        parentChallengeId: parentChallengeId,
        medalType: medalType,
        isUnlocked: isUnlocked ?? this.isUnlocked,
        levels: levels,
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
    'target': target,
    'current': current,
    'unit': unit,
    'icon': icon,
    'isJoined': isJoined,
    'isCompleted': isCompleted,
    'joinedAt': joinedAt?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'parentChallengeId': parentChallengeId,
    'medalType': medalType,
    'isUnlocked': isUnlocked,
    'levels': levels.map((l) => l.toJson()).toList(),
  };

  factory Challenge.fromJson(Map<String, dynamic> json) {
    // parse enums safely
    ChallengeType parseType(String? s) {
      if (s == null) return ChallengeType.proficiency;
      return ChallengeType.values.firstWhere(
            (e) => _enumToString(e).toLowerCase() == s.toLowerCase(),
        orElse: () => ChallengeType.proficiency,
      );
    }

    ChallengeCategory parseCategory(String? s) {
      if (s == null) return ChallengeCategory.strength;
      return ChallengeCategory.values.firstWhere(
            (e) => _enumToString(e).toLowerCase() == s.toLowerCase(),
        orElse: () => ChallengeCategory.strength,
      );
    }

    final levelsRaw = (json['levels'] as List<dynamic>?);
    final levels = levelsRaw != null
        ? levelsRaw
        .map((e) => LevelDef.fromJson(Map<String, dynamic>.from(e)))
        .toList()
        : <LevelDef>[];

    return Challenge(
      id: json['id'] as String,
      title: json['title'] as String? ?? json['id'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      description: json['description'] as String? ?? '',
      days: (json['days'] as num?)?.toInt() ?? 0,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      difficulty: json['difficulty'] as String? ?? 'Średni',
      type: parseType(json['type'] as String?),
      category: parseCategory(json['category'] as String?),
      target: json['target'] != null ? Map<String, dynamic>.from(json['target']) : {},
      current: json['current'] != null ? Map<String, dynamic>.from(json['current']) : {},
      unit: json['unit'] as String? ?? '',
      icon: json['icon'] as String? ?? '🏆',
      isJoined: json['isJoined'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      joinedAt: json['joinedAt'] != null ? DateTime.parse(json['joinedAt'] as String) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
      parentChallengeId: json['parentChallengeId'] as String?,
      medalType: json['medalType'] as String? ?? 'none',
      isUnlocked: json['isUnlocked'] as bool? ?? true,
      levels: levels,
    );
  }
}

// Pomocnicza funkcja do konwersji enum na string
String _enumToString(dynamic enumValue) {
  return enumValue.toString().split('.').last;
}
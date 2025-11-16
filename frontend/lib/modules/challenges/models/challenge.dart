// lib/modules/challenges/models/challenge.dart

enum ChallengeType {
  proficiency, // Maksymalne obciążenia
  specialization, // Objętość treningowa
  streak, // Pasy i postęp
  activity, // Aktywności ogólne
  exercise, // Konkretne ćwiczenia
  endurance, // Czas i wytrzymałość
}

enum ChallengeCategory {
  strength,
  volume,
  consistency,
  variety,
  endurance,
  bodyweight,
}

class Challenge {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final int days;
  final double progress; // 0.0 - 1.0
  final String difficulty; // 'Łatwy','Średni','Trudny'
  final ChallengeType type;
  final ChallengeCategory category;
  final Map<String, dynamic> target; // Cel do osiągnięcia
  final Map<String, dynamic> current; // Aktualny postęp
  final String unit; // Jednostka (kg, km, serie, etc.)
  final String icon; // Ikona
  final bool isJoined; // Czy użytkownik dołączył do wyzwania
  final bool isCompleted; // Czy wyzwanie ukończone
  final DateTime? joinedAt; // Data dołączenia
  final DateTime? completedAt; // Data ukończenia
  final String? parentChallengeId; // ID wyzwania które musi być ukończone przed tym
  final String medalType; // 'bronze', 'silver', 'gold', 'diamond'
  final bool isUnlocked; // Czy wyzwanie jest dostępne

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
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'description': description,
    'days': days,
    'progress': progress,
    'difficulty': difficulty,
    'type': type.toString(),
    'category': category.toString(),
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
  };

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      description: json['description'],
      days: json['days'],
      progress: (json['progress'] as num).toDouble(),
      difficulty: json['difficulty'],
      type: ChallengeType.values.firstWhere(
            (e) => e.toString() == 'ChallengeType.${json['type']}' || e.toString() == json['type'],
        orElse: () => ChallengeType.proficiency,
      ),
      category: ChallengeCategory.values.firstWhere(
            (e) => e.toString() == 'ChallengeCategory.${json['category']}' || e.toString() == json['category'],
        orElse: () => ChallengeCategory.strength,
      ),
      target: Map<String, dynamic>.from(json['target']),
      current: Map<String, dynamic>.from(json['current']),
      unit: json['unit'] ?? '',
      icon: json['icon'] ?? '🏆',
      isJoined: json['isJoined'] ?? false,
      isCompleted: json['isCompleted'] ?? false,
      joinedAt: json['joinedAt'] != null ? DateTime.parse(json['joinedAt']) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      parentChallengeId: json['parentChallengeId'],
      medalType: json['medalType'] ?? 'none',
      isUnlocked: json['isUnlocked'] ?? true,
    );
  }
}
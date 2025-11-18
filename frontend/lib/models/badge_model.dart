class AchievementBadge {
  final String id;
  final String title;
  final String? hint;
  final String description;
  final String category; // 'trophies', 'badges', 'proficiency'
  final int currentProgress;
  final int targetProgress;
  final bool isSecret;

  AchievementBadge({
    required this.id,
    required this.title,
    this.hint,
    required this.description,
    required this.category,
    required this.currentProgress,
    required this.targetProgress,
    this.isSecret = false,
  });

  double get progressPercentage => targetProgress > 0
      ? (currentProgress / targetProgress).clamp(0.0, 1.0)
      : 0.0;

  String get displayText => isSecret ? (hint ?? '???') : description;
  bool get isCompleted => currentProgress >= targetProgress;
}
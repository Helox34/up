class AchievementBadge {
  final String id;
  final String title;
  final String description;
  final String category;
  final int currentProgress;
  final int targetProgress;
  final String icon;
  final bool isSecret;
  final String? hint;

  AchievementBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.currentProgress,
    required this.targetProgress,
    required this.icon,
    this.isSecret = false,
    this.hint,
  });

  double get progressPercentage => targetProgress > 0 ? currentProgress / targetProgress : 0.0;

  String get displayText {
    if (isSecret && currentProgress < targetProgress) {
      return hint ?? '???';
    }
    return description;
  }

  bool get isCompleted => currentProgress >= targetProgress;
}
// lib/services/badge_service.dart
import '../models/badge_model.dart';

class BadgeService {
  static final List<AchievementBadge> allBadges = [
    // ODZNAKI (jak na zdjęciach)
    AchievementBadge(
      id: 'badge1',
      title: 'Mistrz Podciągania',
      hint: 'Dasz radę zrobić jedno?',
      description: 'Wykonaj 100 podciągnięć',
      category: 'badges',
      currentProgress: 0,
      targetProgress: 100,
      isSecret: false,
    ),
    AchievementBadge(
      id: 'badge2',
      title: 'Spamer',
      hint: 'Nudny trening',
      description: 'Powtórz to samo ćwiczenie 50 razy',
      category: 'badges',
      currentProgress: 0,
      targetProgress: 50,
      isSecret: false,
    ),
    AchievementBadge(
      id: 'badge3',
      title: 'Toksyczny Przyjaciel',
      hint: 'Bądź złym przyjacielem',
      description: 'Opuść 10 treningów z przyjaciółmi',
      category: 'badges',
      currentProgress: 0,
      targetProgress: 10,
      isSecret: false,
    ),

    // ODZNAKI Z WYZWANIA WYCISKANIE
    AchievementBadge(
      id: 'bench_bronze',
      title: 'Wyciskanie - Brąz',
      description: 'Wyciśnij 0.75× masy ciała',
      category: 'badges',
      currentProgress: 0,
      targetProgress: 1,
      isSecret: false,
    ),
    AchievementBadge(
      id: 'bench_silver',
      title: 'Wyciskanie - Srebro',
      description: 'Wyciśnij 1.0× masy ciała',
      category: 'badges',
      currentProgress: 0,
      targetProgress: 1,
      isSecret: false,
    ),
    AchievementBadge(
      id: 'bench_gold',
      title: 'Wyciskanie - Złoto',
      description: 'Wyciśnij 1.25× masy ciała',
      category: 'badges',
      currentProgress: 0,
      targetProgress: 1,
      isSecret: false,
    ),
    AchievementBadge(
      id: 'bench_diamond',
      title: 'Wyciskanie - Diament',
      description: 'Wyciśnij 1.5× masy ciała',
      category: 'badges',
      currentProgress: 0,
      targetProgress: 1,
      isSecret: false,
    ),

    // MOŻESZ DODAĆ WIĘCEJ ODZNAK Z TWOICH WYZWAŃ...
  ];

  static List<AchievementBadge> getBadgesByCategory(String category) {
    return allBadges.where((badge) => badge.category == category).toList();
  }

  static List<String> get categories => ['badges']; // 👈 TYLKO ODZNAKI
}
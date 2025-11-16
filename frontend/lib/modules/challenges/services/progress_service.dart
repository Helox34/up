// lib/services/progress_service.dart
import 'package:wkmobile/modules/challenges/models/challenge.dart';

class ProgressService {
  static final ProgressService _instance = ProgressService._internal();
  factory ProgressService() => _instance;
  ProgressService._internal();

  static ProgressService get instance => _instance;

  List<Challenge> challenges = [];

  List<Challenge> get userChallenges => challenges.where((c) => c.isJoined).toList();
  List<Challenge> get completedChallenges => challenges.where((c) => c.isCompleted).toList();
  List<Challenge> get activeChallenges => challenges.where((c) => c.isJoined && !c.isCompleted).toList();

  void initializeChallenges() {
    challenges = _getDefaultChallenges();
  }

  // Dołącz do wyzwania
  void joinChallenge(String challengeId) {
    final index = challenges.indexWhere((c) => c.id == challengeId);
    if (index != -1) {
      challenges[index] = challenges[index].copyWith(
        isJoined: true,
        joinedAt: DateTime.now(),
        progress: 0.0,
      );
      _saveUserProgress();
    }
  }

  // Aktualizuj postęp wyzwania
  void updateChallengeProgress(String challengeId, num value) {
    final index = challenges.indexWhere((c) => c.id == challengeId);
    if (index != -1) {
      final challenge = challenges[index];
      final targetKey = challenge.target.keys.first;
      final targetValue = challenge.target[targetKey] as num;

      final newProgress = (value / targetValue).clamp(0.0, 1.0);
      final isCompleted = newProgress >= 1.0;

      challenges[index] = challenge.copyWith(
        progress: newProgress,
        current: {targetKey: value},
        isCompleted: isCompleted,
        completedAt: isCompleted ? DateTime.now() : null,
      );

      _saveUserProgress();
    }
  }

  // Pobierz statystyki
  Map<String, dynamic> getStats() {
    final userChallenges = this.userChallenges;
    final completed = completedChallenges.length;
    final total = userChallenges.length;
    final completionRate = total > 0 ? completed / total : 0.0;
    final avgProgress = userChallenges.isNotEmpty
        ? userChallenges.map((c) => c.progress).reduce((a, b) => a + b) / userChallenges.length
        : 0.0;

    return {
      'completed': completed,
      'total': total,
      'completionRate': completionRate,
      'avgProgress': avgProgress,
    };
  }

  // Filtrowanie wyzwań
  List<Challenge> getChallengesByCategory(ChallengeCategory? category) {
    if (category == null) return challenges;
    return challenges.where((c) => c.category == category).toList();
  }

  List<Challenge> getChallengesByStatus(bool joined) {
    return challenges.where((c) => c.isJoined == joined).toList();
  }

  // Domyślne wyzwania - UPROSZCZONE
  List<Challenge> _getDefaultChallenges() {
    return [
      // PROFIENCIES - Maksymalne obciążenia
      Challenge(
        id: 'bench_press_proficiency',
        title: 'Bench Press Proficiency',
        subtitle: 'Maksymalne obciążenie w wyciskaniu leżąc',
        description: 'Osiągnij swoje maksimum w wyciskaniu leżąc',
        days: 30,
        progress: 0.0,
        difficulty: 'Trudny',
        type: ChallengeType.proficiency,
        category: ChallengeCategory.strength,
        target: {'weight': 100},
        current: {'weight': 0},
        unit: 'kg',
        icon: '🏋️',
      ),
      Challenge(
        id: 'squat_proficiency',
        title: 'Squat Proficiency',
        subtitle: 'Maksymalne obciążenie w przysiadzie',
        description: 'Pokonaj swoje limity w przysiadzie',
        days: 30,
        progress: 0.0,
        difficulty: 'Trudny',
        type: ChallengeType.proficiency,
        category: ChallengeCategory.strength,
        target: {'weight': 120},
        current: {'weight': 0},
        unit: 'kg',
        icon: '🦵',
      ),
      Challenge(
        id: 'deadlift_proficiency',
        title: 'Deadlift Proficiency',
        subtitle: 'Maksymalne obciążenie w martwym ciągu',
        description: 'Podnieś swoje maksimum w martwym ciągu',
        days: 30,
        progress: 0.0,
        difficulty: 'Trudny',
        type: ChallengeType.proficiency,
        category: ChallengeCategory.strength,
        target: {'weight': 150},
        current: {'weight': 0},
        unit: 'kg',
        icon: '💪',
      ),

      // SPECIALIZATIONS - Objętość treningowa
      Challenge(
        id: 'chest_specialist',
        title: 'Chest Specialist',
        subtitle: 'Objętość treningu klatki piersiowej',
        description: 'Wykonaj 5000 serii na klatkę piersiową',
        days: 90,
        progress: 0.0,
        difficulty: 'Średni',
        type: ChallengeType.specialization,
        category: ChallengeCategory.volume,
        target: {'volume': 5000},
        current: {'volume': 0},
        unit: 'serii',
        icon: '👊',
      ),

      // STREAK & PROGRESS
      Challenge(
        id: 'resolve',
        title: 'Resolve',
        subtitle: 'Zwiększ tygodniową passę',
        description: 'Utrzymaj passę treningową przez 4 tygodnie',
        days: 28,
        progress: 0.0,
        difficulty: 'Średni',
        type: ChallengeType.streak,
        category: ChallengeCategory.consistency,
        target: {'streak': 28},
        current: {'streak': 0},
        unit: 'dni',
        icon: '🔥',
      ),

      // ACTIVITIES
      Challenge(
        id: 'gym_rat',
        title: 'Gym Rat',
        subtitle: 'Ukończ treningi',
        description: 'Wykonaj 100 treningów na siłowni',
        days: 365,
        progress: 0.0,
        difficulty: 'Średni',
        type: ChallengeType.activity,
        category: ChallengeCategory.consistency,
        target: {'workouts': 100},
        current: {'workouts': 0},
        unit: 'treningów',
        icon: '🐀',
      ),

      // SPECIFIC EXERCISES
      Challenge(
        id: 'pull_up_master',
        title: 'Pull-Up Master',
        subtitle: 'Wykonaj podciągnięcia',
        description: 'Zrób 1000 podciągnięć',
        days: 60,
        progress: 0.0,
        difficulty: 'Średni',
        type: ChallengeType.exercise,
        category: ChallengeCategory.bodyweight,
        target: {'reps': 1000},
        current: {'reps': 0},
        unit: 'powtórzeń',
        icon: '🙃',
      ),

      // TIME & ENDURANCE
      Challenge(
        id: 'test_of_patience',
        title: 'Test of Patience',
        subtitle: 'Ukończ ćwiczenia na czas',
        description: 'Spędź 50 godzin na treningach wytrzymałościowych',
        days: 180,
        progress: 0.0,
        difficulty: 'Trudny',
        type: ChallengeType.endurance,
        category: ChallengeCategory.endurance,
        target: {'hours': 50},
        current: {'hours': 0},
        unit: 'godzin',
        icon: '⏱️',
      ),
    ];
  }

  void _saveUserProgress() {
    // TODO: Implementacja zapisu do shared_preferences
    print('Zapisano postęp użytkownika');
  }
}
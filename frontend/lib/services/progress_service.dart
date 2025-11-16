// lib/services/progress_service.dart
import 'package:wkmobile/modules/challenges/models/challenge.dart';
import 'achievement_service.dart';

class ProgressService {
  static final ProgressService _instance = ProgressService._internal();
  factory ProgressService() => _instance;
  ProgressService._internal();



  static ProgressService get instance => _instance;

  List<Challenge> _challenges = [];
  List<Challenge> get challenges => _challenges;

  List<Challenge> get userChallenges => _challenges.where((challenge) => challenge.isJoined).toList();
  List<Challenge> get completedChallenges => _challenges.where((challenge) => challenge.isCompleted).toList();
  List<Challenge> get activeChallenges => _challenges.where((challenge) => challenge.isJoined && !challenge.isCompleted).toList();
  List<Challenge> get unlockedChallenges => _challenges.where((challenge) => challenge.isUnlocked).toList();

  // Inicjalizacja KOMPLETNYCH wyzwań Z PROGRESJĄ
  List<Challenge> _getDefaultChallenges() {
    return [
      // ========== PRZYKŁAD SEKWENCJI POMPSKI ==========
      Challenge(
        id: 'pushups_bronze',
        title: '100 pompek',
        subtitle: 'Brązowy medal pompek',
        description: 'Wykonaj 100 pompek w dowolnym czasie. Zacznij swoją przygodę z kalisteniką!',
        days: 30,
        progress: 0.0,
        difficulty: 'Łatwy',
        type: ChallengeType.exercise,
        category: ChallengeCategory.bodyweight,
        target: {'reps': 100},
        current: {'reps': 0},
        unit: 'pompek',
        icon: '💪',
        isUnlocked: true, // Pierwsze wyzwanie zawsze odblokowane
        medalType: 'bronze',
      ),
      Challenge(
        id: 'pushups_silver',
        title: '500 pompek',
        subtitle: 'Srebrny medal pompek',
        description: 'Wykonaj 500 pompek. Twoja wytrzymałość rośnie!',
        days: 60,
        progress: 0.0,
        difficulty: 'Średni',
        type: ChallengeType.exercise,
        category: ChallengeCategory.bodyweight,
        target: {'reps': 500},
        current: {'reps': 0},
        unit: 'pompek',
        icon: '💪',
        parentChallengeId: 'pushups_bronze',
        isUnlocked: false, // Odblokowane po ukończeniu brązowego
        medalType: 'silver',
      ),
      Challenge(
        id: 'pushups_gold',
        title: '1000 pompek',
        subtitle: 'Złoty medal pompek',
        description: 'Wykonaj 1000 pompek. Jesteś mistrzem pompek!',
        days: 90,
        progress: 0.0,
        difficulty: 'Trudny',
        type: ChallengeType.exercise,
        category: ChallengeCategory.bodyweight,
        target: {'reps': 1000},
        current: {'reps': 0},
        unit: 'pompek',
        icon: '💪',
        parentChallengeId: 'pushups_silver',
        isUnlocked: false, // Odblokowane po ukończeniu srebrnego
        medalType: 'gold',
      ),
      Challenge(
        id: 'pushups_diamond',
        title: '10000 pompek',
        subtitle: 'Diamentowy medal pompek',
        description: 'Wykonaj 10000 pompek. Legenda kalisteniki!',
        days: 365,
        progress: 0.0,
        difficulty: 'Trudny',
        type: ChallengeType.exercise,
        category: ChallengeCategory.bodyweight,
        target: {'reps': 10000},
        current: {'reps': 0},
        unit: 'pompek',
        icon: '💪',
        parentChallengeId: 'pushups_gold',
        isUnlocked: false, // Odblokowane po ukończeniu złotego
        medalType: 'diamond',
      ),

      // ========== PROFICIENCIES - Maksymalne obciążenia ==========
      Challenge(
        id: 'bench_press_proficiency',
        title: 'Bench Press Proficiency',
        subtitle: 'Maksymalne obciążenie w wyciskaniu leżąc',
        description: 'Osiągnij swoje maksimum w wyciskaniu leżąc. Trenuj regularnie i stopniowo zwiększaj obciążenie.',
        days: 30,
        progress: 0.0,
        difficulty: 'Trudny',
        type: ChallengeType.proficiency,
        category: ChallengeCategory.strength,
        target: {'weight': 100},
        current: {'weight': 0},
        unit: 'kg',
        icon: '🏋️',
        isUnlocked: true,
        medalType: 'bronze',
      ),
      // ... pozostałe wyzwania z twojego pliku (dodaj im medalType: 'bronze' i isUnlocked: true)
    ];
  }

  Future<void> initializeChallenges() async {
    if (_challenges.isEmpty) {
      _challenges = _getDefaultChallenges();
      print('✅ Załadowano ${_challenges.length} wyzwań');
      _checkUnlockedChallenges(); // Sprawdź które wyzwania są odblokowane
    }
  }

  // Dołącz do wyzwania
  Future<void> joinChallenge(String challengeId) async {
    final index = _challenges.indexWhere((challenge) => challenge.id == challengeId);
    if (index != -1) {
      final challenge = _challenges[index];
      _challenges[index] = challenge.copyWith(
        isJoined: true,
        joinedAt: DateTime.now(),
      );
      print('✅ Dołączono do wyzwania: ${challenge.title}');
    }
  }

  // Aktualizuj postęp wyzwania
  Future<void> updateChallengeProgress(String challengeId, num newValue) async {
    final index = _challenges.indexWhere((challenge) => challenge.id == challengeId);
    if (index != -1) {
      final challenge = _challenges[index];
      final key = challenge.current.keys.first;
      final targetValue = challenge.target[key] as num;

      final oldProgress = challenge.progress;
      final newProgress = _calculateProgress(targetValue, newValue);
      final isNewlyCompleted = !challenge.isCompleted && newProgress >= 1.0;

      final updatedChallenge = challenge.copyWith(
        current: {...challenge.current}..[key] = newValue,
        progress: newProgress,
        isCompleted: newProgress >= 1.0,
        completedAt: newProgress >= 1.0 ? DateTime.now() : challenge.completedAt,
      );

      _challenges[index] = updatedChallenge;

      if (isNewlyCompleted) {
        print('🎉 Ukończono wyzwanie: ${challenge.title}');
        // Przyznaj medal
        AchievementService().unlockMedal(challengeId, challenge.medalType);
        // Odblokuj następne wyzwania
        _unlockNextChallenges(challengeId);
      }

      print('📈 Zaktualizowano wyzwanie: ${challenge.title} - $newValue/${targetValue} ${challenge.unit} (${(newProgress * 100).round()}%)');
    }
  }

  // Oznacz wyzwanie jako ukończone
  Future<void> completeChallenge(String challengeId) async {
    final index = _challenges.indexWhere((challenge) => challenge.id == challengeId);
    if (index != -1) {
      final challenge = _challenges[index];
      final targetKey = challenge.target.keys.first;
      final targetValue = challenge.target[targetKey] as num;

      _challenges[index] = challenge.copyWith(
        progress: 1.0,
        current: {targetKey: targetValue},
        isCompleted: true,
        completedAt: DateTime.now(),
        isJoined: true, // Automatycznie dołącz jeśli nie było
      );

      print('🎉 Wymuszone ukończenie wyzwania: ${challenge.title}');
      AchievementService().unlockMedal(challengeId, challenge.medalType);
      _unlockNextChallenges(challengeId);
    }
  }

  double _calculateProgress(num target, num current) {
    if (target == 0) return 0.0;
    return (current / target).clamp(0.0, 1.0).toDouble();
  }

  // Odblokuj następne wyzwania po ukończeniu
  void _unlockNextChallenges(String completedChallengeId) {
    int unlockedCount = 0;

    for (int i = 0; i < _challenges.length; i++) {
      final challenge = _challenges[i];
      if (challenge.parentChallengeId == completedChallengeId && !challenge.isUnlocked) {
        _challenges[i] = challenge.copyWith(isUnlocked: true);
        unlockedCount++;
        print('🔓 Odblokowano wyzwanie: ${challenge.title}');
      }
    }

    if (unlockedCount > 0) {
      print('🎯 Odblokowano $unlockedCount nowych wyzwań');
    }
  }

  // Sprawdź które wyzwania powinny być odblokowane na starcie
  void _checkUnlockedChallenges() {
    // Wyzwania bez parentChallengeId są zawsze odblokowane
    // Te z parentChallengeId są odblokowane tylko jeśli parent jest ukończony
    for (int i = 0; i < _challenges.length; i++) {
      final challenge = _challenges[i];
      if (challenge.parentChallengeId != null) {
        final parent = _challenges.firstWhere(
              (c) => c.id == challenge.parentChallengeId,
          orElse: () => challenge,
        );
        if (parent.isCompleted && !challenge.isUnlocked) {
          _challenges[i] = challenge.copyWith(isUnlocked: true);
        }
      }
    }
  }

  List<Challenge> getChallengesByCategory(ChallengeCategory? category) {
    if (category == null) return unlockedChallenges;
    return unlockedChallenges.where((challenge) => challenge.category == category).toList();
  }

  Map<String, dynamic> getStats() {
    final completed = completedChallenges.length;
    final total = userChallenges.length;
    final avgProgress = _challenges.isEmpty ? 0.0 :
    _challenges.map((e) => e.progress).reduce((a, b) => a + b) / _challenges.length;

    return {
      'completed': completed,
      'total': total,
      'avgProgress': avgProgress,
      'completionRate': total > 0 ? (completed / total) : 0.0,
    };
  }

  // Statystyki dla profilu
  Map<String, dynamic> getUserStats() {
    final userChallenges = this.userChallenges;
    final completed = completedChallenges.length;
    final active = activeChallenges.length;
    final totalProgress = userChallenges.isNotEmpty
        ? userChallenges.map((c) => c.progress).reduce((a, b) => a + b) / userChallenges.length
        : 0.0;

    return {
      'completedCount': completed,
      'activeCount': active,
      'totalProgress': totalProgress,
      'totalChallenges': userChallenges.length,
      'medals': AchievementService().totalMedals,
    };
  }
}
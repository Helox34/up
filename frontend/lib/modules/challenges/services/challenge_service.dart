// lib/modules/challenges/services/challenge_service.dart
import '../models/challenge.dart';

class ChallengeService {
  List<Challenge> getDefaultChallenges() {
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
        target: {'weight': 100}, // kg
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

      // Dodaj tutaj pozostałe wyzwania...
    ];
  }

  double calculateProgress(Challenge challenge) {
    final target = challenge.target.values.first as num;
    final current = challenge.current.values.first as num;
    return (current / target).clamp(0.0, 1.0);
  }

  void updateProgress(Challenge challenge, num value) {
    final key = challenge.current.keys.first;
    challenge.current[key] = value;
    challenge.progress = calculateProgress(challenge);
  }
}
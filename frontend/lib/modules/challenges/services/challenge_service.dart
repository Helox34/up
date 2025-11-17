// lib/modules/challenges/services/challenge_service.dart
// Tymczasowa wersja bez Firebase

class ChallengeService {
  ChallengeService._();
  static final ChallengeService instance = ChallengeService._();

  final List<Challenge> _challenges = [];
  bool _loaded = false;

  List<Challenge> get challenges => List.unmodifiable(_challenges);
  String? get currentUserId => "demo-user"; // Tymczasowy użytkownik
  bool get isUserAuthenticated => true; // Zawsze zalogowany dla demo

  /// Load demo challenges
  Future<void> loadFromAssets({String path = 'assets/challenges.json', bool pushToFirestore = false}) async {
    if (_loaded) return;

    // Tymczasowe dane demo zamiast ładowania z Firebase
    _challenges.clear();

    // Przykładowe wyzwania
    _challenges.addAll([
      Challenge(
        id: 'pushups_bronze',
        title: '100 pompek',
        subtitle: 'Brązowy medal pompek',
        description: 'Wykonaj 100 pompek w dowolnym czasie. Zacznij swoją przygodę z kalisteniką!',
        days: 30,
        progress: 0.0,
        difficulty: 'Łatwy',
        type: 'exercise',
        category: 'bodyweight',
        target: {'reps': 100},
        current: {'reps': 0},
        unit: 'pompek',
        icon: '💪',
        isUnlocked: true,
        medalType: 'bronze',
        isJoined: false,
      ),
      Challenge(
        id: 'bench_press_bronze',
        title: '80 kg wyciskania',
        subtitle: 'Brązowy medal wyciskania',
        description: 'Wyciśnij 80 kg w wyciskaniu leżąc. Solidna podstawa!',
        days: 30,
        progress: 0.0,
        difficulty: 'Łatwy',
        type: 'strength',
        category: 'proficiency',
        target: {'weight': 80},
        current: {'weight': 0},
        unit: 'kg',
        icon: '🏋️',
        isUnlocked: true,
        medalType: 'bronze',
        isJoined: false,
      ),
    ]);

    _loaded = true;
  }

  Future<void> loadFromFirestore() async {
    // Tymczasowo używaj danych lokalnych
    await loadFromAssets();
  }

  Challenge? byId(String id) {
    try {
      return _challenges.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Write user progress (e.g., after join/update)
  Future<void> setUserProgress(String challengeId, Map<String, dynamic> data) async {
    // Tymczasowo tylko zapis w pamięci
    print('Progress saved for $challengeId: $data');
    await Future.delayed(Duration(milliseconds: 100)); // Symulacja opóźnienia
  }

  /// Join challenge
  Future<void> joinChallenge(String challengeId) async {
    final ch = byId(challengeId);
    if (ch == null) throw Exception('Challenge not found: $challengeId');

    // Tymczasowo tylko aktualizacja lokalna
    ch.isJoined = true;
    print('Joined challenge: $challengeId');
    await Future.delayed(Duration(milliseconds: 100)); // Symulacja opóźnienia
  }

  /// Update user profile data
  Future<void> updateUserProfile(Map<String, dynamic> updateData) async {
    // Tymczasowo tylko log
    print('Profile updated: $updateData');
    await Future.delayed(Duration(milliseconds: 100)); // Symulacja opóźnienia
  }
}r
// lib/modules/challenges/services/progress_service.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/challenge.dart';
import 'progress_helper.dart';

class ProgressService {
  static final ProgressService _instance = ProgressService._internal();
  factory ProgressService() => _instance;
  ProgressService._internal();

  static ProgressService get instance => _instance;

  List<Challenge> _challenges = [];
  List<Challenge> get challenges => _challenges;

  bool isInitialized = false;

  /// Inicjalizacja: ładowanie JSON + wczytywanie progresu użytkownika
  Future<void> initialize() async {
    if (isInitialized) return;

    // 1) Wczytaj wyzwania z assets/challenges.json
    final jsonString = await rootBundle.loadString('assets/challenges.json');
    final List<dynamic> rawData = json.decode(jsonString);

    _challenges = rawData.map((e) => Challenge.fromJson(e)).toList();

    // 2) Wczytaj progres użytkownika
    await _loadUserProgress();

    isInitialized = true;
  }

  /// Pobierz wyzwanie po ID
  Challenge? getById(String id) {
    try {
      return _challenges.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// ◾ Użytkownik dołącza do wyzwania
  Future<void> joinChallenge(String id) async {
    final index = _challenges.indexWhere((c) => c.id == id);
    if (index == -1) return;

    _challenges[index] = _challenges[index].copyWith(
      isJoined: true,
      joinedAt: DateTime.now(),
      progress: 0.0,
      current: { _challenges[index].target.keys.first: 0 },
    );

    await _saveUserProgress();
  }

  /// ◾ Aktualizacja progresu wyzwania
  Future<void> updateChallengeValue(String id, num newValue, Map<String, dynamic> userData) async {
    final index = _challenges.indexWhere((c) => c.id == id);
    if (index == -1) return;

    final ch = _challenges[index];

    final updated = ProgressHelper.updateProgress(ch, newValue, userData);
    _challenges[index] = updated;

    // Jeśli ukończone → automatyczne odblokowanie kolejnego poziomu
    if (updated.isCompleted) {
      _unlockNextLevel(updated);
    }

    await _saveUserProgress();
  }

  /// ◾ Automatyczne odblokowanie kolejnego poziomu (parentChallengeId → next)
  void _unlockNextLevel(Challenge completed) {
    final next = _challenges.where((c) => c.parentChallengeId == completed.id);

    for (final challenge in next) {
      final index = _challenges.indexWhere((c) => c.id == challenge.id);
      if (index != -1) {
        _challenges[index] = challenge.copyWith(
          isUnlocked: true,
        );
      }
    }
  }

  /// ◾ Pobieranie wyzwań wg statusu
  List<Challenge> get joinedChallenges =>
      _challenges.where((c) => c.isJoined).toList();

  List<Challenge> get activeChallenges =>
      _challenges.where((c) => c.isJoined && !c.isCompleted).toList();

  List<Challenge> get completedChallenges =>
      _challenges.where((c) => c.isCompleted).toList();

  List<Challenge> get unlockedChallenges =>
      _challenges.where((c) => c.isUnlocked).toList();

  /// ◾ Statystyki ogólne
  Map<String, dynamic> getStats() {
    final totalJoined = joinedChallenges.length;
    final completed = completedChallenges.length;

    final completionRate = totalJoined > 0 ? completed / totalJoined : 0.0;

    final avgProgress = joinedChallenges.isNotEmpty
        ? joinedChallenges.map((c) => c.progress).reduce((a, b) => a + b) /
        joinedChallenges.length
        : 0.0;

    return {
      'joined': totalJoined,
      'completed': completed,
      'completionRate': completionRate,
      'avgProgress': avgProgress,
    };
  }

  /// ◾ Zapis progresu użytkownika
  Future<void> _saveUserProgress() async {
    final prefs = await SharedPreferences.getInstance();

    final List<Map<String, dynamic>> jsonData =
    _challenges.map((c) => c.toJson()).toList();

    await prefs.setString('user_challenges', json.encode(jsonData));
  }

  /// ◾ Wczytanie progresu użytkownika przy starcie aplikacji
  Future<void> _loadUserProgress() async {
    final prefs = await SharedPreferences.getInstance();

    final saved = prefs.getString('user_challenges');

    if (saved == null) return;

    final List<dynamic> rawSaved = json.decode(saved);

    // Mapowanie progresu użytkownika na strukturę JSON z assets/challenges
    for (final savedItem in rawSaved) {
      final savedChallenge = Challenge.fromJson(savedItem);
      final index = _challenges.indexWhere((c) => c.id == savedChallenge.id);

      if (index != -1) {
        _challenges[index] = _challenges[index].mergeWith(savedChallenge);
      }
    }
  }
}

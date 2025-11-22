// lib/modules/challenges/services/progress_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/challenge.dart';

class ProgressService with ChangeNotifier {
  static final ProgressService _instance = ProgressService._internal();
  factory ProgressService() => _instance;
  ProgressService._internal();

  static ProgressService get instance => _instance;

  List<Challenge> _challenges = [];
  List<Challenge> get challenges => _challenges;

  bool isInitialized = false;

  Future<void> initialize() async {
    if (isInitialized) return;

    _challenges = _getDefaultChallenges();
    await _loadUserProgress();

    isInitialized = true;
    notifyListeners();
  }

  Challenge? getById(String id) {
    try {
      return _challenges.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateChallengeValue(String id, double newValue) async {
    final index = _challenges.indexWhere((c) => c.id == id);
    if (index == -1) return;

    var ch = _challenges[index];

    ch = ch.updateProgress(newValue);

    if (ch.canLevelUp) {
      ch = ch.levelUp();
      _showLevelUpNotification(ch);
    }

    _challenges[index] = ch;
    await _saveUserProgress();
    notifyListeners();
  }

  List<Challenge> get joinedChallenges =>
      _challenges.where((c) => c.isJoined).toList();

  List<Challenge> get activeChallenges =>
      _challenges.where((c) => c.isJoined && !c.isCompleted).toList();

  List<Challenge> get completedChallenges =>
      _challenges.where((c) => c.highestAchievedTier != MedalTier.none).toList();

  List<Challenge> get unlockedChallenges =>
      _challenges.where((c) => c.isUnlocked).toList();

  Map<String, MedalTier> getEarnedMedals() {
    final Map<String, MedalTier> medals = {};

    for (final challenge in _challenges) {
      if (challenge.highestAchievedTier != MedalTier.none) {
        medals[challenge.id] = challenge.highestAchievedTier;
      }
    }

    return medals;
  }

  int getTotalPoints() {
    return _challenges.fold(0, (sum, challenge) {
      if (challenge.highestAchievedTier != MedalTier.none) {
        return sum + challenge.highestAchievedTier.points;
      }
      return sum;
    });
  }

  int getCompletedChallengesCount() {
    return _challenges.where((c) => c.highestAchievedTier != MedalTier.none).length;
  }

  Map<String, dynamic> getStats() {
    final totalJoined = joinedChallenges.length;
    final completed = getCompletedChallengesCount();

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
      'totalPoints': getTotalPoints(),
    };
  }

  Future<void> _saveUserProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonData =
    _challenges.map((c) => c.toJson()).toList();
    await prefs.setString('user_challenges', json.encode(jsonData));
  }

  Future<void> _loadUserProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('user_challenges');
    if (saved == null) return;

    final List<dynamic> rawSaved = json.decode(saved);
    for (final savedItem in rawSaved) {
      final savedChallenge = Challenge.fromJson(savedItem);
      final index = _challenges.indexWhere((c) => c.id == savedChallenge.id);
      if (index != -1) {
        _challenges[index] = _challenges[index].mergeWith(savedChallenge);
      }
    }
  }

  List<Challenge> _getDefaultChallenges() {
    return [
      Challenge.simple(
        id: 'pushups_100',
        title: '100 pompek',
        subtitle: 'Brązowy medal pompek',
        description: 'Wykonaj 100 pompek aby zdobyć brązowy medal. Po osiągnięciu celu wyzwanie zresetuje się do 500 pompek dla srebrnego medalu.',
        difficulty: 'bardzo łatwy',
        type: 'exercise',
        category: 'bodyweight',
        icon: '💪',
        progress: 0.2, // 20/100
        unit: 'pompek',
        bronzeTarget: 100,
        silverTarget: 500,
        goldTarget: 1000,
        diamondTarget: 2500,
      ),
      Challenge.simple(
        id: 'benchpress_80',
        title: '80 kg wyciskania',
        subtitle: 'Brązowy medal wyciskania',
        description: 'Wyciśnij 80kg na ławce poziomej aby zdobyć brązowy medal. System automatycznie zwiększy cel do 100kg dla srebrnego medalu.',
        difficulty: 'bardzo łatwy',
        type: 'proficiency',
        category: 'strength',
        icon: '🏋️',
        progress: 0.0, // 0/80
        unit: 'kg',
        bronzeTarget: 80,
        silverTarget: 100,
        goldTarget: 120,
        diamondTarget: 150,
      ),
      Challenge.simple(
        id: 'squat_100',
        title: '100 kg przysiadów',
        subtitle: 'Brązowy medal przysiadów',
        description: 'Wykonaj przysiad z obciążeniem 100kg dla brązowego medalu. Kolejne poziomy: 140kg (srebro), 180kg (złoto), 220kg (diament).',
        difficulty: 'bardzo łatwy',
        type: 'proficiency',
        category: 'strength',
        icon: '🦵',
        progress: 0.0, // 0/100
        unit: 'kg',
        bronzeTarget: 100,
        silverTarget: 140,
        goldTarget: 180,
        diamondTarget: 220,
      ),
      Challenge.simple(
        id: 'plank_5min',
        title: '5 minut plank',
        subtitle: 'Brązowy medal wytrzymałości',
        description: 'Utrzymaj deskę przez 5 minut nieprzerwanie dla brązowego medalu. Poziomy: 5min (brąz), 10min (srebro), 15min (złoto), 20min (diament).',
        difficulty: 'bardzo łatwy',
        type: 'endurance',
        category: 'endurance',
        icon: '⏱️',
        progress: 0.0, // 0/5
        unit: 'minut',
        bronzeTarget: 5,
        silverTarget: 10,
        goldTarget: 15,
        diamondTarget: 20,
      ),
      Challenge.simple(
        id: 'pullups_20',
        title: '20 podciągnięć',
        subtitle: 'Brązowy medal podciągnięć',
        description: 'Wykonaj 20 podciągnięć dla brązowego medalu. Poziomy: 20 (brąz), 50 (srebro), 100 (złoto), 200 (diament).',
        difficulty: 'bardzo łatwy',
        type: 'exercise',
        category: 'bodyweight',
        icon: '🙅',
        progress: 0.0, // 0/20
        unit: 'podciągnięć',
        bronzeTarget: 20,
        silverTarget: 50,
        goldTarget: 100,
        diamondTarget: 200,
      ),
      Challenge.simple(
        id: 'running_50km',
        title: '50 km biegu',
        subtitle: 'Brązowy medal biegania',
        description: 'Przebiegnij 50km w miesiącu dla brązowego medalu. Poziomy: 50km (brąz), 100km (srebro), 200km (złoto), 500km (diament).',
        difficulty: 'bardzo łatwy',
        type: 'endurance',
        category: 'endurance',
        icon: '🏃',
        progress: 0.0, // 0/50
        unit: 'km',
        bronzeTarget: 50,
        silverTarget: 100,
        goldTarget: 200,
        diamondTarget: 500,
      ),
    ];
  }

  void _showLevelUpNotification(Challenge challenge) {
    print('🎉 AWANS! ${challenge.title} - teraz ${challenge.currentTier.displayName} medal!');
  }

  Future<void> resetAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_challenges');
    _challenges = _getDefaultChallenges();
    notifyListeners();
  }
}
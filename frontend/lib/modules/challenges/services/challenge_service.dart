// lib/modules/challenges/services/challenge_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/challenge.dart';

class ChallengeService {
  ChallengeService._();
  static final ChallengeService instance = ChallengeService._();

  final List<Challenge> _challenges = [];
  bool _loaded = false;

  List<Challenge> get challenges => List.unmodifiable(_challenges);
  String? get currentUserId => "demo-user";
  bool get isUserAuthenticated => true;

  /// Load demo challenges
  Future<void> loadFromAssets({String path = 'assets/challenges.json', bool pushToFirestore = false}) async {
    if (_loaded) return;

    _challenges.clear();

    // Przykładowe wyzwania - używając istniejących wartości enum
    _challenges.addAll([
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
        type: ChallengeType.proficiency,
        category: ChallengeCategory.strength,
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
    await loadFromAssets();
  }

  Challenge? byId(String id) {
    try {
      return _challenges.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> setUserProgress(String challengeId, Map<String, dynamic> data) async {
    print('Progress saved for $challengeId: $data');
    await Future.delayed(Duration(milliseconds: 100));
  }

  Future<void> joinChallenge(String challengeId) async {
    final ch = byId(challengeId);
    if (ch == null) throw Exception('Challenge not found: $challengeId');

    ch.isJoined = true;
    print('Joined challenge: $challengeId');
    await Future.delayed(Duration(milliseconds: 100));
  }

  Future<void> updateUserProfile(Map<String, dynamic> updateData) async {
    print('Profile updated: $updateData');
    await Future.delayed(Duration(milliseconds: 100));
  }
}
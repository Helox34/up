// lib/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../modules/challenges/models/challenge.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Zapisz wyzwania użytkownika
  Future<void> saveUserChallenges(List<Challenge> challenges) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final challengesJson = challenges.map((challenge) => challenge.toJson()).toList();

    await _firestore.collection('users').doc(user.uid).set({
      'challenges': challengesJson,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Pobierz wyzwania użytkownika
  Future<List<Challenge>> loadUserChallenges() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        final challengesData = doc.data()!['challenges'] as List<dynamic>;
        return challengesData.map((data) => Challenge.fromJson(Map<String, dynamic>.from(data))).toList();
      }
    } catch (e) {
      print('Błąd ładowania z Firebase: $e');
    }

    return [];
  }

  // Zapisz pojedynczy postęp
  Future<void> updateChallengeProgress(Challenge challenge) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).collection('challenge_progress').doc(challenge.id).set({
      'challengeId': challenge.id,
      'progress': challenge.progress,
      'current': challenge.current,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  // Pobierz historię postępów
  Future<Map<String, dynamic>> getProgressHistory(String challengeId) async {
    final user = _auth.currentUser;
    if (user == null) return {};

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('challenge_progress')
        .doc(challengeId)
        .get();

    return snapshot.data() ?? {};
  }
}
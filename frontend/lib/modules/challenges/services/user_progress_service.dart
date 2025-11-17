// lib/modules/challenges/services/user_progress_service.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Manages user profile (bodyweight, maxes) and updates user progress
class UserProgressService {
  UserProgressService._();
  static final UserProgressService instance = UserProgressService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fire = FirebaseFirestore.instance;

  Map<String, dynamic> currentUserProfile = {};

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _profileSub;

  Future<void> startListening() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    _profileSub = _fire.collection('users').doc(uid).snapshots().listen((snap) {
      if (snap.exists) {
        currentUserProfile = snap.data() ?? {};
      }
    });
    // initial fetch
    final doc = await _fire.collection('users').doc(uid).get();
    if (doc.exists) currentUserProfile = doc.data() ?? {};
  }

  Future<void> stopListening() async {
    await _profileSub?.cancel();
    _profileSub = null;
  }

  /// Example: update profile after a training event (auto progress)
  Future<void> updateAfterTraining(Map<String, dynamic> trainingEvent) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final doc = _fire.collection('users').doc(uid);
    await doc.set(trainingEvent, SetOptions(merge: true));
    // Firestore listener will update currentUserProfile automatically
  }
}

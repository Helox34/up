// lib/modules/auth/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AuthStatus status = AuthStatus.uninitialized;
  User? user;

  AuthProvider() {
    _init();
  }

  void _init() {
    _auth.authStateChanges().listen((u) {
      user = u;
      status = (u == null) ? AuthStatus.unauthenticated : AuthStatus.authenticated;
      notifyListeners();
    });
  }

  Future<void> signInWithEmail(String email, String pass) async {
    try {
      status = AuthStatus.loading;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: pass);
    } on FirebaseAuthException catch (e) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      rethrow;
    } finally {
      // Status zostanie zaktualizowany przez authStateChanges
    }
  }

  Future<void> registerWithEmail(String email, String pass, String displayName) async {
    try {
      status = AuthStatus.loading;
      notifyListeners();
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: pass);
      await cred.user!.updateDisplayName(displayName);
    } on FirebaseAuthException catch (e) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      rethrow;
    } finally {
      // Status zostanie zaktualizowany przez authStateChanges
    }
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 👇 TYMCZASOWO PUSTE METODY
  Future<void> signInWithGoogle() async {
    // TODO: Implementować później
  }

  Future<void> signInWithFacebook() async {
    // TODO: Implementować później
  }

  Future<void> signInWithApple() async {
    // TODO: Implementować później
  }
}
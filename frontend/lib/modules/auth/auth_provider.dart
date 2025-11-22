// lib/modules/auth/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fs = FirebaseFirestore.instance;
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
      await _createUserDocIfMissing(_auth.currentUser!);
    } on FirebaseAuthException catch (e) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> registerWithEmail(String email, String pass, String displayName) async {
    try {
      status = AuthStatus.loading;
      notifyListeners();
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: pass);
      await cred.user!.updateDisplayName(displayName);
      await _createUserDoc(cred.user!);
    } on FirebaseAuthException catch (e) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    try {
      status = AuthStatus.loading;
      notifyListeners();
      await _auth.signOut();
    } catch (e) {
      status = AuthStatus.authenticated;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      status = AuthStatus.loading;
      notifyListeners();
      print('signInWithGoogle called');
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken
      );
      final userCred = await _auth.signInWithCredential(credential);
      await _createUserDocIfMissing(userCred.user!);
    } catch (e) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signInWithFacebook() async {
    try {
      status = AuthStatus.loading;
      notifyListeners();
      print('signInWithFacebook called');
      final LoginResult res = await FacebookAuth.instance.login(permissions: ['email', 'public_profile']);
      if (res.status == LoginStatus.success) {
        final OAuthCredential facebookCredential = FacebookAuthProvider.credential(res.accessToken!.tokenString);
        final userCred = await _auth.signInWithCredential(facebookCredential);
        await _createUserDocIfMissing(userCred.user!);
      }
    } catch (e) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signInWithApple() async {
    try {
      status = AuthStatus.loading;
      notifyListeners();
      print('signInWithApple called');
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      );
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      final userCred = await _auth.signInWithCredential(oauthCredential);
      await _createUserDocIfMissing(userCred.user!);
    } catch (e) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _createUserDoc(User user) async {
    final doc = _fs.collection('users').doc(user.uid);

    // POPRAWIONA LOGIKA - unikamy operatorów na null'owalnych typach
    final displayName = user.displayName ?? '';
    final nameParts = displayName.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.last : '';

    await doc.set({
      'firstName': firstName,
      'lastName': lastName,
      'displayName': displayName.isNotEmpty ? displayName : user.email?.split('@').first ?? 'Użytkownik',
      'avatarUrl': user.photoURL,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _createUserDocIfMissing(User user) async {
    final doc = _fs.collection('users').doc(user.uid);
    final snapshot = await doc.get();
    if (!snapshot.exists) await _createUserDoc(user);
  }
}
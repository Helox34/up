// lib/modules/auth/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fs = FirebaseFirestore.instance;

  AuthService() {
    print('AuthService initialized');
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    await _createUserDocIfMissing(cred.user!);
    return cred;
  }

  Future<UserCredential> registerWithEmail(String email, String password, String displayName) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await cred.user!.updateDisplayName(displayName);
    await _createUserDoc(cred.user!);
    return cred;
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserCredential?> signInWithGoogle() async {
    print('signInWithGoogle called');
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken
    );
    final userCred = await _auth.signInWithCredential(credential);
    await _createUserDocIfMissing(userCred.user!);
    return userCred;
  }

  Future<UserCredential?> signInWithFacebook() async {
    print('signInWithFacebook called');
    final LoginResult res = await FacebookAuth.instance.login(permissions: ['email', 'public_profile']);
    if (res.status == LoginStatus.success) {
      final OAuthCredential facebookCredential = FacebookAuthProvider.credential(res.accessToken!.tokenString);
      final userCred = await _auth.signInWithCredential(facebookCredential);
      await _createUserDocIfMissing(userCred.user!);
      return userCred;
    } else {
      return null;
    }
  }

  Future<UserCredential?> signInWithApple() async {
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
    return userCred;
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
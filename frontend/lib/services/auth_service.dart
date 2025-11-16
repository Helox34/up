import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Rejestracja
  Future<User?> register(String email, String password) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } catch (e) {
      print("Błąd rejestracji: $e");
      return null;
    }
  }

  // Logowanie
  Future<User?> login(String email, String password) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } catch (e) {
      print("Błąd logowania: $e");
      return null;
    }
  }

  // Wylogowanie
  Future<void> logout() async => await _auth.signOut();

  // Aktualny użytkownik
  User? get currentUser => _auth.currentUser;
}

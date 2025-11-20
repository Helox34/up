// language: dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../main.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _pseudonymCtrl = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;
  bool _socialLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final _resetEmailCtrl = TextEditingController();

  Future<void> _submit() async {
    if (_isLogin) {
      if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wprowadź email i hasło')),
        );
        return;
      }
    } else {
      if (_firstNameCtrl.text.isEmpty || _lastNameCtrl.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wprowadź imię i nazwisko')),
        );
        return;
      }

      if (_emailCtrl.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wprowadź email')),
        );
        return;
      }

      if (_passCtrl.text.isEmpty || _confirmPassCtrl.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wprowadź hasło i potwierdzenie hasła')),
        );
        return;
      }

      if (_passCtrl.text != _confirmPassCtrl.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hasła nie są identyczne')),
        );
        return;
      }

      if (_passCtrl.text.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hasło musi mieć co najmniej 6 znaków')),
        );
        return;
      }
    }

    setState(() => _loading = true);
    try {
      if (_isLogin) {
        await _auth.signInWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
        );
        _redirectToHome();
      } else {
        final displayName = '${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}';
        final cred = await _auth.createUserWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
        );
        await cred.user!.updateDisplayName(displayName);
        await _createUserDoc(cred.user!);
        _redirectToHome();
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_getErrorMessage(e))),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _createUserDoc(User user) async {
    final doc = _firestore.collection('users').doc(user.uid);
    await doc.set({
      'firstName': _firstNameCtrl.text.trim(),
      'lastName': _lastNameCtrl.text.trim(),
      'pseudonym': _pseudonymCtrl.text.trim().isNotEmpty ? _pseudonymCtrl.text.trim() : null,
      'displayName': '${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}',
      'avatarUrl': null, // Zdjęcie będzie null - użytkownik doda je później
      'email': user.email,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _createUserDocIfMissing(User user) async {
    final doc = _firestore.collection('users').doc(user.uid);
    final snapshot = await doc.get();
    if (!snapshot.exists) {
      await _createUserDoc(user);
    }
  }

  void _clearRegistrationFields() {
    _firstNameCtrl.clear();
    _lastNameCtrl.clear();
    _pseudonymCtrl.clear();
    _emailCtrl.clear();
    _passCtrl.clear();
    _confirmPassCtrl.clear();
  }

  // Pozostałe metody bez zmian (_signInWithGoogle, _signInWithFacebook, _signInWithApple, etc.)
  Future<UserCredential?> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred = await _auth.signInWithCredential(credential);
      await _createUserDocIfMissing(userCred.user!);
      return userCred;
    } catch (e) {
      print('Google sign in error: $e');
      return null;
    }
  }

  Future<UserCredential?> _signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        final OAuthCredential facebookCredential =
        FacebookAuthProvider.credential(result.accessToken!.tokenString);
        final userCred = await _auth.signInWithCredential(facebookCredential);
        await _createUserDocIfMissing(userCred.user!);
        return userCred;
      } else {
        return null;
      }
    } catch (e) {
      print('Facebook sign in error: $e');
      return null;
    }
  }

  Future<UserCredential?> _signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCred = await _auth.signInWithCredential(oauthCredential);
      await _createUserDocIfMissing(userCred.user!);
      return userCred;
    } catch (e) {
      print('Apple sign in error: $e');
      return null;
    }
  }

  Future<void> _handleGoogleLogin() async {
    await _handleSocialLogin(_signInWithGoogle, 'Google');
  }

  Future<void> _handleFacebookLogin() async {
    await _handleSocialLogin(_signInWithFacebook, 'Facebook');
  }

  Future<void> _handleAppleLogin() async {
    await _handleSocialLogin(_signInWithApple, 'Apple');
  }

  Future<void> _handleSocialLogin(
      Future<UserCredential?> Function() signInFunction,
      String platformName
      ) async {
    setState(() => _socialLoading = true);
    try {
      final userCred = await signInFunction();
      if (userCred != null) {
        print('$platformName login successful: ${userCred.user?.email}');
        _redirectToHome();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logowanie przez $platformName anulowane')),
        );
      }
    } catch (e) {
      print('Błąd logowania $platformName: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd logowania przez $platformName: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _socialLoading = false);
      }
    }
  }

  void _redirectToHome() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found': return 'Nie znaleziono użytkownika';
      case 'wrong-password': return 'Nieprawidłowe hasło';
      case 'email-already-in-use': return 'Email jest już używany';
      case 'weak-password': return 'Hasło jest zbyt słabe';
      case 'invalid-email': return 'Nieprawidłowy email';
      default: return e.message ?? 'Wystąpił błąd';
    }
  }

  Future<void> _resetPassword() async {
    if (_resetEmailCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wprowadź email')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await _auth.sendPasswordResetEmail(email: _resetEmailCtrl.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email resetujący hasło został wysłany')),
      );
      Navigator.of(context).pop();
      _resetEmailCtrl.clear();
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_getErrorMessage(e))),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showResetPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resetuj hasło'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Wprowadź swój email, a wyślemy link do resetowania hasła:'),
            const SizedBox(height: 16),
            TextField(
              controller: _resetEmailCtrl,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            onPressed: _resetPassword,
            child: const Text('Wyślij'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zaloguj / Zarejestruj'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              _isLogin ? 'Witaj' : 'Zarejestruj się',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isLogin
                  ? 'Zaloguj się, aby korzystać ze społeczności'
                  : 'Utwórz nowe konto',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),

            // FORMULARZ REJESTRACJI - BEZ ZDJĘCIA
            if (!_isLogin) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _firstNameCtrl,
                      label: 'Imię',
                      icon: Icons.person,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _lastNameCtrl,
                      label: 'Nazwisko',
                      icon: Icons.person_outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _pseudonymCtrl,
                label: 'Pseudonim (opcjonalnie)',
                icon: Icons.alternate_email,
              ),
              const SizedBox(height: 16),
            ],

            // EMAIL
            _buildTextField(
              controller: _emailCtrl,
              label: 'Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // HASŁO
            _buildPasswordField(
              controller: _passCtrl,
              label: 'Hasło',
              obscureText: _obscurePassword,
              onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            const SizedBox(height: 16),

            // POTWIERDZENIE HASŁA (tylko rejestracja)
            if (!_isLogin) ...[
              _buildPasswordField(
                controller: _confirmPassCtrl,
                label: 'Powtórz hasło',
                obscureText: _obscureConfirmPassword,
                onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
              const SizedBox(height: 8),
            ],

            // Reset hasła (tylko login)
            if (_isLogin) ...[
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _showResetPasswordDialog,
                  child: const Text('Nie pamiętasz hasła?'),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Przycisk główny
            _loading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  _isLogin ? 'Zaloguj' : 'Zarejestruj się',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Przełącznik login/rejestracja
            Center(
              child: TextButton(
                onPressed: _loading || _socialLoading ? null : () {
                  setState(() {
                    _isLogin = !_isLogin;
                    if (_isLogin) {
                      _clearRegistrationFields();
                    } else {
                      _passCtrl.clear();
                    }
                  });
                },
                child: Text(
                  _isLogin ? 'Zarejestruj się' : 'Masz już konto? Zaloguj się',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),

            const Center(
              child: Text(
                'Lub zaloguj się przez',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 20),

            _buildSocialButton(
              icon: Icons.g_mobiledata,
              text: 'Zaloguj przez Google',
              onTap: _socialLoading ? null : _handleGoogleLogin,
              isLoading: _socialLoading,
            ),
            const SizedBox(height: 12),

            _buildSocialButton(
              icon: Icons.facebook,
              text: 'Zaloguj przez Facebook',
              onTap: _socialLoading ? null : _handleFacebookLogin,
              isLoading: _socialLoading,
            ),
            const SizedBox(height: 12),

            _buildSocialButton(
              icon: Icons.apple,
              text: 'Zaloguj przez Apple',
              onTap: _socialLoading ? null : _handleAppleLogin,
              isLoading: _socialLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
          onPressed: onToggle,
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String text,
    required VoidCallback? onTap,
    required bool isLoading,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: isLoading
            ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : Icon(icon, size: 24),
        label: isLoading
            ? const Text('Logowanie...')
            : Text(
          text,
          style: const TextStyle(fontSize: 16),
        ),
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _pseudonymCtrl.dispose();
    _resetEmailCtrl.dispose();
    super.dispose();
  }
}
// language: dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../modules/auth/auth_provider.dart';
import '../../main.dart'; // 👈 DODAJ TEN IMPORT

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;
  final _resetEmailCtrl = TextEditingController();

  Future<void> _submit() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wprowadź email i hasło')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      if (_isLogin) {
        await _auth.signInWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
        );

        // 👇 DODAJ PRZEKIEROWANIE PO UDANYM LOGOWANIU
        _redirectToHome();

      } else {
        if (_nameCtrl.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Wprowadź imię i nazwisko')),
          );
          return;
        }
        final cred = await _auth.createUserWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
        );
        await cred.user!.updateDisplayName(_nameCtrl.text.trim());

        // 👇 DODAJ PRZEKIEROWANIE PO UDANEJ REJESTRACJI
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

  // 👇 NOWA METODA DO PRZEKIEROWANIA
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
            // Nagłówek
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

            // Formularz
            if (!_isLogin) ...[
              _buildTextField(
                controller: _nameCtrl,
                label: 'Imię i nazwisko',
                icon: Icons.person,
              ),
              const SizedBox(height: 16),
            ],

            _buildTextField(
              controller: _emailCtrl,
              label: 'Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _passCtrl,
              label: 'Hasło',
              icon: Icons.lock,
              obscureText: true,
            ),
            const SizedBox(height: 8),

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
                onPressed: _loading ? null : () {
                  setState(() {
                    _isLogin = !_isLogin;
                    _nameCtrl.clear();
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

            // Social media
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

            // Przyciski social media
            _buildSocialButton(
              icon: Icons.g_mobiledata,
              text: 'Zaloguj przez Google',
              onTap: () => _showComingSoon('Google'),
            ),
            const SizedBox(height: 12),

            _buildSocialButton(
              icon: Icons.facebook,
              text: 'Zaloguj przez Facebook',
              onTap: () => _showComingSoon('Facebook'),
            ),
            const SizedBox(height: 12),

            _buildSocialButton(
              icon: Icons.apple,
              text: 'Zaloguj przez Apple',
              onTap: () => _showComingSoon('Apple'),
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

  Widget _buildSocialButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 24),
        label: Text(
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

  void _showComingSoon(String platform) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logowanie przez $platform - wkrótce')),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    _resetEmailCtrl.dispose();
    super.dispose();
  }
}
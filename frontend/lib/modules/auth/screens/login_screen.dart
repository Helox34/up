import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';
import '../widgets/social_sign_buttons.dart';
import './register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(children: [
            const SizedBox(height: 40),
            const Text('Witaj', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Zaloguj się, aby korzystać ze społeczności', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(children: [
                  TextField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                      controller: _pass,
                      decoration: const InputDecoration(labelText: 'Hasło'),
                      obscureText: true
                  ),
                  const SizedBox(height: 16),
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: TextStyle(color: Colors.red[700], fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_error != null) const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : () async {
                        setState((){ _loading = true; _error = null;});
                        try {
                          await auth.signInWithEmail(_email.text.trim(), _pass.text.trim());
                        } catch (e) {
                          setState(() => _error = _getUserFriendlyError(e.toString()));
                        } finally {
                          if (mounted) {
                            setState(() => _loading = false);
                          }
                        }
                      },
                      child: _loading ? const CircularProgressIndicator() : const Text('Zaloguj'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const RegisterScreen())
                      ),
                      child: const Text('Zarejestruj się')
                  ),
                  TextButton(
                      onPressed: () => _showResetDialog(context),
                      child: const Text('Nie pamiętasz hasła?')
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Lub zaloguj się przez'),
            const SizedBox(height: 8),
            SocialSignButtons(
              onGoogle: () async {
                setState(() => _loading = true);
                try {
                  await auth.signInWithGoogle();
                } catch (e) {
                  if (mounted) {
                    setState(() => _error = _getUserFriendlyError(e.toString()));
                  }
                } finally {
                  if (mounted) {
                    setState(() => _loading = false);
                  }
                }
              },
              onFacebook: () async {
                setState(() => _loading = true);
                try {
                  await auth.signInWithFacebook();
                } catch (e) {
                  if (mounted) {
                    setState(() => _error = _getUserFriendlyError(e.toString()));
                  }
                } finally {
                  if (mounted) {
                    setState(() => _loading = false);
                  }
                }
              },
              onApple: () async {
                setState(() => _loading = true);
                try {
                  await auth.signInWithApple();
                } catch (e) {
                  if (mounted) {
                    setState(() => _error = _getUserFriendlyError(e.toString()));
                  }
                } finally {
                  if (mounted) {
                    setState(() => _loading = false);
                  }
                }
              },
            )
          ]),
        ),
      ),
    );
  }

  // FUNKCJA DO TŁUMACZENIA BŁĘDÓW NA PRZYJAZNE KOMUNIKATY
  String _getUserFriendlyError(String error) {
    if (error.contains('[firebase_auth/invalid-email]')) {
      return 'Wprowadzony adres e-mail jest nieprawidłowy';
    } else if (error.contains('[firebase_auth/user-not-found]')) {
      return 'Nie znaleziono użytkownika o podanym adresie e-mail';
    } else if (error.contains('[firebase_auth/wrong-password]')) {
      return 'Wprowadzone hasło jest nieprawidłowe';
    } else if (error.contains('[firebase_auth/email-already-in-use]')) {
      return 'Adres e-mail jest już używany przez inne konto';
    } else if (error.contains('[firebase_auth/weak-password]')) {
      return 'Hasło jest zbyt słabe. Użyj co najmniej 6 znaków';
    } else if (error.contains('[firebase_auth/network-request-failed]')) {
      return 'Błąd połączenia z internetem. Sprawdź swoje połączenie';
    } else if (error.contains('[firebase_auth/too-many-requests]')) {
      return 'Zbyt wiele nieudanych prób. Spróbuj ponownie później';
    } else if (error.contains('[firebase_auth/user-disabled]')) {
      return 'To konto zostało wyłączone';
    } else if (error.contains('[firebase_auth/operation-not-allowed]')) {
      return 'Ta metoda logowania nie jest włączona';
    } else if (error.contains('canceled') || error.contains('cancelled')) {
      return 'Logowanie zostało anulowane';
    } else {
      return 'Wystąpił błąd podczas logowania. Spróbuj ponownie';
    }
  }

  void _showResetDialog(BuildContext ctx) {
    final ctrl = TextEditingController();
    showDialog(context: ctx, builder: (c) {
      return AlertDialog(
          title: const Text('Reset hasła'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(hintText: 'Podaj email'),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(c),
                child: const Text('Anuluj')
            ),
            TextButton(
                onPressed: () async {
                  try {
                    await Provider.of<AuthProvider>(ctx, listen: false).resetPassword(ctrl.text.trim());
                    Navigator.pop(c);
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('Wysłano email resetujący')),
                    );
                  } catch (e) {
                    Navigator.pop(c);
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text(_getUserFriendlyError(e.toString()))),
                    );
                  }
                },
                child: const Text('Wyślij')
            ),
          ]
      );
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }
}
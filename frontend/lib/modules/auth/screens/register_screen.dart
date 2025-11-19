import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _displayName = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rejestracja'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(children: [
            const SizedBox(height: 40),
            const Text('Dołącz do społeczności', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Stwórz nowe konto', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(children: [
                  TextField(
                    controller: _displayName,
                    decoration: const InputDecoration(labelText: 'Imię i nazwisko'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _pass,
                    decoration: const InputDecoration(labelText: 'Hasło'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : () async {
                        setState((){ _loading = true; _error = null;});
                        try {
                          await auth.registerWithEmail(
                              _email.text.trim(),
                              _pass.text.trim(),
                              _displayName.text.trim()
                          );
                        } catch (e) {
                          setState(()=> _error = e.toString());
                        } finally {
                          if (mounted) {
                            setState(()=> _loading = false);
                          }
                        }
                      },
                      child: _loading ? const CircularProgressIndicator() : const Text('Zarejestruj się'),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Masz już konto? Zaloguj się'),
                  ),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    _displayName.dispose();
    super.dispose();
  }
}
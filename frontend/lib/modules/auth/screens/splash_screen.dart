import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';
import '../../../../main.dart'; // import do HomeScreen
import '../../../../screens/auth_page.dart'; // import do AuthPage

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  void _checkAuthStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Poczekaj aż provider się zainicjalizuje
    await Future.delayed(const Duration(milliseconds: 500));

    // Sprawdzaj status aż będzie określony
    while (authProvider.status == AuthStatus.uninitialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (mounted) {
      if (authProvider.status == AuthStatus.authenticated) {
        // Użytkownik jest zalogowany - idź do HomeScreen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      } else {
        // Użytkownik nie jest zalogowany - idź do AuthPage
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const AuthPage(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
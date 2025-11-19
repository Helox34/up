import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './auth_provider.dart';
import './screens/login_screen.dart';

class AuthFlow extends StatelessWidget {
  const AuthFlow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return const LoginScreen();
      },
    );
  }
}
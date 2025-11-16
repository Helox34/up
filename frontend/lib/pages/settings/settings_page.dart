// language: dart
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ustawienia')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Tryb ciemny (demo)'),
            value: false,
            onChanged: (v) {},
          ),
          ListTile(title: const Text('Polityka prywatności')),
          ListTile(title: const Text('Zgłoś problem / moderacja')),
        ],
      ),
    );
  }
}
